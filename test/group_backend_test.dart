import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labaik/core/network/api_client.dart';
import 'package:labaik/core/network/api_exception.dart';
import 'package:labaik/core/network/signalr_hub.dart';
import 'package:labaik/core/utils/geo_utils.dart';
import 'package:labaik/core/utils/token_storage.dart';
import 'package:labaik/features/auth/data/account_registry.dart';
import 'package:labaik/features/auth/data/auth_session.dart';
import 'package:labaik/features/auth/data/models/account_type.dart';
import 'package:labaik/features/chats/data/repositories/server_chat_repository.dart';
import 'package:labaik/features/chats/data/sources/chat_api.dart';
import 'package:labaik/features/chats/data/sources/group_chat_api.dart';
import 'package:labaik/features/family/domain/entities/family_member.dart';
import 'package:labaik/features/group/data/models/company_services.dart';
import 'package:labaik/features/group/data/sources/group_api.dart';
import 'package:labaik/features/group/domain/entities/group_preview.dart';
import 'package:labaik/features/group/presentation/l10n/group_join_text.dart';
import 'package:labaik/features/group/data/sources/group_realtime.dart';
import 'package:labaik/features/group/data/sources/location_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_chat_repository.dart';

// -------------------------------------------------------------
// الربط مع سيرفر لبيك (ملف "تحديثات Labaik API لفريق Flutter"): شكل الطلبات والردود كما هي بالسيرفر
// المجموعة (/home و /groups/{id}/locations)، دردشة المجموعة، مشاركة الموقع، الأدوار، وتجديد التوكن عند 403
// -------------------------------------------------------------

/// سيرفر وهمي: بيسجّل الطلبات وبيرد حسب المسار
class FakeServer {
  final requests = <http.Request>[];
  final Map<String, Object? Function(http.Request)> routes;

  FakeServer(this.routes);

  ApiClient client({Future<String?> Function()? refresh}) => ApiClient(
        baseUrl: 'https://api.test/api/v1',
        accessToken: () async => 'tok',
        refreshToken: refresh ?? () async => null,
        client: MockClient((request) async {
          requests.add(request);
          final key = '${request.method} ${request.url.path.replaceFirst('/api/v1', '')}';
          final handler = routes[key];
          if (handler == null) return http.Response('{"title":"Not Found","status":404}', 404);
          final body = handler(request);
          if (body is http.Response) return body;
          return http.Response.bytes(utf8.encode(body == null ? '' : jsonEncode(body)), body == null ? 204 : 200, headers: {'content-type': 'application/json'});
        }),
      );
}

Map<String, Object?> _home({Map<String, Object?>? group}) => {'journey': null, 'ritual': null, 'group': group, 'unreadNotifications': 0};

