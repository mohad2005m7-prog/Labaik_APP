import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labaik/core/l10n/app_language.dart';
import 'package:labaik/core/network/api_client.dart';
import 'package:labaik/core/utils/geo_utils.dart';
import 'package:labaik/features/auth/data/account_registry.dart';
import 'package:labaik/features/chats/data/sources/chat_api.dart';
import 'package:labaik/features/chats/data/sources/chat_hub.dart';
import 'package:labaik/features/chats/domain/entities/chat_message.dart';
import 'package:labaik/features/chats/domain/entities/conversation_summary.dart';
import 'package:labaik/features/chats/presentation/controllers/chats_controller.dart';
import 'package:labaik/features/chats/presentation/cubits/chats_list_cubit.dart';
import 'package:labaik/features/chats/presentation/cubits/conversation_cubit.dart';
import 'package:labaik/features/chats/presentation/pages/chats_list_screen.dart';
import 'package:labaik/features/chats/presentation/pages/conversation_screen.dart';
import 'package:labaik/features/chats/presentation/widgets/chat_bubble.dart';
import 'package:labaik/features/chats/presentation/widgets/chat_list_time.dart';
import 'package:labaik/features/help_center/presentation/pages/help_center_screen.dart';
import 'package:labaik/features/pilgrim_tabs/presentation/controllers/pilgrim_tabs_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_chat_repository.dart';

