import '../../../../core/l10n/tx.dart';

/// شاشات السعي — من الاضطباع بعد الطواف لحد التحلل (نصوص Figma)
abstract final class SaeeStepsText {
  // الاضطباع بعد الطواف
  static const idtibaTitle = Tx('اضبط إحرامك بعد الطواف', 'Adjust your Ihram after Tawaf');
  static const idtibaSubtitle = Tx('انتهى الطواف، حان الآن وقت إعادة تغطية كتفك\nوالاستعداد للصلاة.', 'Tawaf is done — time to cover your shoulder and prepare for prayer.');
  static const idtibaCard = Tx(
    'للرجال: أعد طرف رداء الإحرام فوق كتفك الأيمن، ليصبح\nكتفاك مغطّيين قبل الصلاة.',
    'Men: return the edge of the Ihram sheet over your right shoulder, so both shoulders are covered before prayer.',
  );
  static const idtibaNote = Tx('ينتهي الاضطباع بعد الطواف حول الكعبة', 'Idtiba ends after Tawaf around the Ka\'bah');
  static const idtibaButton = Tx('تم ، ضبط الإحرام', 'Ihram adjusted');

  // صلاة ركعتي الطواف
  // [إملاء]: الكافرون، الأولى (تصحيح بـ Figma: كانت الكافرن، الاولى)
  static const prayerTitle = Tx('صلاة ركعتي الطواف', 'Two Rak\'ahs of Tawaf');
  static const prayerSubtitle = Tx('خذ مكانك بهدوء، وصلِّ ركعتين قبل الانتقال إلى السعي.', 'Find your spot calmly and pray two Rak\'ahs before heading to Sa\'i.');
  static const prayerCard = Tx(
    'إن تيسّر، صلِّ خلف مقام إبراهيم، وإن كان المكان\nمزدحمًا فصلِّ في أي موضع مناسب داخل الحرم.',
    'If possible, pray behind the Maqam of Ibrahim. If crowded, pray anywhere suitable inside the Haram.',
  );
  static const prayerNote = Tx(
    'لمن أراد معرفة ما يُقرأ : سورة الكافرون في الركعة الأولى وسورة\nالإخلاص في الركعة الثانية',
    'For those who want to know what to recite: Surah Al-Kafirun in the first Rak\'ah and Al-Ikhlas in the second.',
  );
  static const prayerButton = Tx('تم، صليت الركعتين', 'Prayer done');

  // شرب ماء زمزم
  static const zamzamTitle = Tx('اشرب من ماء زمزم', 'Drink Zamzam water');
  static const zamzamSubtitle = Tx('بعد الصلاة، خذ لحظتك مع ماء زمزم، واشرب وادعُ الله بما\nتحب.', 'After prayer, take a moment with Zamzam water — drink and call on Allah as you wish.');
  static const zamzamCard = Tx(
    'توجه إلى أقرب نقطة لماء زمزم، واشرب منه بهدوء، ثم ادعُ الله بما\nتشاء.',
    'Head to the nearest Zamzam water point, drink calmly, then make dua as you wish.',
  );
  static const zamzamNote = Tx(
    '«اللهم إني أسألك علماً نافعاً، ورزقاً واسعاً، وشفاءً من كل داء»',
    '«O Allah, I ask You for beneficial knowledge, abundant provision, and healing from every illness»',
  );
  static const zamzamButton = Tx('تم، شربت من ماء زمزم', 'I drank Zamzam');

  // اتجه نحو المسعى
  static const masaaTitle = Tx('اتجه نحو المسعى', 'Head to the Mas\'a');
  static const masaaSubtitle = Tx('ارفع رأسك… اللوحات الخضراء ستدلك على الطريق.', 'Look up… the green signs will guide your way.');
  static const masaaCard = Tx(
    'ابحث عن اللوحات الإرشادية الخضراء المعلقة داخل الحرم، والتي\nتحمل عبارة «إلى المسعى» أو «إلى الصفا» مع سهم الاتجاه.',
    'Look for the green signs inside the Haram bearing the words "To Al-Mas\'a" or "To Al-Safa" with a direction arrow.',
  );
  static const masaaNote = Tx('تابع طريقك نحو المسعى.', 'Continue on your way to the Mas\'a.');
  static const masaaButton = Tx('تم أنا في الممر', 'I\'m in the corridor');

  // استعد للسعي
  // [إملاء]: "ذهاباً وإياباً" (Figma: "هذا شوط وإياتًا" — نص مكسور، تم تصحيحه)
  static const readyTitle = Tx('استعد للسعي', 'Get ready for Sa\'i');
  static const readySubtitle = Tx('٧ أشواط بين الصفا والمروة', '7 rounds between Safa and Marwa');
  static const readyCard = Tx(
    'تبدأ من الصفا وتتجه إلى المروة، ثم تعود إلى الصفا، وتستمر ذهابًا\nوإيابًا حتى تكمل ٧ أشواط.',
    'Start at Safa heading toward Marwa, then return to Safa — back and forth until you complete 7 rounds.',
  );
  // [إملاء]: "الإضاءة الخضراء" (Figma: "الخضراء الإضاءة" — ترتيب مكسور، تم تصحيحه)
  static const readyNote = Tx(
    'عند المرور بمنطقة الإضاءة الخضراء، يُسن الإسراع في\nالمشي، ثم العودة للمشي المعتاد بعد تجاوزها.',
    'When passing the green-lit zone, it is Sunnah to quicken your pace, then return to normal walking after passing it.',
  );
  static const readyButton = Tx('أنا مستعد للسعي', 'I\'m ready for Sa\'i');

