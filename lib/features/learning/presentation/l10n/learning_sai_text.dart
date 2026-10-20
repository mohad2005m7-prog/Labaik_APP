import '../../../../core/l10n/tx.dart';

/// المرحلة الثالثة: السعي (Figma 243:3922) — "\n" مكان كسر سطور Figma
/// (بـ Figma العنوان "لمرحلة الثالثة" وأول كلمة بآخر كرت "لركض" — الألف ناقصة فانصلحوا)
abstract final class LearningSaiText {
  static const title = Tx('المرحلة الثالثة: السعي', "Stage three: Sa'i");
  static const subtitle = Tx('من الصفا إلى المروة، سبعة أشواط لإتمام السعي.', "From Safa to Marwah, seven rounds to complete Sa'i.");
  static const topChip = Tx('7 أشواط', '7 rounds');
  static const topNote = Tx('تبدأ بالصفا وتنتهي بالمروة.', 'Starts at Safa, ends at Marwah.');

  static const counting = Tx('كيف أحسب الأشواط؟', 'How do I count the rounds?');
  static const countingBody = Tx(
    'السعي ممر مستقيم وليس دائرياً. من الصفا إلى المروة شوط، ومن\nالمروة إلى الصفا شوط آخر',
    "Sa'i is a straight path: Safa to Marwah is one round, Marwah to Safa is another",
  );

  static const startLine = Tx('خط البداية والنهاية', 'Start & finish line');
  static const startLineBody = Tx(
    'السعي يبدأ دائماً من جبل الصفا وينتهي حتماً عند جبل المروة في\nالشوط السابع.',
    "Sa'i always starts at Mount Safa and ends at Mount Marwah in the seventh round.",
  );

  static const supplication = Tx('الدعاء عند الجبلين', 'Duas on the hills');
  static const supplicationBody = Tx(
    'يُسن استقبال القبلة عند الوقوف على الصفا والمروة ورفع اليدين\nللدعاء والتكبير 3 مرات قبل المشي.',
    'On Safa and Marwah, face the Qibla, raise your hands to pray and say takbir 3 times.',
  );

  static const harwala = Tx('الهرولة (للرجال)', 'Jogging (men)');
  static const harwalaBody = Tx(
    'يبدأ الشوط وينتهي عند محاذاة الحجر الأسود (الضوء الأخضر المعلق)\nبجعل الكعبة على يسارك تماماً .',
    'Each round starts and ends in line with the Black Stone (green light), with the Kaaba on your left.',
  );

  static const ramal = Tx('الاضطباع والرَّمَل (للرجال)', 'Idtiba and Ramal (men)');
  static const ramalBody = Tx(
    'الركض الخفيف فقط بين العلمين الأخضرين (الإضاءة الخضراء في\nالسقف)، والمشي العادي للنساء والرجال في باقي الممر.',
    'Light jogging only between the two green lights in the ceiling; normal walking elsewhere for everyone.',
  );

  static const rules = Tx('شروط وأحكام السعي', "Sa'i rules");
}
