import 'package:flutter/material.dart';

import '../l10n/duas_text.dart';
import 'duas_colors.dart';

enum DuaAction { edit, delete }

// -------------------------------------------------------------
// خيارات دعاء خاص (ضغطة مطوّلة على الكرت): تعديل / حذف — والحذف بيتأكد قبل
// (مش مصممين بـ Figma: نفس شكل خيارات الصورة بتعديل البيانات)
// -------------------------------------------------------------
const _red = Color(0xFFF44336);

TextStyle _style(Color color) => TextStyle(fontFamily: 'NotoSansArabic', fontSize: 16, color: color);

Future<DuaAction?> showDuaActions(BuildContext context) {
  Widget option(BuildContext sheet, IconData icon, String label, DuaAction action, Color color) => ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: _style(color)),
        onTap: () => Navigator.pop(sheet, action),
      );
  return showModalBottomSheet<DuaAction>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          option(sheet, Icons.edit_outlined, DuasText.edit(), DuaAction.edit, DuasColors.green),
          option(sheet, Icons.delete_outline_rounded, DuasText.delete(), DuaAction.delete, _red),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

Future<bool> confirmDeleteDua(BuildContext context, String title) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      backgroundColor: Colors.white,
      title: Text(DuasText.deleteQuestion(), style: _style(DuasColors.green).copyWith(fontWeight: FontWeight.w600)),
      content: Text(title, style: _style(Colors.black)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialog, false), child: Text(DuasText.cancel(), style: _style(DuasColors.green))),
        TextButton(onPressed: () => Navigator.pop(dialog, true), child: Text(DuasText.delete(), style: _style(_red))),
      ],
    ),
  );
  return confirmed ?? false;
}