  // اتجه إلى صالونات الحلاقة
  static const barbershopTitle = Tx('اتجه إلى صالونات الحلاقة', 'Head to the barbershops');
  static const barbershopSubtitle = Tx('ارفع رأسك… اللوحات الخضراء ستدلك على الطريق.', 'Look up… the green signs will guide your way.');
  static const barbershopCard = Tx(
    'بعد انتهاء السعي، اتجه إلى أحد صالونات الحلاقة القريبة\nمن الحرم لإتمام التحلل.',
    'After Sa\'i, head to one of the barbershops near the Haram to complete your Tahallul.',
  );
  static const barbershopNote = Tx('اتبع اللوحات الإرشادية وابحث عن علامة الحلاقة', 'Follow the signs and look for the barbershop sign.');
  static const barbershopButton = Tx('وجدت طريق الحلاقة', 'I found the barbershop way');

  // أتمم تحللك من العمرة
  static const tahallulTitle = Tx('أتمم تحللك من العمرة', 'Complete your Tahallul from Umrah');
  static const tahallulSubtitle = Tx('بقيت خطوة أخيرة، وبعدها تكون قد أتممت عمرتك بإذن ❤️ الله', 'One last step — then your Umrah is complete, by Allah\'s grace ❤️');
  static const tahallulMenHeader = Tx('للرجال: (الحلق أو التقصير)', 'For men: (shaving or trimming)');
  static const tahallulMenBody = Tx(
    'احلق شعرك أو قصّره للتحلل من العمرة.\nالحلق أفضل، ويجوز التقصير.',
    'Shave or trim your hair to exit Ihram. Shaving is better, trimming is permitted.',
  );
  static const tahallulWomenHeader = Tx('للمرأة: (التقصير)', 'For women: (trimming)');
  static const tahallulWomenBody = Tx(
    'قصّري قدرًا يسيرًا من أطراف شعرك\nللتحلل من العمرة.',
    'Trim a small amount from the ends of your hair to exit Ihram.',
  );
  static const tahallulNote = Tx('❤️ بعد التحلل، تنتهي أعمال العمرة.', '❤️ After Tahallul, the rites of Umrah are complete.');
  static const tahallulButton = Tx('تم التحلل', 'Tahallul done');

  // الحمدلله، أتممت نسكك
  // [إملاء]: "لقد أتممت نسكك بنجاح" (Figma: "لقد اتتمت ننسكك" — نص مكسور، تم تصحيحه)
  static const completeTitle = Tx('الحمدلله، أتممت نسكك', 'Praise Allah, you completed your rite');
  static const completeSubtitle = Tx('تقبّل الله منك، وكتب لك الأجر والقبول.', 'May Allah accept from you and reward you.');
  static const completeHeadline = Tx('الحمدلله على تمام النعمة', 'All praise to Allah for completing this blessing');
  static const completeSubHeadline = Tx('لقد أتممت نسكك بنجاح، تقبّل الله منك', 'You have completed your rite, may Allah accept from you');
  static const completeDua = Tx(
    '«الحَمْدُ لِلَّهِ الَّذِي بِنِعْمَتِهِ تَتِمُّ الصَّالِحَاتُ.. اللَّهُمَّ تَقَبَّلْ مِنَّا عُمْرَتَنَا،\nوَاغْفِرْ لَنَا ذُنُوبَنَا، وَاجْعَلْ سَعْيَنَا مَشْكُورًا، وَذَنْبَنَا مَغْفُورًا،\nوَعَمَلَنَا صَالِحًا مَقْبُولًا. اللَّهُمَّ اجْعَلْهَا عُمْرَةً مُبَارَكَةً تُغَسِّلُ\nبِهَا سَيِّئَاتِنَا، وَتَرْفَعُ بِهَا دَرَجَاتِنَا، وَتَرُدَّنَا إِلَى بِلَادِنَا\nسَالِمِينَ غَانِمِينَ. آمِينَ.»',
    '«All praise is for Allah, by whose grace good deeds are completed. O Allah, accept our Umrah, forgive our sins, make our effort rewarded, our sin forgiven, and our deeds righteous and accepted. O Allah, make it a blessed Umrah that washes our wrongs, raises our ranks, and returns us to our lands safe and blessed. Amen.»',
  );
  static const completeButton = Tx('إنهاء الرحلة', 'End the journey');
}
