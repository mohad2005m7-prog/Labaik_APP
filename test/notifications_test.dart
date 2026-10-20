import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labaik/core/l10n/app_language.dart';
import 'package:labaik/features/notifications/data/models/app_notification_json.dart';
import 'package:labaik/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:labaik/features/notifications/data/sources/notifications_api.dart';
import 'package:labaik/features/notifications/domain/entities/app_notification.dart';
import 'package:labaik/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:labaik/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:labaik/features/notifications/presentation/cubits/notifications_cubit.dart';
import 'package:labaik/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:labaik/features/notifications/presentation/widgets/notification_day_label.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'group_backend_test.dart' show FakeServer;

// -------------------------------------------------------------
// إشعارات المعتمر (جرس الرئيسية → Figma 114:10192): من GET /notifications، كلها بتصير مقروءة لما تنفتح،
// والجديد بيوصل لحظياً — بالشاشة إشعارات الإعلانات بس ("إعلان جديد للمجموعة") مقسومة حسب اليوم
// -------------------------------------------------------------
class FakeNotifications implements NotificationsRepository {
  List<AppNotification> items = [];
  int readAll = 0;
  final live = StreamController<void>.broadcast();

  @override
  Future<List<AppNotification>> list() async => items;

  @override
  Future<void> markAllRead() async => readAll++;

  @override
  Stream<void> changes() => live.stream;
}

AppNotification _n(String id, DateTime at, {NotificationKind kind = NotificationKind.announcement, bool read = false}) =>
    AppNotification(id: id, kind: kind, createdAt: at, preview: 'تذكير بموعد التجمع', isRead: read);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLanguage.notifier.value = 'ar';
  });

  test('NotificationDto: type 1/2 by number, unknown types ignored', () async {
    final server = FakeServer({
      'GET /notifications': (_) => [
            {'id': 'n1', 'type': 1, 'groupId': 'g1', 'referenceId': 'a1', 'preview': 'تذكير بموعد التجمع', 'createdAtUtc': '2026-10-16T09:40:00Z', 'isRead': false},
            {'id': 'n2', 'type': 2, 'groupId': 'g1', 'referenceId': 'u1', 'preview': 'سهاد علي', 'createdAtUtc': '2026-10-16T09:00:00Z', 'isRead': true},
            {'id': 'n3', 'type': 9, 'preview': 'نوع جديد', 'createdAtUtc': '2026-10-16T08:00:00Z', 'isRead': false},
          ],
      'POST /notifications/read-all': (_) => null,
    });
    final repo = NotificationsRepositoryImpl(api: NotificationsApi(server.client()));
    final items = await repo.list();
    expect(items.map((n) => n.kind), [NotificationKind.announcement, NotificationKind.memberJoined]);
    expect(items.first.referenceId, 'a1');
    expect(items.first.createdAt, DateTime.utc(2026, 10, 16, 9, 40).toLocal());
    expect(items.first.isRead, isFalse);
    await repo.markAllRead();
    expect(server.requests.last.url.path, '/api/v1/notifications/read-all');
    expect(AppNotificationJson.fromJson({'id': 'x', 'type': 3}), isNull);
  });

  test('cubit: loads, marks all read only when something is unread, reloads on a live notification', () async {
    final repo = FakeNotifications()..items = [_n('1', DateTime.now(), read: true), _n('2', DateTime.now(), kind: NotificationKind.memberJoined)];
    final cubit = NotificationsCubit(repo);
    await cubit.start();
    expect(cubit.state.loading, isFalse);
    // "انضم عضو" للمشرف بس
    expect(cubit.state.visible.map((n) => n.id), ['1']);
    expect(repo.readAll, 1);

    repo.items = [_n('3', DateTime.now()), ...repo.items];
    repo.live.add(null);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.visible.map((n) => n.id), ['3', '1']);
    expect(repo.readAll, 2);

    repo.items = [_n('1', DateTime.now(), read: true)];
    await cubit.refresh();
    expect(repo.readAll, 2);
    await cubit.close();
  });

  test('day labels: «اليوم», «الأمس 9:40» (Figma), older days by date', () {
    final now = DateTime(2026, 10, 17, 12);
    expect(NotificationDayLabel.of(DateTime(2026, 10, 17, 8), now: now), 'اليوم');
    expect(NotificationDayLabel.of(DateTime(2026, 10, 16, 21, 40), now: now), 'الأمس 9:40');
    expect(NotificationDayLabel.of(DateTime(2026, 10, 12, 9), now: now), '12 أكتوبر 2026');
  });

  testWidgets('bell → notifications: cards grouped by day, tap → قريباً, empty state', (tester) async {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)).add(const Duration(hours: 9, minutes: 40));
    final repo = FakeNotifications()..items = [_n('1', now), _n('2', now), _n('3', yesterday)];
    NotificationsController.repository = () => repo;
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    tester.view.viewPadding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
        home: Builder(builder: (context) => Scaffold(body: TextButton(onPressed: () => NotificationsController.open(context), child: const Text('bell')))),
      ),
    );
    await tester.tap(find.text('bell'));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(find.text('الإشعارات'), findsOneWidget);
    expect(find.text('اليوم'), findsOneWidget);
    expect(find.text('الأمس 9:40'), findsOneWidget);
    expect(find.text('إعلان جديد للمجموعة'), findsNWidgets(3));
    expect(find.text('أضاف المشرف إعلانًا جديدًا يخص أفراد المجموعة.'), findsNWidgets(3));
    expect(repo.readAll, 1);

    // تفاصيل الإعلان (372:7642) لسا ما انبنت
    await tester.tap(find.text('إعلان جديد للمجموعة').first, warnIfMissed: false);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);

    // ما في إشعارات
    repo.items = [];
    await tester.element(find.byType(NotificationsScreen)).read<NotificationsCubit>().refresh();
    await tester.pumpAndSettle();
    expect(find.text('لا توجد إشعارات بعد'), findsOneWidget);
  });
}
