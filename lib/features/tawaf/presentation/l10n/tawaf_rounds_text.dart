import '../../../../core/l10n/tx.dart';

/// الطواف: الأشواط السبعة (Figma 268:5033 …) وشاشة "أتممت الطواف" (256:5837) — "\n" مكان كسر سطور Figma
/// (انصلح بـ Figma: "ا" زيادة بآخر دعاء الشوط الخامس، و"لقد اكملت 7 اشواط" → "لقد أكملت 7 أشواط")
abstract final class TawafRoundsText {
  static const title = Tx('أنت الآن في الطواف', 'You are now in Tawaf');
  static const subtitle = Tx('شوطًا بعد شوط… ونحن معك حتى تتم نسكك', 'Round after round… we are with you until you finish');
  static const roundDone = Tx('تم الشوط', 'Round done');

  /// "الشوط ٣ من ٧" — الكلمات #4C7A75 والأرقام #1F3B2E (أرقام عربية متل Figma)
  static ({String word, String number, String of, String total}) counter(int round) => AppLanguage.isArabic
      ? (word: 'الشوط', number: ' ${arabicDigits(round)} ', of: 'من', total: ' ٧')
      : (word: 'Round', number: ' $round ', of: 'of', total: ' 7');

  static String arabicDigits(int n) => n.toString().split('').map((d) => '٠١٢٣٤٥٦٧٨٩'[int.parse(d)]).join();

  /// الرقم بنص الدائرة
  static String ringNumber(int round) => AppLanguage.isArabic ? arabicDigits(round) : '$round';

  /// دعاء كل شوط
  static const duas = [
    Tx(
      '«رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِنْ لَدُنْكَ رَحْمَةً إِنَّكَ أَنْتَ الْوَهَّابُ،\nرَبَّنَا إِنَّنَا آمَنَّا فَاغْفِرْ لَنَا ذُنُوبَنَا وَقِنَا عَذَابَ النَّارِ»',
      '«Our Lord, do not let our hearts deviate after You have guided us, and grant us mercy from Yourself; You are the Bestower. Our Lord, we have believed, so forgive us our sins and protect us from the Fire»',
    ),
    Tx(
      '«رَبَّنَا اغْفِرْ لَنَا ذُنُوبَنَا وَإِسْرَافَنَا فِي أَمْرِنَا وَثَبِّتْ أَقْدَامَنَا وَانْصُرْنَا عَلَى الْقَوْمِ\nالْكَافِرِينَ»',
      '«Our Lord, forgive us our sins and our excesses, make our feet firm and give us victory over the disbelievers»',
    ),
    Tx(
      '«اللَّهُمَّ أَصْلِحْ لِي دِينِي وَدُنْيَايَ وَآخِرَتِي، وَاجْعَلِ الْحَيَاةَ زِيَادَةً لِي فِي كُلِّ خَيْرٍ،\nوَالْمَوْتَ رَاحَةً لِي مِنْ كُلِّ شَرٍّ»',
      '«O Allah, set right my religion, my worldly life and my Hereafter; make life an increase in all good for me, and death a relief from all evil»',
    ),
    Tx(
      '«اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ،وَأَعُوذُ\nبِكَ مِنَ الْجُبْنِ وَالبُخْلِ، وَأَعُوذُ بِكَ مِنْ غَلَبَةِ الدَّيْنِ وَقَهْرِ الرِّجَالِ»',
      '«O Allah, I seek refuge in You from worry and grief, from weakness and laziness, from cowardice and miserliness, and from the burden of debt and being overpowered by men»',
    ),
    Tx(
      '«اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ\nوَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي»',
      '«O Allah, I ask You for pardon and well-being in this life and the next. O Allah, I ask You for pardon and well-being in my religion, my worldly life, my family and my wealth»',
    ),
    Tx(
      '«اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى، اللَّهُمَّ اغْفِرْ لِي، وَارْحَمْنِي،\nوَاهْدِنِي، وَعَافِنِي، وَارْزُقْنِي»',
      '«O Allah, I ask You for guidance, piety, chastity and sufficiency. O Allah, forgive me, have mercy on me, guide me, keep me well and provide for me»',
    ),
    Tx(
      '«اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ، وَتَحَوُّلِ عَافِيَتِكَ، وَفُجَاءَةِ نِقْمَتِكَ،\nوَجَمِيعِ سَخَطِكَ»',
      '«O Allah, I seek refuge in You from the loss of Your blessings, the change of Your protection, Your sudden punishment and all Your displeasure»',
    ),
  ];

  // أتممت الطواف
  static const doneTitle = Tx('أتممت الطواف', 'Tawaf completed');
  static const doneSubtitle = Tx('سبعة أشواط اكتملت… والآن ننتقل للخطوة التالية بهدوء.', 'Seven rounds are done… now we calmly move to the next step.');
  static const doneHeadline = Tx('لقد أكملت 7 أشواط', 'You completed 7 rounds');
  static const doneBody = Tx(
    'أحسنت، أتممت سبعة أشواط من الطواف حول الكعبة.\nخذ لحظة للراحة إذا احتجت، ثم استعد للخطوة التالية.',
    'Well done, you completed seven rounds around the Kaaba. Rest a moment if you need to, then get ready for the next step.',
  );
  static const doneButton = Tx('متابعة إلى الخطوة التالية', 'Continue to the next step');
}
