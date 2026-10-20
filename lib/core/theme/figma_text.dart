import 'package:flutter/material.dart';

import '../utils/design_scale.dart';

// -------------------------------------------------------------
// نصوص Figma العربية
// خطوط التصميم (Poppins و SF Compact) ما فيها حروف عربية، فـ Figma بيرسم العربي
// بـ Noto Sans Arabic. هون بنستخدم نسخة Noto Sans Arabic المتغيّرة (Variable)
// المضمّنة بالتطبيق، حتى نعطي الوزن الرقمي بالظبط (مش بس 500 أو 600)
// والأوزان بـ FigmaWeight مقاسة بمقارنة سماكة الخط مع رندر Figma نفسه.
// ملاحظة: Flutter ما بيطبّق letterSpacing على العربي (الحروف المتصلة).
// -------------------------------------------------------------
class FigmaWeight {
  static const poppinsLight = 300.0; // Poppins 300
  static const poppinsRegular = 400.0; // Poppins 400
  static const poppinsMedium = 500.0; // Poppins 500
  static const semiBold = 585.0; // Poppins 600 و SF Compact 556 (Figma بيرسمهم أخف من 600)
  static const sfSemibold = 690.0; // SF Compact 656 (عناوين إشعارات المشرف — مقاس بعرض النص مع رندر Figma)
  static const poppinsBold = 700.0; // Poppins 700
  static const sfRegular = 500.0; // SF Compact 457
  static const sfLight = 450.0; // SF Compact 350 (شريط التنقل)
  static const sfBold = 690.0; // SF Compact 790 (العناوين والترحيب)
}

const _family = 'NotoSansArabic';

/// نص بخط Poppins بـ Figma: الأرقام والرموز اللاتينية بتترسم بـ Poppins نفسه (لأنه فيه هالحروف)
/// والعربي بـ Noto Sans Arabic — فبنقسم النص لأجزاء. (Poppins Regular و Medium مضمّنين: [latinWeight] = w400 أو w500)
TextSpan poppinsLatinSpan(String text, TextStyle style, {FontWeight latinWeight = FontWeight.w500}) {
  final latin = style.copyWith(fontFamily: 'Poppins', fontWeight: latinWeight, fontVariations: const []);
  bool isLatin(int rune) => rune > 0x20 && rune < 0x0600 && rune != 0xA0;

  final spans = <TextSpan>[];
  final buffer = StringBuffer();
  bool? current;
  void flush() {
    if (buffer.isEmpty) return;
    spans.add(TextSpan(text: buffer.toString(), style: current! ? latin : style));
    buffer.clear();
  }

  for (final rune in text.runes) {
    // المسافة بتضل مع الجزء اللي قبلها
    final latinRune = rune == 0x20 ? (current ?? false) : isLatin(rune);
    if (current != null && latinRune != current) flush();
    current = latinRune;
    buffer.writeCharCode(rune);
  }
  flush();
  return TextSpan(children: spans, style: style);
}

/// [size] و [lineHeight] و [letterSpacing] أرقام Figma (px) وبتتحجّم مع الشاشة.
/// [lineHeight] = null يعني line height "auto" (1.2 من حجم الخط بدون توزيع متساوي).
TextStyle figmaText(
  DesignScale s, {
  required double size,
  required double weight,
  required Color color,
  double? lineHeight = 22,
  double letterSpacing = -0.408,
}) {
  return TextStyle(
    fontFamily: _family,
    fontVariations: [FontVariation('wght', weight)],
    fontSize: s.x(size),
    color: color,
    letterSpacing: s.x(letterSpacing),
    height: lineHeight == null ? 1.2 : lineHeight / size,
    leadingDistribution: lineHeight == null ? null : TextLeadingDistribution.even,
  );
}
