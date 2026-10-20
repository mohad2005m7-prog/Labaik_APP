import '../../../../core/l10n/tx.dart';

/// السعي: الأشواط السبعة وشاشة "أتممت السعي" (نصوص Figma)
abstract final class SaeeRoundsText {
  static const title = Tx('أنت الآن في السعي', 'You are now in Sa\'i');
  static const subtitle = Tx('شوطاً بعد شوط… ونحن معك حتى تتم نسكك', 'Round after round… we are with you until you finish');
  static const roundDone = Tx('تم الشوط', 'Round done');

  /// زر نهاية كل شوط — يتغير حسب الاتجاه
  static const buttonToMarwa = Tx('وصلت إلى المروة', 'I reached Marwa');
  static const buttonToSafa = Tx('وصلت إلى الصفا', 'I reached Safa');

  /// توجيه الشوط داخل الكرت (سطر واحد، يتغير حسب الاتجاه)
  static const instrToMarwa = Tx('تابع سيرك بهدوء في الممر حتى تصل إلى المروة.', 'Continue walking calmly in the corridor until you reach Marwa.');
  static const instrToSafa = Tx('عد في نفس الممر باتجاه الصفا، وتابع سيرك بهدوء حتى تصل إليه.', 'Return along the same corridor toward Safa and walk calmly until you reach it.');

  /// "الشوط ٣ من ٧" — الكلمات #4C7A75 والأرقام #1F3B2E
  static ({String word, String number, String of, String total}) counter(int round) => AppLanguage.isArabic
      ? (word: 'الشوط', number: ' ${_arabicDigit(round)} ', of: 'من', total: ' ٧')
      : (word: 'Round', number: ' $round ', of: 'of', total: ' 7');

  /// الرقم الكبير بالشاشة
  static String roundNumber(int round) => AppLanguage.isArabic ? _arabicDigit(round) : '$round';

  static String _arabicDigit(int n) => '٠١٢٣٤٥٦٧٨٩'[n];

  /// الأشواط الفردية (1,3,5,7) تتجه من الصفا إلى المروة، الزوجية العكس
  static bool goingToMarwa(int round) => round.isOdd;

  /// توجيه كل شوط
  static const instructions = [
    Tx('امشِ من الصفا نحو المروة', 'Walk from Safa toward Marwa'),
    Tx('ارجع من المروة إلى الصفا', 'Return from Marwa to Safa'),
    Tx('امشِ من الصفا نحو المروة', 'Walk from Safa toward Marwa'),
    Tx('ارجع من المروة إلى الصفا', 'Return from Marwa to Safa'),
    Tx('امشِ من الصفا نحو المروة', 'Walk from Safa toward Marwa'),
    Tx('ارجع من المروة إلى الصفا', 'Return from Marwa to Safa'),
    Tx('امشِ من الصفا نحو المروة (الشوط الأخير)', 'Walk from Safa toward Marwa (last round)'),
  ];

  /// دعاء كل شوط
  static const duas = [
    Tx(
      '«رَبِّ اغْفِرْ وَارْحَمْ وَأَنْتَ الْأَعَزُّ الْأَكْرَمُ»',
      '«My Lord, forgive and have mercy, You are the Most Mighty, Most Generous»',
    ),
    Tx(
      '«اللَّهُمَّ اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُسْلِمِينَ أَجْمَعِينَ»',
      '«O Allah, forgive me, my parents and all the Muslims»',
    ),
    Tx(
      '«رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ»',
      '«Our Lord, give us good in this life and good in the next, and protect us from the Fire»',
    ),
    Tx(
      '«اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ»',
      '«O Allah, I ask You for pardon and well-being in this life and the next»',
    ),
    Tx(
      '«اللَّهُمَّ اجْعَلْ هَذَا السَّعْيَ مَقْبُولًا، وَالذَّنْبَ مَغْفُورًا، وَالسَّعْيَ مَشْكُورًا»',
      '«O Allah, make this Sa\'i accepted, the sin forgiven and the effort rewarded»',
    ),
    Tx(
      '«اللَّهُمَّ اغْفِرْ لَنَا وَارْحَمْنَا وَعَافِنَا وَاعْفُ عَنَّا»',
      '«O Allah, forgive us, have mercy on us, keep us well and pardon us»',
    ),
    Tx(
      '«اللَّهُمَّ تَقَبَّلْ مِنَّا سَعْيَنَا، وَاخْتِمْ لَنَا بِالصَّالِحَاتِ»',
      '«O Allah, accept our Sa\'i and seal our deeds with good»',
    ),
  ];

  // أتممت السعي
  static const doneTitle = Tx('أتممت السعي', 'Sa\'i completed');
  static const doneSubtitle = Tx('سبعة أشواط اكتملت… والآن ننتقل للخطوة التالية بهدوء.', 'Seven rounds done… now we calmly move to the next step.');
  static const doneHeadline = Tx('لقد أكملت 7 أشواط', 'You completed 7 rounds');
  static const doneBody = Tx(
    'أحسنت، أتممت سبعة أشواط بين الصفا والمروة.\nخذ لحظة للراحة إذا احتجت، ثم استعد للخطوة التالية.',
    'Well done, you completed seven rounds between Safa and Marwa. Rest a moment if needed, then get ready for the next step.',
  );
  static const doneNextStep = Tx('الخطوة التالية : التحلل (الحلق أو التقصير)', 'Next step: Tahallul (shaving or trimming)');
  static const doneButton = Tx('متابعة إلى الخطوة التالية', 'Continue to the next step');
}
