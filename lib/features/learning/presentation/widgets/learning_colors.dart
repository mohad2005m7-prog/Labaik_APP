import 'package:flutter/material.dart';

/// ألوان شاشات مراحل التعلم (Figma)
abstract final class LearningColors {
  // الكرت #4C7A75 10% فوق الأبيض — لون مصمت حتى ظل الكرت ما يبين من تحته (Figma بيرسم الظل برا الشكل بس)
  static const card = Color(0xFFEDF2F1);
  // الشريحة #4C7A75 25% (جوّا الكرت) — والشريحة اللي فوق (عليها ظل) مصمتة على الأبيض
  static const chip = Color(0x404C7A75);
  static const raisedChip = Color(0xFFD2DEDD);
  // الأزرار الذهبية
  static const gold = Color(0xFFA59063);
  // خلفية النوافذ
  static const popup = Color(0xFFECF4F1);
}
