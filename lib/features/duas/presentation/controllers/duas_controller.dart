import 'package:flutter/material.dart';

import '../../data/repositories/duas_repository_impl.dart';
import '../../domain/entities/personal_dua.dart';
import '../../domain/entities/suggested_dua.dart';
import '../../domain/repositories/duas_repository.dart';
import '../pages/dua_form_screen.dart';
import '../pages/duas_screen.dart';
import '../pages/suggested_dua_screen.dart';

// -------------------------------------------------------------
// التنقل بشاشات الأدعية:
// الرئيسية (كرت "أدعية") → الأدعية: "سجل أدعيتي" ⇄ "أدعية مقترحة"
//   سجل أدعيتي → "+ إضافة دعاء" / الضغط على دعاء (تعديله) → نفس شاشة إضافة دعاء → حفظ أو إلغاء → سجل أدعيتي
//   أدعية مقترحة → الدعاء الأول … العاشر
// -------------------------------------------------------------
class DuasController {
  static final DuasRepository _repository = DuasRepositoryImpl();

  static Future<void> open(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => DuasScreen(repository: _repository)));

  /// [dua] = null دعاء جديد، غير هيك تعديله
  static Future<void> openForm(BuildContext context, {PersonalDua? dua}) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => DuaFormScreen(repository: _repository, dua: dua)));

  static Future<void> openSuggested(BuildContext context, SuggestedDua dua) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => SuggestedDuaScreen(dua: dua)));

  static void showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(milliseconds: 1600)));
  }
}
