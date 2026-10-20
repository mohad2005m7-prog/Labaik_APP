import '../../../../core/l10n/tx.dart';

/// نصوص شاشة "أنت جاهز للخطوة التالية"
abstract final class ReadyText {
  static const title = Tx('أنت جاهز للخطوة التالية', 'You are ready for the next step');
  static const description = Tx(
    'تم تجهيزك للمتابعة. سنرشدك الآن إلى الخطوة المناسبة\nحسب موقعك ومرحلتك في النسك.',
    'You are all set. We will now guide you to the right step based on your location and stage of the rite.',
  );
  static const continueLabel = Tx('متابعة', 'Continue');
}
