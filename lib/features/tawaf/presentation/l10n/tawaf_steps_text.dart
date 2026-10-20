import '../../../../core/l10n/tx.dart';

/// شاشات الدخول للحرم لحد بداية الطواف (Figma 203:1886 → 203:2095) — "\n" مكان كسر سطور Figma
/// (انصلح بـ Figma: "هاذا" → "هذا" و"الساحة المفتوح" → "الساحة المفتوحة")
abstract final class TawafStepsText {
  // الوصول إلى الباب (العنوان باسم الباب اللي وصله — بـ Figma "وصلت إلى باب الملك فهد")
  static String gateTitle(String gateAr, String gateEn) => tr('وصلت إلى $gateAr', 'You reached $gateEn');
  static const gateSubtitle = Tx('من هنا تبدأ رحلتك إلى البيت العتيق', 'Your journey to the Ancient House starts here');
  static const gateCard = Tx('من هنا تبدأ رحلتك داخل المسجد الحرام.', 'Your journey inside Al-Masjid Al-Haram starts here.');
  static const gateNote = Tx('ادخل من هذا الباب', 'Enter through this gate');
  static const gateButton = Tx('دخلت الحرم', 'I entered the Haram');

  // داخل الحرم: اتبع الممر إلى المطاف
  static const insideTitle = Tx('أنت الآن داخل المسجد الحرام', 'You are now inside Al-Masjid Al-Haram');
  static const insideSubtitle = Tx('خذ طريقك بهدوء… نحن نرافقك خطوة بخطوة', 'Take your time… we are with you step by step');
  static const insideCard = Tx(
    'ستدخل الآن إلى الممرات الداخلية، فاتبع اللوحات\nالإرشادية التي تشير إلى «المطاف».',
    'You will now walk through the inner corridors. Follow the signs to «Mataf».',
  );
  static const insideNote = Tx('تابع طريقك نحو صحن المطاف.', 'Keep heading to the Mataf courtyard.');
  static const insideButton = Tx('وجدت لوحة «المطاف»', 'I found the «Mataf» sign');

  // لحظة رؤية الكعبة
  static const kaabaTitle = Tx('الكعبة أمامك', 'The Kaaba is in front of you');
  static const kaabaSubtitle = Tx('استقبل الكعبة بقلبك، وادعُ الله بما تشاء', 'Face the Kaaba with your heart and pray as you wish');
  static const kaabaCard = Tx(
    'لايوجد دعاء محدد عند رؤية الكعبة، إدعو بما تشاء من\nخيري الدنيا والآخرة.',
    'There is no set dua on seeing the Kaaba; ask for whatever good you wish in this life and the next.',
  );
  static const kaabaDua = Tx(
    '«اللَّهُمَّ زِدْ هَذَا الْبَيْتَ تَشْرِيفًا وَتَعْظِيمًا وَتَكْرِيمًا وَمَهَابَةً، وَزِدْ مَنْ\nشَرَّفَهُ وَكَرَّمَهُ مِمَّنْ حَجَّهُ أَوِ اعْتَمَرَهُ تَشْرِيفًا وَتَكْرِيمًا وَتَعْظِيمًا وَبِرًّا،\nاللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، فَحَيِّنَا رَبَّنَا بِالسَّلَامِ»',
    '«O Allah, increase this House in honour, greatness, respect and awe, and increase those who honour it among its pilgrims in honour, respect, greatness and righteousness. O Allah, You are Peace and from You is peace, so greet us, our Lord, with peace»',
  );
  static const kaabaButton = Tx('وصلت إلى صحن المطاف', 'I reached the Mataf courtyard');

