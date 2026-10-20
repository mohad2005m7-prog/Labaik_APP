import '../../../../core/l10n/tx.dart';

/// نصوص "إنشاء الدائرة" (111:5131) و"الانضمام" (111:5165) — بنفس كتابة وسطور Figma
abstract final class FamilySetupText {
  static const createTitle = Tx('أنشئ دائرة عائلتك', 'Create your family circle');
  static const joinTitle = Tx('انضم إلى دائرة عائلتك', 'Join your family circle');

  static const createDescription = Tx(
    'أنشئ دائرة تجمع أفراد عائلتك، وابقوا على تواصل وتابعوا مواقع\nبعض أثناء الرحلة ،يمكن لأفراد عائلتك مسح رمز QR للانضمام.',
    'Create a circle for your family, stay in touch and follow each other during the trip. Your family can scan the QR code to join.',
  );
  static const joinDescription = Tx(
    'أنشئ دائرة تجمع أفراد عائلتك، وابقوا على تواصل وتابعوا مواقع بعض\nأثناء الرحلة،يمكنك أيضًا مسح رمز QR للانضمام إلى دائرة عائلتك.',
    'Create a circle for your family, stay in touch and follow each other during the trip. You can also scan a QR code to join your family circle.',
  );

  static const createTab = Tx('إنشاء دائرة العائلة', 'Create family circle');
  static const joinTab = Tx('إنضم إلى دائرة العائلة', 'Join family circle');

  static const codeLabel = Tx('رمز المجموعة :', 'Group code:');
  static const shareInvite = Tx('مشاركة الدعوة', 'Share invite');

  static const enterCode = Tx('أدخل رمز المجموعة', 'Enter the group code');
  static const codeHint = Tx('مثال: UMRAH25', 'e.g. UMRAH25');

  /// نص الدعوة اللي بينبعت (مش بـ Figma)
  static String invite(String code, String? link) => tr(
        'انضم إلى دائرة عائلتي على تطبيق لبيك 🤍\nرمز المجموعة: $code${link == null ? '' : '\n$link'}',
        'Join my family circle on Labaik 🤍\nGroup code: $code${link == null ? '' : '\n$link'}',
      );
}
