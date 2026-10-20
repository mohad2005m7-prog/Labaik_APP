import 'package:flutter/material.dart';

// ألوان شاشات دائرة العائلة (أرقام Figma — والمقاسة من لقطاته)
abstract final class FamilyColors {
  static const green = Color(0xFF1F3B2E);
  static const grey = Color(0xFF717171);

  /// الكروت والخانات: #4C7A75 10% فوق الأبيض (معتم حتى ما يبيّن الظل تحته)
  static const cardFill = Color(0xFFEEF2F2);

  /// النافذة "مع من تريد التتبع؟"
  static const dialogFill = Color(0xFFECF4F1);

  /// الـ SegmentedPicker: #767680 بشفافية 24%
  static const segmentFill = Color(0x3D767680);

  /// خانة البحث: #767680 بشفافية 12%
  static const searchFill = Color(0x1F767680);

  /// الدبوس: متصل (أحمر) — غير متصل (نفس الأحمر 50%) — ما شارك (رمادي)
  static const pinOnline = Color(0xFFE74C3C);
  static const pinOffline = Color(0x80E74C3C);

  /// نقطة "متصل الان" وأحمر "اخر ظهور"
  static const online = Color(0xFF00FF5D);
  static const offline = Color(0xFFE74C3C);

  /// موقعي على الخريطة (أزرق) ونقطة التجمع (أصفر)
  static const me = Color(0xFF372EDD);
  static const meeting = Color(0xFFFFDB56);
  static const flag = Color(0xFFFFD600);

  static const avatarPlaceholder = Color(0xFFB6B6B6);
}
