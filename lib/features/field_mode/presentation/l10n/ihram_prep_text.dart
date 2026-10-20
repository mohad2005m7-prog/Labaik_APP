import '../../../../core/l10n/tx.dart';

/// نصوص شاشة الاستعداد للإحرام (الخطوات)
abstract final class IhramPrepText {
  static const title = Tx('الاستعداد للإحرام', 'Preparing for ihram');
  static const intro = Tx('اتبع الخطوات بالترتيب، وعند إتمام كل خطوة \nاضغط "تمت".', 'Follow the steps in order, and when you finish each step tap "Done".');
  static const step1Title = Tx('1. اغتسل واستعد', '1. Bathe and get ready');
  static const step1Body = Tx(
    'اغتسل إن تيسر لك، وتطيب على بدنك  وليس على\nملابس إحرام إن رغبت، ثم ارتدِ ملابس الإحرام.',
    'Bathe if you can, and apply perfume to your body (not to the ihram clothes) if you wish, then put on the ihram clothes.',
  );
  static const step1Clothes = Tx(
    'للرجل : الإزار والرداء\nللمرأة : ملابسها المعتادة مع مراعاة أحكام\nالإحرام.',
    'Men: the izar and rida\nWomen: their usual clothes, observing the rules of ihram.',
  );
  static const howToWear = Tx('طريقة ارتداء الإحرام →', 'How to wear ihram →');
  static const step2Title = Tx('2. صلِّ إن كان وقت الصلاة', '2. Pray if it is prayer time');
  static const step2Body = Tx(
    'إن حضرت فريضة فصلِّها، وإلا فصلِّ ركعتين تنوي\nبها سنة الوضوء .',
    'If an obligatory prayer is due, pray it; otherwise pray two rak‘ahs as the Sunnah of wudu.',
  );
  static const step2Note = Tx('الحائض والنفساء لا تصليان.', 'Women in menstruation or postpartum do not pray.');
  static const step3TitleA = Tx('3. انوِ ', '3. Intend ');
  static const step3TitleB = Tx('العمرة', 'Umrah');
  static const step3Body = Tx(
    'بعد الصلاة فانو الحج بقلبك عند الميقات وتلفظ\nبالنسك الذي تريده',
    'After the prayer, make the intention in your heart at the Miqat and say the rite you want',
  );
  static const step3Talbiya = Tx(' قائلاً  “ لبيك اللهم عمرة “', 'saying “Labbayk Allahumma Umrah”');
  static const step4Title = Tx('4. ابدأ التلبية', '4. Start the Talbiyah');
  static const step4Body = Tx('بعد الإحرام والنية، ابدأ بالتلبية.', 'After ihram and intention, start the Talbiyah.');
  static const step4Talbiya = Tx(
    ' قائلاً “ لبيك اللهم لبيك، لبيك لا شريك لك لبيك،\nإن الحمد والنعمة لك والملك، لا شريك لك “',
    'saying “Labbayk Allahumma labbayk, labbayka la sharika laka labbayk, innal-hamda wan-ni‘mata laka wal-mulk, la sharika lak”',
  );
  static const step4Note = Tx('بعد الدخول في النسك، تجنب محظورات الإحرام', 'After entering the rite, avoid the prohibitions of ihram');
  static const details = Tx('التفاصيل →', 'Details →');
  static const done = Tx('تم', 'Done');
}
