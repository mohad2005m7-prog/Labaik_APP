import 'package:flutter/material.dart';

// ألوان شاشات وضع الميدان (من Figma)
class FieldColors {
  static const green = Color(0xFF1F3B2E);
  static const accent = Color(0xFF4C7A75);
  static const grey = Color(0xFF717171);

  // #4C7A75 بشفافية 10% فوق الأبيض (لون صلب حتى ما يبيّن الظل من تحت الكرت)
  static const cardFill = Color(0xFFEDF2F1);

  // تدرّج عناوين خطوات الإحرام: من تحت #2E7C58 لفوق #224A37 (الخطوة الأولى لفوق #07291A) — شفافية التعبئة 80%
  static const stepGradient = LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xCC2E7C58), Color(0xCC224A37)]);
  static const firstStepGradient = LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xCC2E7C58), Color(0xCC07291A)]);
}
