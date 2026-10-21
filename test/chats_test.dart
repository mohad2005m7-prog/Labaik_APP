import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labaik/core/l10n/app_language.dart';
import 'package:labaik/core/network/api_client.dart';
import 'package:labaik/core/utils/geo_utils.dart';
import 'package:labaik/features/auth/data/account_registry.dart';
import 'package:labaik/features/chats/data/sources/chat_api.dart';
import 'package:labaik/features/chats/domain/entities/chat_message.dart';
import 'package:labaik/features/chats/domain/entities/chat_room.dart';
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
// الدردشات: طلبات السيرفر الفردية (/chats: القائمة، البدء، الرسائل، الإرسال، القراءة)،
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

  test('direct chat API (/chats): conversations, start, history oldest-first, send {body}, read', () async {
    final requests = <http.Request>[];
    const json = {'content-type': 'application/json; charset=utf-8'};
    final client = MockClient((request) async {
      requests.add(request);
      final path = request.url.path.replaceFirst('/api/v1', '');
      final key = '${request.method} $path';
      switch (key) {
        case 'GET /chats':
          return http.Response(jsonEncode([
            {'id': 'c1', 'otherUserId': '7', 'otherName': 'أحمد محمد', 'otherPhotoUrl': null, 'lastMessage': 'وين انت؟', 'lastMessageAtUtc': '2026-10-21T10:01:00Z', 'unreadCount': 2},
          ]), 200, headers: json);
        case 'POST /chats/direct':
          return http.Response(jsonEncode({'id': 'c1', 'otherUserId': '7', 'otherName': 'أحمد محمد', 'unreadCount': 0}), 200, headers: json);
        case 'GET /chats/c1/messages':
          return http.Response(jsonEncode([
            {'id': 'm2', 'conversationId': 'c1', 'senderId': '7', 'senderName': 'أحمد محمد', 'body': 'وين انت؟', 'sentAtUtc': '2026-10-21T10:01:00Z', 'isRead': false},
            {'id': 'm1', 'conversationId': 'c1', 'senderId': 'u1', 'senderName': 'محمد', 'body': 'مرحبا', 'sentAtUtc': '2026-10-21T10:00:00Z', 'isRead': true},
          ]), 200, headers: json);
        case 'POST /chats/c1/messages':
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(jsonEncode({'id': 'm3', 'conversationId': 'c1', 'senderId': 'u1', 'body': body['body'], 'sentAtUtc': '2026-10-21T10:02:00Z', 'isRead': false}), 201, headers: json);
        case 'POST /chats/c1/messages/read':
          return http.Response('', 204);
      }
      return http.Response('', 404);
    });
    final api = ChatApi(ApiClient(baseUrl: 'https://api.test/api/v1', accessToken: () async => 'tok', refreshToken: () async => null, client: client));

    final list = await api.conversations();
    expect((list.single.title, list.single.otherUserId, list.single.unreadCount, list.single.lastMessage?.text), ('أحمد محمد', '7', 2, 'وين انت؟'));
    expect((await api.start('7')).id, 'c1');
    expect(jsonDecode(requests.last.body), {'userId': '7'});

    final messages = await api.messages('c1');
    expect(requests.last.url.queryParameters['take'], '50');
    expect(messages.map((m) => (m.id, m.fromMe)), [('m1', true), ('m2', false)]);
    expect(messages.last.senderId, '7');

    final saved = await api.send('c1', 'أنا عند الباب');
    expect(jsonDecode(requests.last.body), {'body': 'أنا عند الباب'});
    expect((saved.id, saved.fromMe), ('m3', true));

    await api.markRead('c1');
    expect(requests.last.url.path, '/api/v1/chats/c1/messages/read');
    expect(requests.every((r) => r.headers['Authorization'] == 'Bearer tok'), isTrue);
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

  test('group chat permissions: supervisor deletes any message and mutes the sender; live deletions disappear; lock', () async {
    final now = DateTime.now();
    final repo = FakeChat()
      ..roomValue = const ChatRoom(isGroup: true, isSupervisor: true)
      ..server = [
        ChatMessage(id: 'm1', clientId: 'm1', conversationId: 'g1', fromMe: false, senderId: 'p1', senderName: 'أحمد', text: 'السلام عليكم', sentAt: now),
        ChatMessage(id: 'm2', clientId: 'm2', conversationId: 'g1', fromMe: true, text: 'وعليكم السلام', sentAt: now.add(const Duration(seconds: 1))),
      ];
    final cubit = ConversationCubit(repo, 'g1', pollInterval: const Duration(hours: 1));
    await cubit.start();
    await Future<void>.delayed(Duration.zero);
    final first = cubit.state.messages.first;
    expect((cubit.state.canDelete(first), cubit.state.canMute(first)), (true, true));
    expect(cubit.state.canMute(cubit.state.messages.last), isFalse); // رسالتي
    await cubit.mute(first, minutes: 60);
    expect(repo.mutes, [('p1', 60)]);
    await cubit.delete(first);
    expect(repo.deletedIds, ['m1']);
    expect(cubit.state.messages.map((m) => m.id), ['m2']);
    repo.deletions.add('m2'); // حذفها حدا تاني (SignalR)
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.messages, isEmpty);
    await cubit.setOnlySupervisorCanPost(true);
    expect(repo.locks, [true]);
    expect((cubit.state.room.onlySupervisorCanPost, cubit.state.room.canPost), (true, true)); // المشرف بضل يكتب
    await cubit.close();
  });

  test('chat room: who can post (read-only company, muted pilgrim, supervisor-only group, direct)', () {
    expect(const ChatRoom(isGroup: true, readOnly: true).canPost, isFalse);
    expect(ChatRoom(isGroup: true, mutedUntil: DateTime.now().add(const Duration(hours: 1))).canPost, isFalse);
    expect(ChatRoom(isGroup: true, mutedUntil: DateTime.now().subtract(const Duration(minutes: 1))).canPost, isTrue);
    expect(const ChatRoom(isGroup: true, onlySupervisorCanPost: true).canPost, isFalse);
    expect(const ChatRoom(isGroup: true, onlySupervisorCanPost: true, isSupervisor: true).canPost, isTrue);
    expect(ChatRoom.direct.canPost, isTrue);
    // الفردية ما فيها حذف ولا كتم
    final m = ChatMessage(id: 'x', clientId: 'x', fromMe: true, sentAt: DateTime.now());
    expect(const ConversationState().canDelete(m), isFalse);
  });

  testWidgets('read-only and supervisor-only rooms replace the input with a note', (tester) async {
    Future<void> pump(ChatRoom room) async {
      final repo = FakeChat()..roomValue = room;
      await tester.pumpWidget(MaterialApp(
        home: BlocProvider(key: ValueKey(room), create: (_) => ConversationCubit(repo, 'g1', pollInterval: const Duration(hours: 1))..start(), child: const ConversationScreen(title: 'حملة النور', isGroup: true)),
      ));
      await tester.pumpAndSettle();
    }

    await pump(const ChatRoom(isGroup: true, readOnly: true));
    expect(find.text('قراءة فقط: دردشة المجموعة بين المشرف والمعتمرين'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await pump(const ChatRoom(isGroup: true, onlySupervisorCanPost: true));
    expect(find.text('الكتابة في هذه المجموعة للمشرف فقط'), findsOneWidget);
    await pump(const ChatRoom(isGroup: true, isSupervisor: true));
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.lock_open_rounded), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
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
