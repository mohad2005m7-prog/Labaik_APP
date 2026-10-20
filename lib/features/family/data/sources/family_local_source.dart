import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/data/account_registry.dart';
import '../../domain/entities/family_circle.dart';
import '../../domain/entities/family_member.dart';
import '../models/family_json.dart';

// -------------------------------------------------------------
// نسخة على الجهاز من آخر بيانات وصلت من السيرفر — كل حساب لحاله (بإيميله):
//   family_circle:<email>    → الدائرة (بتطلع فوراً لما يضغط "العائلة")
//   family_members:<email>   → الأفراد
// -------------------------------------------------------------
class FamilyLocalSource {
  /// بادئة المفاتيح (البيانات التجريبية منفصلة: "demo_family" — حتى ما تختلط ببيانات السيرفر)
  final String prefix;

  FamilyLocalSource({this.prefix = 'family'});

  Future<String> _account() async => await AccountRegistry.currentEmail() ?? '';

  Future<FamilyCircle?> circle() async {
    final raw = (await SharedPreferences.getInstance()).getString('${prefix}_circle:${await _account()}');
    if (raw == null) return null;
    try {
      return FamilyJson.circle(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCircle(FamilyCircle? circle) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${prefix}_circle:${await _account()}';
    if (circle == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, jsonEncode(FamilyJson.circleToJson(circle)));
    }
  }

  Future<List<FamilyMember>> members() async {
    final raw = (await SharedPreferences.getInstance()).getString('${prefix}_members:${await _account()}');
    if (raw == null) return const [];
    try {
      return [for (final item in (jsonDecode(raw) as List).whereType<Map<String, dynamic>>()) FamilyJson.member(item)];
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveMembers(List<FamilyMember> members) async {
    await (await SharedPreferences.getInstance()).setString('${prefix}_members:${await _account()}', jsonEncode([for (final m in members) FamilyJson.memberToJson(m)]));
  }
}
