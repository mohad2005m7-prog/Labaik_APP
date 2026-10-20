import 'tx.dart';

/// نصوص كلمات مشتركة بين كذا شاشة (أزرار عامة وأسماء اللغات)
abstract final class CommonText {
  static const next = Tx('التالي', 'Next');
  static const continueLabel = Tx('متابعة', 'Continue');
  static const comingSoon = Tx('قريباً', 'Coming soon');
  static const arabic = Tx('العربية', 'Arabic');
  static const english = Tx('English', 'English');
}
