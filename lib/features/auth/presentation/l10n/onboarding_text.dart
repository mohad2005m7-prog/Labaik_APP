import '../../../../core/l10n/tx.dart';

/// نصوص شاشات الترحيب
abstract final class OnboardingText {
  static const title1 = Tx('لَبيك رفيقك في كل خطوة', 'Labaik is your companion every step');
  static const description1 = Tx(
    'أدِّ مناسكك بسكينة وطمأنينة.. إرشاد تفاعلي يرافقك خطوة بخطوة دون تشتت أو تعقيد.',
    'Perform your rituals with peace of mind.. interactive step-by-step guidance without distraction.',
  );
  static const title2 = Tx('طريقك آمن.. وفندقك بنقرة زر', 'Your path is safe.. hotel a click away');
  static const description2 = Tx(
    'لا تقلق من الازدحام؛ عد إلى مقرك بسهولة مع ميزة "رجعني لفندقي" وابقَ على تواصل دائم مع عائلتك.',
    'Don\'t worry about crowds; easily return to your location with "Take me back to my hotel".',
  );
  static const title3 = Tx('صُمم ليكون سهلاً للجميع', 'Designed to be easy for everyone');
  static const description3 = Tx('واجهات بسيطة بخطوط واضحة تتناسب مع كافة الأعمار.', 'Simple interfaces with clear typography suitable for all ages.');
  static const startJourney = Tx('ابدأ رحلتك الآن!', 'Start your journey now!');
}
