import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/data/account_registry.dart';
import '../../domain/entities/budget.dart';
import '../models/budget_json.dart';

// -------------------------------------------------------------
// ميزانية المعتمر على الجهاز — كل حساب لحاله (بإيميله): budget:<email>
// تسجيل الخروج ما بيمسحها، فبترجع لما يسجل دخول بنفس الحساب
// -------------------------------------------------------------
class BudgetLocalSource {
  Future<String> _key() async => 'budget:${await AccountRegistry.currentEmail() ?? ''}';

  Future<Budget> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(await _key());
    if (raw == null) return Budget.empty;
    try {
      return BudgetJson.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return Budget.empty;
    }
  }

  Future<void> save(Budget budget) async => (await SharedPreferences.getInstance()).setString(await _key(), jsonEncode(budget.toJson()));
}
