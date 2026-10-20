import 'dart:convert';

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
    expect(sections.first.items.single.title, 'انضم سهاد علي إلى مجموعتك');
    expect(sections.first.items.single.body, 'المجموعة الأولى');
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

  test('notification sections: unknown types are ignored, older days use the date', () {
    final now = DateTime(2026, 10, 16, 12);
    final sections = NotificationSections.fromJson([
      {'id': 'n1', 'type': 1, 'preview': 'تذكير', 'createdAtUtc': DateTime(2026, 10, 12, 9).toUtc().toIso8601String()},
      {'id': 'n2', 'type': 7, 'preview': 'x', 'createdAtUtc': DateTime(2026, 10, 12, 9).toUtc().toIso8601String()},
    ], now: now);
    expect(sections.single.label, '12 أكتوبر 2026');
    expect(sections.single.items.single.body, 'تذكير');
  });
}
