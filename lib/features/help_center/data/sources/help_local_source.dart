import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/data/account_registry.dart';
import '../../domain/entities/supervisor_contact.dart';
import '../models/supervisor_contact_json.dart';

// -------------------------------------------------------------
// نسخة على الجهاز من آخر بيانات المشرف من السيرفر — كل حساب لحاله (بإيميله):
//   help_supervisor:<email>  → المشرف (رقمه بيضل متاح للاتصال حتى بدون إنترنت)
// (رسائل المحادثة محفوظة بـ features/chats — ChatLocalSource)
// -------------------------------------------------------------
class HelpLocalSource {
  Future<String> _account() async => await AccountRegistry.currentEmail() ?? '';

  Future<SupervisorContact?> supervisor() async {
    final raw = (await SharedPreferences.getInstance()).getString('help_supervisor:${await _account()}');
    if (raw == null) return null;
    try {
      return SupervisorContactJson.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSupervisor(SupervisorContact? contact) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'help_supervisor:${await _account()}';
    if (contact == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, jsonEncode(contact.toJson()));
    }
  }
}
