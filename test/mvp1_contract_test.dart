import 'package:flutter_test/flutter_test.dart';
import 'package:labaik/features/auth/data/auth_session.dart';
import 'package:labaik/features/group/data/models/home_group.dart';
import 'package:labaik/features/group/domain/entities/group_preview.dart';

void main() {
  test('user.roles من رد الدخول: فاضية = حاج، Supervisor = مشرف، Admin لحاله = لوحة الويب (من 20 أكتوبر)', () {
    final pilgrim = AuthUser.fromJson({'id': 'u1', 'email': 'a@b.c', 'fullName': 'حاج', 'roles': <String>[]})!;
    final supervisor = AuthUser.fromJson({'id': 'u2', 'email': 'a@b.c', 'fullName': 'مشرف', 'roles': ['Supervisor']})!;
    final admin = AuthUser.fromJson({'id': 'u3', 'email': 'a@b.c', 'fullName': 'مسؤول', 'roles': ['Admin']})!;
    final company = AuthUser.fromJson({'id': 'u4', 'email': 'a@b.c', 'fullName': 'شركة', 'roles': ['Company']})!;

    expect(pilgrim.isSupervisor, isFalse);
    expect(supervisor.isSupervisor, isTrue);
    expect(admin.isSupervisor, isFalse);
    expect(company.isSupervisor, isFalse);
    expect(company.roles, ['Company']);
  });

  test('معاينة المجموعة وعدد غير المقروء من /home', () {
    final preview = GroupPreview.fromJson({'id': 'g1', 'name': 'حملة النور', 'leaderName': null, 'memberCount': 24}, 'A7K8P2');
    expect(preview.supervisor, isNull);
    expect(preview.memberCount, 24);
    expect(preview.code, 'A7K8P2');

    final group = HomeGroup.fromHome({
      'group': {'id': 'g1', 'name': 'حملة النور', 'memberCount': 25, 'myRole': 2, 'unreadAnnouncements': 1, 'unreadMessages': 3},
    })!;
    expect(group.unreadMessages, 3);
    expect(group.isLeader, isFalse);
  });
}
