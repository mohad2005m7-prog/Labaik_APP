import '../../../../core/l10n/tx.dart';

/// نصوص شاشة "خلّينا نجهّز رحلتك"
abstract final class PrepareTripText {
  static const title = Tx('خلّينا نجهّز رحلتك', "Let's Prepare Your Trip");
  static const description = Tx(
    'سنسألك عن بعض تفاصيل رحلتك لنقدّم لك إرشادات مناسبة من لحظة وصولك وحتى أداء المناسك.',
    'We will ask you about a few details of your trip to give you the right guidance from the moment you arrive until you perform the rites.',
  );
  static const note = Tx('لن يستغرق الأمر سوى بضع دقائق.', 'It will only take a few minutes.');
  static const listTitle = Tx('ما الذي سنجهزه لك؟', 'What will we prepare for you?');
  static const itemArrival = Tx('✓ تفاصيل وصولك', '✓ Your arrival details');
  static const itemStay = Tx('✓ مكان إقامتك', '✓ Where you will stay');
  static const itemRoute = Tx('✓ إرشادات لمسار رحلتك', '✓ Guidance for your trip route');
  static const itemExperience = Tx('✓ تجربة تناسب احتياجاتك', '✓ An experience that suits your needs');
  static const letsStart = Tx('لنبدأ', "Let's Start");
}