// -------------------------------------------------------------
// الدردشات: طلبات السيرفر (القائمة، الرسائل، الإرسال، القراءة)، الاتصال اللحظي (SignalR) مع سيرفر WebSocket محلي،
// المحادثة (إرسال فوري، بدون تكرار، إعادة المحاولة)، القائمة (المثبّتة فوق، البحث، غير المقروء)،
// والتنقل: شريط التنقل → الدردشات → المحادثة → مركز المساعدة → الدردشات → الرئيسية
// -------------------------------------------------------------
ChatMessage message(String id, String text, DateTime at, {bool me = false, String conversation = 'c1'}) =>
    ChatMessage(id: id, clientId: id, conversationId: conversation, fromMe: me, text: text, sentAt: at);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({'access_token': fakeJwt('u1')});
    AppLanguage.notifier.value = 'ar';
  });

  test('server API: conversations, messages (isMine from the JWT), send, read', () async {
    final requests = <http.Request>[];
    const json = {'content-type': 'application/json; charset=utf-8'};
    final client = MockClient((request) async {
      requests.add(request);
      final path = request.url.path;
      if (path.endsWith('/chats') && request.method == 'GET') {
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 'c1',
                'title': 'أحمد محمد',
                'isPinned': true,
                'unreadCount': 2,
                'lastMessage': {'id': 'm5', 'conversationId': 'c1', 'senderId': '7', 'text': 'التجمع عند البوابة المحددة', 'sentAt': '2026-10-15T09:12:00Z'},
              },
              {'Id': 'g1', 'Title': 'مجموعة حملة النور', 'IsGroup': true},
            ],
          }),
          200,
          headers: json,
        );
      }
      if (path.endsWith('/chats/c1/messages') && request.method == 'GET') {
        return http.Response(
          jsonEncode([
            {'id': 'm1', 'senderId': 'u1', 'text': 'مرحبا', 'sentAt': '2026-10-15T10:00:00Z'},
            {'id': 'm2', 'senderId': '7', 'senderName': 'أحمد محمد', 'latitude': 21.42, 'longitude': 39.82, 'sentAt': '2026-10-15T10:01:00Z'},
          ]),
          200,
          headers: json,
        );
      }
      if (path.endsWith('/chats/c1/messages') && request.method == 'POST') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(jsonEncode({'id': 'm3', 'clientId': body['clientId'], 'text': body['text'], 'sentAt': '2026-10-15T10:02:00Z'}), 201, headers: json);
      }
      if (path.endsWith('/chats/c1/read')) return http.Response('', 204);
      return http.Response('', 404);
    });
    final api = ChatApi(ApiClient(baseUrl: 'https://api.test/api/v1', accessToken: () async => 'tok', refreshToken: () async => null, client: client));

    final list = await api.conversations();
    expect(list.map((c) => c.title), ['أحمد محمد', 'مجموعة حملة النور']);
    expect(list.first.isPinned, isTrue);
    expect(list.first.unreadCount, 2);
    expect(list.first.lastMessage?.fromMe, isFalse);
    expect(list.last.isGroup, isTrue);

    final messages = await api.messages('c1', afterId: 'm0');
    expect(requests.last.url.queryParameters['afterId'], 'm0');
    expect(messages.map((m) => m.fromMe), [true, false]);
    expect(messages[1].senderName, 'أحمد محمد');
    expect(messages[1].location?.latitude, 21.42);

    final saved = await api.send('c1', clientId: 'local-1', text: 'أنا عند الباب');
    expect(saved.id, 'm3');
    expect(saved.clientId, 'local-1');
    expect(saved.fromMe, isTrue);
    expect(jsonDecode(requests.last.body), {'clientId': 'local-1', 'text': 'أنا عند الباب', 'latitude': null, 'longitude': null});

    await api.markRead('c1');
    expect(requests.last.method, 'POST');
    expect(requests.last.url.path, '/api/v1/chats/c1/read');
    expect(requests.every((r) => r.headers['Authorization'] == 'Bearer tok'), isTrue);
  });

  test('SignalR hub: Bearer token, JSON handshake, ReceiveMessage and ping over a real WebSocket', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    String? auth;
    var pings = 0;
    server.listen((request) async {
      auth = request.headers.value('authorization');
      final socket = await WebSocketTransformer.upgrade(request);
      socket.listen((data) {
        for (final record in (data as String).split('\u001e').where((r) => r.isNotEmpty)) {
          final json = jsonDecode(record) as Map<String, dynamic>;
          if (json['protocol'] == 'json') {
            // رد الـ handshake ورسالة بنفس الإطار
            socket.add('{}\u001e{"type":1,"target":"ReceiveMessage","arguments":[{"id":"m9","conversationId":"c1","text":"وصلت؟","isMine":false,"sentAt":"2026-10-15T10:00:00Z"}]}\u001e');
          } else if (json['type'] == 6) {
            pings++;
          }
        }
      });
    });
    final hub = ChatHub(uri: Uri.parse('ws://127.0.0.1:${server.port}/hubs/chat'), accessToken: () async => 'tok', pingInterval: const Duration(milliseconds: 50));
    hub.start();
    final received = await hub.messages.first.timeout(const Duration(seconds: 5));
    expect(received['text'], 'وصلت؟');
    expect(auth, 'Bearer tok');
    expect(hub.isConnected, isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(pings, greaterThan(0));
    await hub.dispose();
    await server.close(force: true);
  });

  test('conversation: my message shows at once, the server copy replaces it (no duplicates), a failed one can be retried, read is sent', () async {
    final repo = FakeChat();
    final cubit = ConversationCubit(repo, 'c1', pollInterval: const Duration(hours: 1));
    await cubit.start();
    expect(repo.read, ['c1']);

    final sending = cubit.sendText('أنا تائه');
    expect(cubit.state.messages.single.status, ChatMessageStatus.sending);
    await sending;
    expect(cubit.state.messages.single.id, 's1');
    expect(cubit.state.messages.single.status, ChatMessageStatus.sent);

    // نفس الرسالة رجعت عن طريق SignalR → ما بتتكرر — ورسالة الطرف التاني بتنضاف وبتتعلّم مقروءة
    repo.live.add(cubit.state.messages.single);
    repo.live.add(message('m2', 'وين انت؟', DateTime.now().add(const Duration(seconds: 1))));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.messages.map((m) => m.text), ['أنا تائه', 'وين انت؟']);
    expect(repo.read, ['c1', 'c1']);

    repo.failSend = true;
    await cubit.sendLocation(const GeoPoint(21.42, 39.82));
    final failed = cubit.state.messages.firstWhere((m) => m.isLocation);
    expect(failed.status, ChatMessageStatus.failed);
    repo.failSend = false;
    await cubit.retry(failed);
    expect(cubit.state.messages.where((m) => m.isLocation).single.status, ChatMessageStatus.sent);
    expect(cubit.state.messages, hasLength(3));
    expect(repo.sent.last.clientId, failed.clientId);
    expect(repo.sent.last.location?.longitude, 39.82);
    await cubit.close();
  });

  test('chats list: pinned first then newest, search, live message updates the row and unread count', () async {
    final now = DateTime.now();
    final repo = FakeChat()
      ..list = [
        ConversationSummary(id: 'm1', title: 'محمد خالد', lastMessage: message('a', 'الله يتقبل منكم', now)),
        ConversationSummary(id: 'c1', title: 'أحمد محمد', isPinned: true, unreadCount: 2, lastMessage: message('b', 'التجمع عند البوابة المحددة', now.subtract(const Duration(hours: 1)))),
        ConversationSummary(id: 's1', title: 'سارة علي', lastMessage: message('c', 'تمام، بشوفكم هناك', now.subtract(const Duration(minutes: 5)))),
      ];
    final cubit = ChatsListCubit(repo, pollInterval: const Duration(hours: 1));
    await cubit.start();
    expect(cubit.state.visible.map((c) => c.id), ['c1', 'm1', 's1']);

    cubit.search('سارة');
    expect(cubit.state.visible.single.id, 's1');
    cubit.search('البوابة');
    expect(cubit.state.visible.single.id, 'c1');
    cubit.search('');

    repo.live.add(message('d', 'وصلنا', now.add(const Duration(minutes: 1)), conversation: 's1'));
    await Future<void>.delayed(Duration.zero);
    final sara = cubit.state.all.firstWhere((c) => c.id == 's1');
    expect(sara.lastMessage?.text, 'وصلنا');
    expect(sara.unreadCount, 1);
    expect(cubit.state.visible.map((c) => c.id), ['c1', 's1', 'm1']);

    cubit.opened('s1');
    expect(cubit.state.all.firstWhere((c) => c.id == 's1').unreadCount, 0);
    await cubit.close();
  });

  test('list time like iOS and Figma ("9:12 AM", Yesterday, weekday, date)', () {
    final now = DateTime(2026, 10, 15, 22, 0);
    expect(ChatListTime.format(DateTime(2026, 10, 15, 9, 12), now: now), '9:12 AM');
    expect(ChatListTime.format(DateTime(2026, 10, 15, 21, 41), now: now), '9:41 PM');
    expect(ChatListTime.format(DateTime(2026, 10, 14, 9, 41), now: now), 'Yesterday');
    expect(ChatListTime.format(DateTime(2026, 10, 12, 9, 41), now: now), 'Monday');
    expect(ChatListTime.format(DateTime(2026, 9, 1, 9, 41), now: now), '1/9/26');
  });

  testWidgets('tab bar → chats → conversation (send) → help center → chats → home', (tester) async {
    await AccountRegistry.signedIn('p@example.com');
    final now = DateTime.now();
    final repo = FakeChat()
      ..list = [
        ConversationSummary(id: 'c1', title: 'أحمد محمد', isPinned: true, unreadCount: 2, lastMessage: message('b', 'التجمع عند البوابة المحددة', now)),
        ConversationSummary(id: 's1', title: 'سارة علي', lastMessage: message('c', 'تمام، بشوفكم هناك', now)),
      ]
      ..server = [message('m1', 'عند البوابة المحددة من المشرف.', now, conversation: 's1')];
    ChatsController.groupChats = () => repo;
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    tester.view.viewPadding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(onPressed: () => PilgrimTabsController.open(context, PilgrimTab.chats), child: const Text('home')),
          ),
        ),
      ),
    );
    Future<void> tap(String text) async {
      await tester.tap(find.text(text).last, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    await tap('home');
    expect(find.byType(ChatsListScreen), findsOneWidget);
    expect(find.text('أحمد محمد'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    // صف سارة → المحادثة الفردية: رسالة الطرف التاني + إرسال
    await tap('سارة علي');
    expect(find.byType(ConversationScreen), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is ChatBubble && !w.fromMe && w.text == 'عند البوابة المحددة من المشرف.'), findsOneWidget);
    expect(repo.read, contains('s1'));
    await tester.enterText(find.byType(TextField), 'مرحبا، وين نقطة التجمع؟');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    expect(repo.sent.single.conversationId, 's1');
    expect(find.byWidgetPredicate((w) => w is ChatBubble && w.fromMe && w.text == 'مرحبا، وين نقطة التجمع؟'), findsOneWidget);
    Navigator.of(tester.element(find.byType(ConversationScreen))).pop();
    await tester.pumpAndSettle();

    // تبديل التبويبات: مركز المساعدة ↔ الدردشات — والرئيسية
    await tap('مركز المساعدة');
    expect(find.byType(HelpCenterScreen), findsOneWidget);
    expect(find.byType(ChatsListScreen), findsNothing);
    await tap('الدردشات');
    expect(find.byType(ChatsListScreen), findsOneWidget);
    expect(find.byType(HelpCenterScreen), findsNothing);
    await tap('الرئيسية');
    expect(find.text('home'), findsOneWidget);
    expect(find.byType(ChatsListScreen), findsNothing);
  });
}
