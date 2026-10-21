import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:labaik/core/l10n/app_language.dart';
import 'package:labaik/features/chats/data/sources/group_chat_api.dart';
import 'package:labaik/features/group/data/sources/group_api.dart';
import 'package:labaik/features/group/data/sources/group_realtime.dart';
import 'package:labaik/features/supervisor/data/models/notification_sections.dart';
import 'package:labaik/features/supervisor/data/repositories/supervisor_repository_impl.dart';
import 'package:labaik/features/supervisor/data/sources/announcements_api.dart';
import 'package:labaik/features/supervisor/data/sources/supervisor_api.dart';
import 'package:labaik/features/notifications/data/sources/notifications_api.dart';
import 'package:labaik/features/supervisor/domain/entities/announcement.dart';
import 'package:labaik/features/supervisor/domain/repositories/supervisor_repository.dart';
import 'package:labaik/features/supervisor/presentation/pages/trip_program_screen.dart';
import 'package:labaik/features/supervisor/domain/entities/group_member.dart';
import 'package:labaik/features/supervisor/domain/entities/trip_program.dart';
import 'package:labaik/features/supervisor/presentation/cubits/supervisor_content_cubits.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/fake_chat_repository.dart';
import 'group_backend_test.dart' show FakeServer;

// -------------------------------------------------------------
// واجهة المشرف من السيرفر: مجموعتي وأعضاؤها (بدون المشرف وبدوني)، الحضور مش بالسيرفر (0 و"الكل" بس)،
// الإعلانات (النوع والمرفق بيضلوا على الجهاز)، الإشعارات حسب النوع واليوم، وآخر رسالة بالدردشة
// -------------------------------------------------------------
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({'access_token': fakeJwt('lead')});
    AppLanguage.notifier.value = 'ar';
    GroupRealtime.reset();
  });

  FakeServer server() => FakeServer({
        'GET /home': (_) => {
              'group': {'id': 'g1', 'name': 'المجموعة الأولى', 'leaderName': 'المشرف', 'memberCount': 3, 'myRole': 1, 'unreadAnnouncements': 0},
              'unreadNotifications': 1,
            },
        'GET /groups/g1/locations': (_) => [
              {'userId': 'lead', 'fullName': 'المشرف', 'role': 1, 'isSharing': false, 'isStale': true},
              {'userId': 'u1', 'fullName': 'أحمد محمد', 'role': 2, 'isSharing': false, 'isStale': true},
              {'userId': 'u2', 'fullName': 'سهاد علي', 'role': 2, 'isSharing': true, 'latitude': 21.42, 'longitude': 39.82, 'updatedAtUtc': DateTime.now().toUtc().toIso8601String(), 'isStale': false},
            ],
        'GET /groups/g1/announcements': (_) => [
              {'id': 'a1', 'groupId': 'g1', 'title': 'تذكير بموعد التجمع', 'body': 'السطر الأول\nالسطر الثاني', 'authorId': 'lead', 'authorName': 'المشرف', 'createdAtUtc': DateTime.now().toUtc().toIso8601String(), 'isRead': true},
            ],
        'POST /groups/g1/announcements': (r) => http.Response(
              jsonEncode({...(jsonDecode(r.body) as Map<String, dynamic>), 'id': 'a2', 'groupId': 'g1', 'authorId': 'lead', 'createdAtUtc': DateTime.now().toUtc().toIso8601String(), 'isRead': true}),
              201,
              headers: {'content-type': 'application/json; charset=utf-8'},
            ),
        'GET /groups/g1/messages': (_) => [
              {'id': 'm1', 'groupId': 'g1', 'senderId': 'u1', 'senderName': 'أحمد محمد', 'body': 'التجمع عند البوابة المحددة', 'sentAtUtc': DateTime.now().toUtc().toIso8601String()},
            ],
        'GET /notifications': (_) => [
              {'id': 'n1', 'type': 2, 'groupId': 'g1', 'referenceId': 'u2', 'preview': 'سهاد علي', 'createdAtUtc': DateTime.now().toUtc().toIso8601String(), 'isRead': false},
              {'id': 'n2', 'type': 99, 'preview': 'نوع جديد', 'createdAtUtc': DateTime.now().toUtc().toIso8601String(), 'isRead': false},
              {'id': 'n3', 'type': 1, 'groupId': 'g1', 'preview': 'تعديل موعد الزيارة', 'createdAtUtc': DateTime.now().subtract(const Duration(days: 1)).toUtc().toIso8601String(), 'isRead': true},
            ],
        'POST /notifications/read-all': (_) => null,
      });

  SupervisorRepositoryImpl repository(FakeServer s) {
    final client = s.client();
    return SupervisorRepositoryImpl(groups: GroupApi(client), announcements: AnnouncementsApi(client), notifications: NotificationsApi(client), chat: GroupChatApi(client), supervisor: SupervisorApi(client));
  }

  test('group, members, chats and notifications from the server', () async {
    final s = server();
    final repo = repository(s);

    final groups = await repo.getGroups();
    expect(groups.single.name, 'المجموعة الأولى');
    expect(groups.single.totalPilgrims, 2);
    // الحضور مش بالسيرفر
    expect(groups.single.presentCount, 0);
    expect(groups.single.absentCount, 0);
    expect(groups.single.nextTripTitle, isEmpty);

    final members = GroupMembersCubit(repo, 'g1');
    await members.load();
    expect(members.state.items.map((m) => m.name), ['أحمد محمد', 'سهاد علي']);
    expect(members.state.visible(MembersTab.all), hasLength(2));
    expect(members.state.visible(MembersTab.present), isEmpty);
    expect(members.state.visible(MembersTab.absent), isEmpty);
    expect(members.state.items.first.number, isNull);
    await members.close();

    expect(await repo.getProgram('g1'), isEmpty);

    final chats = await repo.getChats();
    expect(chats.single.name, 'المجموعة الأولى');
    expect(chats.single.lastMessage, 'التجمع عند البوابة المحددة');

    final sections = await repo.getNotifications();
    expect(sections.first.label, 'اليوم');
    expect(sections.last.label, startsWith('الأمس '));
    expect(sections.first.items.map((n) => n.title), ['انضم سهاد علي إلى مجموعتك', 'إشعار جديد']);
    expect(sections.first.items.map((n) => n.body), ['المجموعة الأولى', 'نوع جديد']);
    expect(sections.last.items.single.title, 'إعلان جديد');
    expect(sections.last.items.single.body, 'تعديل موعد الزيارة');

    await repo.markNotificationsRead();
    expect(s.requests.last.url.path, '/api/v1/notifications/read-all');
  });

  test('announcements: list from the server, send posts {title, body}, the type stays on this device', () async {
    final s = server();
    final repo = repository(s);

    final list = await repo.getAnnouncements();
    expect(list.single.title, 'تذكير بموعد التجمع');
    expect(list.single.summary, 'السطر الأول');
    expect(list.single.target, 'المجموعة الأولى');
    expect(list.single.whenLabel, startsWith('اليوم، '));
    expect(list.single.type, AnnouncementType.normal);

    final saved = await repo.sendAnnouncement(const Announcement(
      id: 'new',
      title: 'تعديل موعد الزيارة',
      target: 'المجموعة الأولى',
      whenLabel: '',
      summary: '',
      body: 'تم تعديل الموعد',
      type: AnnouncementType.important,
      icon: AnnouncementIcon.group,
      dateLabel: '',
      timeLabel: '',
    ));
    expect(jsonDecode(s.requests.last.body), {'title': 'تعديل موعد الزيارة', 'body': 'تم تعديل الموعد', 'importance': 2});
    expect(saved.id, 'a2');
    expect(saved.type, AnnouncementType.important);

    // بعد التحميل من جديد: نفس الإعلان من السيرفر، ونوعه "مهم" من الجهاز
    final again = repository(FakeServer({
      ...server().routes,
      'GET /groups/g1/announcements': (_) => [
            {'id': 'a2', 'groupId': 'g1', 'title': 'تعديل موعد الزيارة', 'body': 'تم تعديل الموعد', 'authorId': 'lead', 'createdAtUtc': DateTime.now().toUtc().toIso8601String(), 'isRead': true},
          ],
    }));
    expect((await again.getAnnouncements()).single.type, AnnouncementType.important);
  });

  test('new server: groups with attendance + next activity from the itinerary, members with number, member card, program', () async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    String day(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final s = FakeServer({
      ...server().routes,
      'GET /supervisor/groups': (_) => [
            {'id': 'g1', 'name': 'المجموعة الأولى', 'tripId': 't1', 'tripName': 'عمرة ديسمبر', 'departureDate': day(tomorrow), 'pilgrimCount': 25, 'presentCount': 22, 'absentCount': 3},
          ],
      'GET /trips/t1/itinerary': (_) => {
            'tripId': 't1',
            'tripName': 'عمرة ديسمبر',
            'days': [
              {
                'date': day(tomorrow),
                'title': 'اليوم الأول',
                'activities': [
                  {'title': 'الاستعداد للعمرة', 'timeUtc': DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 6).toUtc().toIso8601String(), 'place': 'نقطة التجمع'},
                  {'title': 'الطواف', 'timeUtc': DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9).toUtc().toIso8601String(), 'place': 'الحرم'},
                ],
              },
            ],
          },
      'GET /groups/g1/members': (_) => [
            {'userId': 'lead', 'fullName': 'المشرف', 'role': 1, 'attendanceStatus': 2},
            {'userId': 'u1', 'fullName': 'رولا عبدالله', 'email': 'r@x.com', 'role': 2, 'memberNumberInGroup': 15, 'gender': 2, 'nationality': 'فلسطينية', 'attendanceStatus': 1},
          ],
      'GET /groups/g1/members/u1': (_) => {'userId': 'u1', 'fullName': 'رولا عبدالله', 'role': 2, 'memberNumberInGroup': 15, 'gender': 2, 'healthNotes': 'في حالة جيدة', 'attendanceStatus': 1},
    });
    final repo = repository(s);
    final g = (await repo.getGroups()).single;
    expect([g.totalPilgrims, g.presentCount, g.absentCount], [25, 22, 3]);
    expect(g.nextTripTitle, 'الاستعداد للعمرة');
    expect(g.nextTripDetails, '06:00 صباحًا : نقطة التجمع');
    final members = await repo.getMembers('g1');
    expect(members.single.name, 'رولا عبدالله');
    expect(members.single.number, 15);
    expect(members.single.present, isTrue);
    expect(members.single.gender, MemberGender.female);
    expect((await repo.getMember('g1', members.single)).health, 'في حالة جيدة');
    final program = await repo.getProgram('g1');
    expect(program.single.activities.map((a) => (a.title, a.kind)), [('الاستعداد للعمرة', ActivityPlace.hotel), ('الطواف', ActivityPlace.haram)]);
  });

  testWidgets('trip program: empty → message + "إضافة نشاط" → the activity is saved with PUT and shows up', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    Map<String, dynamic> itinerary = {'tripId': 't1', 'tripName': 'عمرة', 'days': <Object>[]};
    final s = FakeServer({
      'GET /supervisor/groups': (_) => [
            {'id': 'g1', 'name': '111', 'tripId': 't1', 'tripName': 'عمرة', 'pilgrimCount': 0, 'presentCount': 0, 'absentCount': 0},
          ],
      'GET /home': (_) => {'group': null},
      'GET /trips/t1/itinerary': (_) => itinerary,
      'PUT /trips/t1/itinerary': (r) => itinerary = {'tripId': 't1', 'tripName': 'عمرة', 'days': (jsonDecode(r.body) as Map<String, dynamic>)['days']},
    });
    final repo = repository(s);
    final group = (await repo.getGroups()).single;
    await tester.pumpWidget(RepositoryProvider<SupervisorRepository>.value(
      value: repo,
      child: MaterialApp(
        builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
        home: TripProgramScreen(group: group),
      ),
    ));
    await tester.pumpAndSettle();
    Finder text(String v) => find.text(v, findRichText: true);
    expect(text('لا يوجد برنامج للرحلة بعد'), findsOneWidget);
    await tester.tap(text('+ إضافة نشاط'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'إضافة'));
    await tester.pumpAndSettle();
    expect(text('اكتب اسم النشاط'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'الاستعداد للعمرة');
    await tester.enterText(find.byType(TextField).last, 'نقطة التجمع');
    await tester.tap(find.widgetWithText(FilledButton, 'إضافة'));
    await tester.pumpAndSettle();
    final put = jsonDecode(s.requests.lastWhere((r) => r.method == 'PUT').body) as Map<String, dynamic>;
    final day = (put['days'] as List).single as Map<String, dynamic>;
    expect(((day['activities'] as List).single as Map)['title'], 'الاستعداد للعمرة');
    expect(((day['activities'] as List).single as Map)['place'], 'نقطة التجمع');
    expect(text('لا يوجد برنامج للرحلة بعد'), findsNothing);
    expect(text('الاستعداد للعمرة'), findsOneWidget);
  });

  test('supervisor adds a pilgrim by email (trimmed, empty fields left out) and removes one; the cubit reloads / drops the row', () async {
    final members = [
      {'userId': 'lead', 'fullName': 'المشرف', 'role': 1},
      {'userId': 'u1', 'fullName': 'أحمد محمد', 'role': 2, 'memberNumber': 1},
    ];
    final s = FakeServer({
      'GET /groups/g1/members': (_) => members,
      'POST /groups/g1/members': (r) {
        final body = jsonDecode(r.body) as Map<String, dynamic>;
        members.add({'userId': 'u2', 'fullName': body['fullName'] ?? body['email'], 'role': 2, 'memberNumber': 2});
        return {'id': 'g1', 'name': 'المجموعة الأولى', 'pilgrimCount': 2};
      },
      'DELETE /groups/g1/members/u1': (_) => null,
    });
    final cubit = GroupMembersCubit(repository(s), 'g1');
    await cubit.load();
    expect(cubit.state.items.map((m) => m.name), ['أحمد محمد']);
    await cubit.add(email: ' new@x.com ', fullName: 'سارة', phone: '  ');
    expect(jsonDecode(s.requests.firstWhere((r) => r.method == 'POST').body), {'email': 'new@x.com', 'fullName': 'سارة'});
    expect(cubit.state.items.map((m) => m.name), ['أحمد محمد', 'سارة']);
    await cubit.remove(cubit.state.items.first);
    expect(s.requests.any((r) => r.method == 'DELETE' && r.url.path.endsWith('/groups/g1/members/u1')), isTrue);
    expect(cubit.state.items.map((m) => m.name), ['سارة']);
    await cubit.close();
  });

  test('notification sections: every type is shown (unknown → generic), older days use the date', () {
    final now = DateTime(2026, 10, 16, 12);
    final at = DateTime(2026, 10, 12, 9).toUtc().toIso8601String();
    final sections = NotificationSections.fromJson([
      {'id': 'n1', 'type': 1, 'preview': 'تذكير', 'createdAtUtc': at},
      {'id': 'n2', 'type': 10, 'groupId': 'g1', 'preview': 'أحمد', 'createdAtUtc': at},
      {'id': 'n3', 'type': 16, 'preview': 'شركة النور', 'createdAtUtc': at},
      {'id': 'n4', 'type': 99, 'preview': 'جديد', 'createdAtUtc': at},
    ], groupId: 'g1', groupName: 'طول بالك', now: now);
    expect(sections.single.label, '12 أكتوبر 2026');
    final items = sections.single.items;
    expect(items.map((n) => n.body), ['تذكير', 'طول بالك', 'شركة النور', 'جديد']);
    expect(items[1].title, 'بلاغ طوارئ من أحمد');
    expect(items[1].important, isTrue);
    expect(items[2].title, 'تم إيقاف حسابك كمشرف');
    expect(items[3].title, 'إشعار جديد');
  });
}
