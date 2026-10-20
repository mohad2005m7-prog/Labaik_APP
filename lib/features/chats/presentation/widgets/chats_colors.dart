import 'package:flutter/material.dart';

// ألوان شاشات الدردشات (أرقام Figma)
abstract final class ChatsColors {
  static const green = Color(0xFF1F3B2E);

  /// فقاعة رسالة الطرف التاني (iOS)
  static const bubbleIn = Color(0xFFE9E9EB);

  /// الوقت، الـ placeholder، وأيقونات iOS الرمادية: #3C3C43 بشفافية 60%
  static const time = Color(0x993C3C43);

  /// الفاصل بين صفوف القائمة: #3C3C43 بشفافية 36%
  static const separator = Color(0x5C3C3C43);

  /// خانة البحث: #D9D9D9 بشفافية 53% فوق الأبيض
  static const searchFill = Color(0xFFEBEBEB);

  static const avatarPlaceholder = Color(0xFFB6B6B6);
}
