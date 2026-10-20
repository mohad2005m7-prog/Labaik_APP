import 'package:flutter/widgets.dart';

/// اتجاه نص كتبه المستخدم حسب أول حرف فيه: عربي → rtl، لاتيني → ltr، فاضي/أرقام بس → null (اتجاه الشاشة)
/// (دعاء عربي بواجهة إنجليزية بيضل من اليمين، والعكس)
TextDirection? contentDirection(String text) {
  for (final rune in text.runes) {
    if ((rune >= 0x0590 && rune <= 0x08FF) || (rune >= 0xFB1D && rune <= 0xFEFF)) return TextDirection.rtl;
    if ((rune >= 0x41 && rune <= 0x5A) || (rune >= 0x61 && rune <= 0x7A) || (rune >= 0xC0 && rune <= 0x24F)) return TextDirection.ltr;
  }
  return null;
}