  // اقتربت من صحن المطاف
  static const approachTitle = Tx('اقتربت من صحن المطاف', 'You are close to the Mataf');
  static const approachSubtitle = Tx('خطوات قليلة وتصل إلى موضع الطواف', 'A few steps and you reach the Tawaf area');
  static const approachCard = Tx(
    'ستبدأ الآن بالانتقال إلى الساحة التي ترى منها الكعبة\nالمشرفة.',
    'You will now move to the courtyard where you can see the Holy Kaaba.',
  );
  static const approachNote = Tx('اقتربت من الساحة المفتوحة', 'You are close to the open courtyard');
  static const approachButton = Tx('وصلت إلى صحن المطاف', 'I reached the Mataf courtyard');

  // الاضطباع للرجال
  static const idtibaTitle = Tx('اضبط إحرامك قبل الطواف', 'Adjust your Ihram before Tawaf');
  static const idtibaSubtitle = Tx('استعد للطواف بهدوء، وكل خطوة لها موضعها', 'Get ready for Tawaf calmly, one step at a time');
  static const idtibaCard = Tx(
    'للرجال: اكشف كتفك الأيمن، واجعل الرداء تحت إبطك\nالأيمن وعلى كتفك الأيسر.',
    'Men: uncover your right shoulder, with the sheet under your right arm and over your left shoulder.',
  );
  static const idtibaNote = Tx('يبقى الاضطباع أثناء الطواف فقط.', 'Idtiba is kept during Tawaf only.');
  static const idtibaButton = Tx('تم ضبط الإحرام', 'Ihram adjusted');

  // نقطة بداية الطواف
  static const startTitle = Tx('قف عند بداية الطواف', 'Stand at the start of Tawaf');
  static const startSubtitle = Tx('اقتربت لحظة الطواف… اجعلها على مهل', 'Tawaf is near… take it slowly');
  static const startCard = Tx(
    'حاذِ نقطة البداية، واجعل الكعبة عن يسارك. عند محاذاة الحجر\nالأسود، أشر إليه بيدك اليمنى وكبّر.',
    'Line up with the starting point with the Kaaba on your left. At the Black Stone, point to it with your right hand and say Allahu Akbar.',
  );
  static const startDua = Tx(
    '«بِسْمِ اللَّهِ، وَاللَّهُ أَكْبَرُ، اللَّهُمَّ إِيمَانًا بِكَ، وَتَصْدِيقًا بِكِتَابِكَ، وَوَفَاءً بِعَهْدِكَ،\nوَاتِّبَاعًا لِسُنَّةِ نَبِيِّكَ مُحَمَّدٍ ﷺ»',
    '«In the name of Allah, Allah is the Greatest. O Allah, out of faith in You, belief in Your Book, keeping Your covenant and following the Sunnah of Your Prophet Muhammad ﷺ»',
  );
  static const startButton = Tx('أنا عند نقطة البداية', 'I am at the starting point');

  // ابدأ الطواف
  static const beginTitle = Tx('ابدأ الشوط الأول', 'Start the first round');
  static const beginSubtitle = Tx('ابدأ باسم الله، ونحن نرافقك في كل شوط', 'Start in the name of Allah, we are with you every round');
  static const beginCard = Tx(
    'أنت الآن عند نقطة البداية.\nابدأ بالطواف حول الكعبة، واجعل الكعبة عن يسارك.',
    'You are now at the starting point. Start circling the Kaaba, keeping it on your left.',
  );
  static const beginNote = Tx('الطواف ٧ أشواط، وسنساعدك على متابعة كل شوط خطوة بخطوة.', 'Tawaf is 7 rounds, and we will help you follow each one.');
  static const beginButton = Tx('ابدأ الشوط الأول', 'Start the first round');

  // نافذة "تنبيه قبل المتابعة" (302:13279) — بعد "وجدت لوحة «المطاف»"
  static const shoesTitle = Tx('تنبيه قبل المتابعة', 'Before you continue');
  static const shoesBody = Tx(
    'إذا لم تخلع نعليك بعد، اخلعهما الآن وضعهما في المكان\nالمخصص أو احتفظ بهما معك.',
    'If you have not taken off your shoes yet, take them off now and leave them in the shoe area or keep them with you.',
  );
}
