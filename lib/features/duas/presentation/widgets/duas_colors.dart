import 'package:flutter/material.dart';

// ألوان شاشات الأدعية (من Figma — مقاسة من رندر الإطارات نفسها)
abstract final class DuasColors {
  static const green = Color(0xFF1F3B2E);
  static const teal = Color(0xFF4C7A75);
  static const grey = Color(0xFF717171);

  // خلفية التبويبين (#4C7A75 فوق الأبيض)
  static const tabsTrack = Color(0xFF84A29F);

  // كروت الأدعية المقترحة وأزرار القائمة (#4C7A75 ~10% فوق الأبيض)
  static const cardFill = Color(0xFFEEF2F2);
}
