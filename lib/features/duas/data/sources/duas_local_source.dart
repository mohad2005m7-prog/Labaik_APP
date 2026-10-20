import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/data/account_registry.dart';
import '../../domain/entities/personal_dua.dart';
import '../models/personal_dua_json.dart';

// -------------------------------------------------------------
// أدعية المعتمر على الجهاز — كل حساب لحاله (بإيميله): duas_personal:<email>
// تسجيل الخروج ما بيمسحها، فبترجع لما يسجل دخول بنفس الحساب
// -------------------------------------------------------------
class DuasLocalSource {
  Future<String> _key() async => 'duas_personal:${await AccountRegistry.currentEmail() ?? ''}';

  Future<List<PersonalDua>> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(await _key());
    if (raw == null) return [];
    try {
      return [for (final j in jsonDecode(raw) as List) PersonalDuaJson.fromJson(j as Map<String, dynamic>)];
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<PersonalDua> duas) async =>
      (await SharedPreferences.getInstance()).setString(await _key(), jsonEncode([for (final d in duas) d.toJson()]));
}
