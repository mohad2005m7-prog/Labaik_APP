import 'package:flutter/material.dart';

import '../pages/terms_screen.dart';

// -------------------------------------------------------------
// الشروط والأحكام والسياسات: من إعدادات المعتمر والمشرف ("الشروط والأحكام والسياسات") ← رجوع بالسهم
// -------------------------------------------------------------
abstract final class TermsController {
  static Future<void> open(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen()));
}
