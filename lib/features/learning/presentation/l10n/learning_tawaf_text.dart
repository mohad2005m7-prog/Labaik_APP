import '../../../../core/l10n/tx.dart';

/// المرحلة الثانية: الطواف (Figma 202:2918) — "\n" مكان كسر سطور Figma
abstract final class LearningTawafText {
  static const title = Tx('المرحلة الثانية: الطواف', 'Stage two: Tawaf');
  static const subtitle = Tx('سبعة أشواط حول الكعبة بخشوع وطمأنينة', 'Seven rounds around the Kaaba with calm and humility');
  static const topChip = Tx('7 أشواط', '7 rounds');
  static const topNote = Tx('تبدأ من محاذاة الحجر الأسود وتنتهي عنده في كل شوط.', 'Each round starts and ends in line with the Black Stone.');

  static const direction = Tx('اتجاه الطواف', 'Tawaf direction');
  static const directionBody = Tx(
    'اجعل الكعبة على يسارك، واتبع مسار الطواف المحدد، واطُف من\nخارج حِجر إسماعيل.',
    'Keep the Kaaba on your left, follow the marked path and walk outside Hijr Ismail.',
  );

  static const purity = Tx('الطهارة والسلامة', 'Purity & safety');
  static const purityBody = Tx(
    'احرص على الطهارة، واتبع تعليمات الموقع، ولا تزاحم للوصول إلى\nالحجر الأسود أو لمسِه.',
    "Stay pure, follow the site rules and don't push to reach or touch the Black Stone.",
  );

  static const startLine = Tx('خط البداية والنهاية', 'Start & finish line');
  static const startLineBody = Tx(
    'يبدأ الشوط وينتهي عند محاذاة الحجر الأسود (الضوء الأخضر المعلق)\nبجعل الكعبة على يسارك تماماً .',
    'Each round starts and ends in line with the Black Stone (green light), with the Kaaba on your left.',
  );

  static const ramal = Tx('الاضطباع والرَّمَل (للرجال)', 'Idtiba and Ramal (men)');
  static const ramalBody = Tx(
    'كشف الكتف الأيمن طوال الأشواط السبعة، والإسراع في المشي\n(الرَّمَل) في الأشواط الثلاثة الأولى فقط إن تيسر.',
    'Uncover the right shoulder in all rounds and walk briskly (Ramal) in the first three if you can.',
  );

  static const hijr = Tx('الطواف حول الحِجْر', 'Tawaf around the Hijr');
  static const hijrBody = Tx(
    'اجعل الكعبة على يسارك، واتبع مسار الطواف المحدد، واطُف من\nخارج حِجر إسماعيل.',
    'Keep the Kaaba on your left, follow the marked path and walk outside Hijr Ismail.',
  );

  // والسهم "→" قبله مرسوم (LearningArrow)
  static const wuduQuestion = Tx('ماذا لو انتقض وضوئي أو نسيت عدد الأشواط؟', 'What if I lose my wudu or forget the count?');
}
