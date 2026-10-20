import 'package:flutter/material.dart';

const companyAssets = 'assets/images/company';

// -------------------------------------------------------------
// ألوان واجهة الشركة (من Figma — الشفافة محسوبة فوق الأبيض حتى ما يبين الظل من تحتها)
// -------------------------------------------------------------
abstract final class CompanyColors {
  static const green = Color(0xFF1F3B2E);

  /// كروت أرقام الرئيسية
  static const statCard = Color(0xFFECF4F1);

  /// #4C7A75 10% فوق الأبيض — كروت الرحلات والإشعارات
  static const card = Color(0xFFEDF2F1);

  /// #4C7A75 10% فوق الكرت — مربع الدبوس ودوائر الأيقونات
  static const cardInset = Color(0xFFDDE6E5);

  /// #4C7A75 25% فوق الأبيض — الإشعار المهم
  static const cardStrong = Color(0xFFD2DEDC);

  /// #767680 12% — حقل البحث
  static const searchFill = Color(0x1F767680);

  /// #3C3C43 60% — Label Color/Light/Secondary
  static const secondaryLabel = Color(0x993C3C43);

  /// شريط التنقل #F5F5F5 94% وخطه العلوي أسود 30%
  static const navFill = Color(0xF0F5F5F5);
  static const navHairline = Color(0x4D000000);

  /// شارة "غير مكتملة" (المجموعة بلا مشرف)
  static const incomplete = Color(0xFF4C7A75);

  static const shadow = Color(0x40000000);
  static const greenShadow = Color(0x401F3B2E);
}
