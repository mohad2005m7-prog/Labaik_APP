import 'package:flutter/material.dart';

// ألوان شاشات تفاصيل الرحلة (من Figma)
abstract final class TripColors {
  static const green = Color(0xFF1F3B2E);
  static const teal = Color(0xFF4C7A75);

  // الكروت (#4C7A75 10% فوق الأبيض)
  static const cardFill = Color(0xFFEEF2F2);

  // خطوات التعديل اللي لسا ما وصلها (#1F3B2E 50%)
  static const stepIdle = Color(0x801F3B2E);

  // خانة "رحلتك الحالية" ونص "سنذكّرك...": تدرج من تحت #2E7C58 لفوق #224A37 بشفافية 80%
  static const gradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0xCC2E7C58), Color(0xCC224A37)],
  );
}
