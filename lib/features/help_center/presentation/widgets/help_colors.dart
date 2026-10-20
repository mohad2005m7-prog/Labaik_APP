import 'package:flutter/material.dart';

// ألوان شاشات مركز المساعدة (أرقام Figma)
abstract final class HelpColors {
  static const green = Color(0xFF1F3B2E);
  static const grey = Color(0xFF717171);

  /// الكروت وشريط الكتابة: #4C7A75 بشفافية 10% فوق الأبيض — لون معتم (#EEF2F2 زي رندر Figma)
  /// حتى ما يبيّن الظل من تحت الكرت (Figma ما بيرسم الظل تحت التعبئة)
  static const cardFill = Color(0xFFEEF2F2);

  /// فقاعة رسالة المشرف (iOS)
  static const bubbleIn = Color(0xFFE9E9EB);

  /// وقت الرسائل: #3C3C43 بشفافية 60%
  static const time = Color(0x993C3C43);

  /// "إرسال موقعي الحالي" بشريط الكتابة (مقاس من لقطة Figma)
  static const inputHint = Color(0x78000000);

  /// شريط التنقل (ناف بار مركز المساعدة)
  static const tabBarFill = Color(0xF0F5F5F5);
  static const tabBarHairline = Color(0x4D000000);

  /// رسالة "تم إرسال البلاغ بنجاح!"
  static const successFill = Color(0xFFECF4F1);

  static const avatarPlaceholder = Color(0xFFB6B6B6);
}