const _group = {'id': 'g1', 'name': 'حملة النور', 'leaderName': 'أبو أحمد', 'memberCount': 4, 'myRole': 2, 'unreadAnnouncements': 1};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({'access_token': fakeJwt('me')});
    GroupRealtime.reset();
  });

  test('my group from /home (null = not added yet) and members with their shared locations', () async {
    final now = DateTime.now().toUtc();
    final server = FakeServer({
      'GET /home': (_) => _home(group: _group),
      'GET /groups/g1/locations': (_) => [
            {'userId': 's', 'fullName': 'أبو أحمد', 'role': 1, 'isSharing': true, 'latitude': 21.4219, 'longitude': 39.8245, 'accuracyMeters': 8.0, 'updatedAtUtc': now.toIso8601String(), 'isStale': false},
            {'userId': 'me', 'fullName': 'محمد', 'role': 2, 'isSharing': true, 'latitude': 21.42, 'longitude': 39.82, 'accuracyMeters': null, 'updatedAtUtc': now.toIso8601String(), 'isStale': false},
            {'userId': 'k', 'fullName': 'خالد', 'role': 2, 'isSharing': true, 'latitude': 21.41, 'longitude': 39.81, 'accuracyMeters': null, 'updatedAtUtc': now.subtract(const Duration(minutes: 18)).toIso8601String(), 'isStale': true},
            {'userId': 'sara', 'fullName': 'سارة', 'role': 2, 'isSharing': false, 'latitude': null, 'longitude': null, 'accuracyMeters': null, 'updatedAtUtc': null, 'isStale': true},
          ],
    });
    final api = GroupApi(server.client());

    final group = await api.myGroup();
    expect(group?.id, 'g1');
    expect(group?.name, 'حملة النور');
    expect(group?.leaderName, 'أبو أحمد');
    expect(group?.isLeader, isFalse);
    expect(server.requests.single.headers['Authorization'], 'Bearer tok');

    final members = await api.members('g1');
    expect(members.map((m) => m.name), ['أبو أحمد', 'محمد', 'خالد', 'سارة']);
    expect(members.first.isSupervisor, isTrue);
    expect(members[1].isMe, isTrue);
    expect(members.first.isOnline, isTrue);
    expect(members.first.locationState(), MemberLocationState.available);
    // أكتر من 15 دقيقة → "آخر ظهور" و"موقعه غير متاح"
    expect(members[2].isOnline, isFalse);
    expect(members[2].lastSeenAt, isNotNull);
    expect(members[2].locationState(), MemberLocationState.unavailable);
    // ما بيشارك → "لم يشارك موقعه"
    expect(members[3].location, isNull);
    expect(members[3].locationState(), MemberLocationState.notShared);

    final none = GroupApi(FakeServer({'GET /home': (_) => _home()}).client());
    expect(await none.myGroup(), isNull);
  });

  test('server chats: the group is the conversation (no /chats on this server), history is oldest→newest, send posts {body}, live messages are filtered by group', () async {
    final hubEvents = StreamController<List<Object?>>.broadcast();
    GroupRealtime.events = _FakeHub(hubEvents.stream);
    final server = FakeServer({
      'GET /home': (_) => _home(group: _group),
      'GET /groups/g1/messages': (r) => r.url.queryParameters['take'] == '1'
          ? [
              {'id': 'm2', 'groupId': 'g1', 'senderId': 's', 'senderName': 'أبو أحمد', 'body': 'التجمع عند البوابة', 'sentAtUtc': '2026-10-16T09:12:00Z'},
            ]
          : [
              {'id': 'm2', 'groupId': 'g1', 'senderId': 's', 'senderName': 'أبو أحمد', 'body': 'التجمع عند البوابة', 'sentAtUtc': '2026-10-16T09:12:00Z'},
              {'id': 'm1', 'groupId': 'g1', 'senderId': 'me', 'senderName': 'محمد', 'body': 'السلام عليكم', 'sentAtUtc': '2026-10-16T09:10:00Z'},
            ],
      'POST /groups/g1/messages': (r) => http.Response(
            jsonEncode({'id': 'm3', 'groupId': 'g1', 'senderId': 'me', 'senderName': 'محمد', 'body': (jsonDecode(r.body) as Map)['body'], 'sentAtUtc': '2026-10-16T09:15:00Z'}),
            201,
            headers: {'content-type': 'application/json'},
          ),
    });
    final client = server.client();
    final repo = ServerChatRepository(groups: GroupApi(client), groupChat: GroupChatApi(client), direct: ChatApi(client));

    final list = await repo.conversations();
    expect(list.single.id, 'g1');
    expect(list.single.title, 'حملة النور');
    expect(list.single.isGroup, isTrue);
    expect(list.single.lastMessage?.text, 'التجمع عند البوابة');
    expect(list.single.lastMessage?.senderName, 'أبو أحمد');

    final history = await repo.fetch('g1');
    expect(history.map((m) => m.id), ['m1', 'm2']);
    expect(history.first.fromMe, isTrue);
    expect(history.last.fromMe, isFalse);
    expect(await repo.fetch('g1', afterId: 'm1'), hasLength(1));

    final saved = await repo.send('g1', clientId: 'c1', text: ' وصلت ');
    expect(jsonDecode(server.requests.last.body), {'body': 'وصلت'});
    expect(saved.id, 'm3');
    expect(saved.clientId, 'c1');
    expect(saved.fromMe, isTrue);
    // رسالة موقع بالمجموعة: kind 2 مع الإحداثيات
    await repo.send('g1', clientId: 'c2', location: const GeoPoint(21.4, 39.8));
    expect(jsonDecode(server.requests.last.body), {'body': '', 'kind': 2, 'latitude': 21.4, 'longitude': 39.8});
    // نص فاضي بلا موقع ما بينبعت
    expect(() => repo.send('g1', clientId: 'c3', text: '  '), throwsA(isA<ApiException>()));

    final live = <String>[];
    final sub = repo.incoming('g1').listen((m) => live.add(m.id));
    await Future<void>.delayed(Duration.zero);
    hubEvents.add([
      {'id': 'x1', 'groupId': 'other', 'senderId': 's', 'body': 'لمجموعة تانية', 'sentAtUtc': '2026-10-16T09:16:00Z'},
    ]);
    hubEvents.add([
      {'id': 'm4', 'groupId': 'g1', 'senderId': 's', 'body': 'تمام', 'sentAtUtc': '2026-10-16T09:17:00Z'},
    ]);
    await Future<void>.delayed(Duration.zero);
    expect(live, ['m4']);
    await sub.cancel();
  });

  test('server chats: group + direct in one list, routing by conversation, DirectMessageReceived, group room from /home?groupId', () async {
    final hub = StreamController<List<Object?>>.broadcast();
    GroupRealtime.events = _FakeHub(hub.stream);
    final server = FakeServer({
      'GET /home': (r) => r.url.queryParameters['groupId'] == 'c1'
          ? _home()
          : _home(group: {..._group, 'myRole': 1, 'onlySupervisorCanPost': true, 'myMutedUntilUtc': null}),
      'GET /groups/g1/messages': (_) => [],
      'GET /chats': (_) => [
            {'id': 'c1', 'otherUserId': 's9', 'otherName': 'أبو أحمد', 'lastMessage': 'أهلاً', 'lastMessageAtUtc': '2026-10-21T09:00:00Z', 'unreadCount': 1},
          ],
      'GET /chats/c1/messages': (_) => [
            {'id': 'd1', 'conversationId': 'c1', 'senderId': 's9', 'body': 'أهلاً', 'sentAtUtc': '2026-10-21T09:00:00Z', 'isRead': false},
          ],
      'POST /chats/c1/messages': (r) => http.Response(
            jsonEncode({'id': 'd2', 'conversationId': 'c1', 'senderId': 'me', 'body': (jsonDecode(r.body) as Map)['body'], 'sentAtUtc': '2026-10-21T09:01:00Z', 'isRead': false}),
            201,
            headers: {'content-type': 'application/json'},
          ),
      'POST /chats/c1/messages/read': (_) => null,
    });
    final client = server.client();
    final repo = ServerChatRepository(groups: GroupApi(client), groupChat: GroupChatApi(client), direct: ChatApi(client));

    final list = await repo.conversations();
    expect(list.map((c) => (c.id, c.isGroup, c.title)), [('g1', true, 'حملة النور'), ('c1', false, 'أبو أحمد')]);
    expect((await repo.fetch('c1')).single.id, 'd1');
    await repo.send('c1', clientId: 'x', text: 'وصلت');
    expect(server.requests.last.url.path, '/api/v1/chats/c1/messages');
    await repo.markRead('c1');
    expect(server.requests.last.url.path, '/api/v1/chats/c1/messages/read');

    final room = await repo.room('g1');
    expect((room.isGroup, room.isSupervisor, room.onlySupervisorCanPost), (true, true, true));
    expect((await repo.room('c1')).isGroup, isFalse);

    final live = <String>[];
    final sub = repo.incoming('c1').listen((m) => live.add(m.id));
    await Future<void>.delayed(Duration.zero);
    hub.add([
      {'id': 'd3', 'conversationId': 'c1', 'senderId': 's9', 'body': 'تمام', 'sentAtUtc': '2026-10-21T09:02:00Z', 'isRead': false},
    ]);
    await Future<void>.delayed(Duration.zero);
    expect(live, contains('d3'));
    await sub.cancel();

    // الشركة: قراءة بس — بلا إرسال
    final reader = ServerChatRepository(groups: GroupApi(client), groupChat: GroupChatApi(client), direct: ChatApi(client), companyGroupId: 'g1');
    expect((await reader.room('g1')).readOnly, isTrue);
    expect(() => reader.send('g1', clientId: 'y', text: 'x'), throwsA(isA<ApiException>()));
  });

  test('company services from /home: missing = all on, a disabled one is off', () async {
    expect(CompanyServices.fromHome(_home()).chatWithGuides, isTrue);
    final off = CompanyServices.fromHome({..._home(), 'enabledServices': {'gpsTracking': false, 'duaAndRituals': true, 'instantNotifications': true, 'chatWithGuides': false, 'reportsAndStats': true}});
    expect((off.gpsTracking, off.chatWithGuides, off.duaAndRituals), (false, false, true));
    final api = GroupApi(FakeServer({'GET /home': (_) => {..._home(group: _group), 'enabledServices': {'chatWithGuides': false}}}).client());
    await api.myGroup();
    expect(CompanyServices.current.chatWithGuides, isFalse);
    CompanyServices.current = CompanyServices.all;
  });

  test('location sharing: PUT /location/sharing then POST /location with the position', () async {
    final server = FakeServer({
      'GET /location/me': (_) => {'isSharing': false, 'latitude': null, 'longitude': null, 'accuracyMeters': null, 'updatedAtUtc': null, 'isStale': true},
      'PUT /location/sharing': (r) => {'isSharing': (jsonDecode(r.body) as Map)['isSharing'], 'isStale': true},
      'POST /location': (_) => null,
    });
    final api = LocationApi(server.client());
    expect(await api.isSharing(), isFalse);
    await api.setSharing(true);
    await api.send(const GeoPoint(21.4225, 39.8262));
    expect(jsonDecode(server.requests[1].body), {'isSharing': true});
    expect(jsonDecode(server.requests[2].body), {'latitude': 21.4225, 'longitude': 39.8262});
  });

  test('403: the token is refreshed once and the request retried (roles come with the new token)', () async {
    var calls = 0;
    var refreshed = 0;
    final server = FakeServer({
      'GET /home': (_) => ++calls == 1 ? http.Response('{"title":"Forbidden","status":403}', 403) : _home(group: _group),
    });
    final group = await GroupApi(server.client(refresh: () async {
      refreshed++;
      return 'new';
    })).myGroup();
    expect(group?.id, 'g1');
    expect(refreshed, 1);
    expect(server.requests.last.headers['Authorization'], 'Bearer new');
    expect(const ApiException(403).isForbidden, isTrue);
    expect(const ApiException(403).isUnauthorized, isFalse);
  });

  test('user.roles from the login response; Supervisor or Admin opens the supervisor UI', () async {
    await AuthSession.saveFromResponse(jsonEncode({
      'accessToken': 'a',
      'refreshToken': 'r',
      'tokenType': 'Bearer',
      'expiresIn': 900,
      'user': {'id': 'u1', 'email': 'p@example.com', 'fullName': 'محمد', 'roles': ['Admin']},
    }));
    final user = await AuthSession.current();
    expect(user?.roles, ['Admin']);
    expect(user?.isSupervisor, isFalse); // من 20 أكتوبر: الـ Admin مش مشرف

    await AuthSession.saveFromResponse(jsonEncode({'user': {'id': 'u2', 'email': 'x@example.com', 'fullName': 'حاج', 'roles': []}}));
    expect((await AuthSession.current())?.isSupervisor, isFalse);
    await AuthSession.clear();
    expect(await AuthSession.current(), isNull);

    // الدور بالتوكن (ClaimTypes.Role): Admin لحاله → لوحة الويب بس، و Admin + Supervisor → واجهة المشرف
    String jwt(Map<String, Object> claims) {
      String part(Map<String, Object> m) => base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
      return '${part({'alg': 'HS256'})}.${part(claims)}.sig';
    }

    await TokenStorage.saveTokens(accessToken: jwt({'sub': 'u1', 'email': 'a@example.com', 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role': 'Admin'}), refreshToken: 'r');
    await AccountRegistry.signedIn('a@example.com');
    expect((await AccountRegistry.current())?.type, AccountType.superAdmin);
    await TokenStorage.saveTokens(accessToken: jwt({'sub': 'u3', 'email': 's@example.com', 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role': ['Admin', 'Supervisor']}), refreshToken: 'r');
    await AccountRegistry.signedIn('s@example.com');
    expect((await AccountRegistry.current())?.type, AccountType.groupSupervisor);
  });

  test('group preview: trip date and company name from GroupSummaryDto (older server: none)', () {
    final p = GroupPreview.fromJson({'id': 'g1', 'name': 'حملة النور', 'leaderName': ' ', 'memberCount': 4, 'tripDate': '2026-11-20', 'companyName': 'شركة النور'}, 'K7P2QX');
    expect((p.supervisor, p.tripDate, p.companyName), (null, DateTime(2026, 11, 20), 'شركة النور'));
    expect(GroupJoinText.tripDate(p.tripDate!), 'تاريخ الرحلة: 20 نوفمبر 2026');
    final old = GroupPreview.fromJson({'id': 'g1', 'name': 'x', 'memberCount': 1}, 'C');
    expect((old.tripDate, old.companyName), (null, null));
  });
}

/// hub وهمي: الأحداث من [stream]
class _FakeHub extends SignalRHub {
  _FakeHub(this.stream) : super(uri: Uri.parse('ws://fake'), accessToken: () async => null);

  final Stream<List<Object?>> stream;

  @override
  Stream<List<Object?>> on(String target) => stream;

  @override
  bool get isConnected => true;

}
