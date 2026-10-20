import '../../../../core/l10n/tx.dart';

/// المرحلة الرابعة: التحلّل (Figma 249:4165) — "\n" مكان كسر سطور Figma
/// (بـ Figma العنوان "لمرحلة الرابعة" — الألف ناقصة فانصلحت)
abstract final class LearningTahallulText {
  static const title = Tx('المرحلة الرابعة: التحلّل', 'Stage four: Tahallul');
  static const subtitle = Tx('بعد السعي، تعرّف على آخر خطوة لإتمام عمرتك', "After Sa'i, learn the last step of your Umrah");
  static const topChip = Tx('الحلق أو التقصير', 'Shaving or trimming');
  static const topNote = Tx('يكون التحلّل بعد إتمام أشواط السعي السبعة.', "Tahallul comes after the seven rounds of Sa'i.");

  static const men = Tx('التحلل للرجال', 'Tahallul for men');
  // نفس نص Figma (منسوخ من كرت "كيف أحسب الأشواط؟" بالسعي)
  static const menBody = Tx(
    'السعي ممر مستقيم وليس دائرياً. من الصفا إلى المروة شوط، ومن\nالمروة إلى الصفا شوط آخر',
    "Sa'i is a straight path: Safa to Marwah is one round, Marwah to Safa is another",
  );

  static const women = Tx('التحلل للنساء', 'Tahallul for women');
  static const womenBody = Tx(
    'التقصير فقط من أطراف الشعر قدر "أنملة" (عقلة إصبع، حوالي 2\nسم) في مكان مستور وخاص.',
    'Trim only about 2 cm (a fingertip) from the hair ends, in private.',
  );

  static const barbers = Tx('الذهاب للمراكز الرسمية', 'Go to the official centers');
  static const barbersBody = Tx(
    'التوجه إلى مجمعات الحلاقة المرخصة تحت ساحات المروة لضمان\nالنظافة والأسعار الحكومية الثابتة.',
    'Go to the licensed barbers under the Marwah plazas for clean service and fixed prices.',
  );
}
