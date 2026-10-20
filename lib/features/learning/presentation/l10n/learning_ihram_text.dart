import '../../../../core/l10n/tx.dart';

/// المرحلة الأولى: الإحرام (Figma 222:1956) — "\n" مكان كسر سطور Figma و **...** = الخط الأعرض
abstract final class LearningIhramText {
  static const title = Tx('المرحلة الأولى: الإحرام', 'Stage one: Ihram');
  static const subtitle = Tx('استعدّ للعمرة واعرف ما يلزمك قبل بدء النسك', 'Get ready for Umrah and know what you need first');
  static const topChip = Tx('الاغتسال والاستعداد', 'Ghusl & getting ready');
  static const topNote = Tx('يُستحب الاغتسال قبل الإحرام والتجهّز لبدء العمرة', 'Bathing before Ihram is recommended to get ready for Umrah');

  static const miqat = Tx('الميقات', 'Miqat');
  static const miqatBody = Tx('استعد للإحرام واعقد نية العمرة قبل تجاوز الميقات المحدد لك.', 'Make your Umrah intention before the Miqat.');

  static const clothes = Tx('لباس الإحرام', 'Ihram clothing');
  static const clothesBody = Tx(
    '**للرجال**  ارتداء رداء وإزار أبيضين نظيفين، مع ضرورة كشف الرأس\nوكشف كعب وقدم الحذاء (شبشب مكشوف).\n\n**للنساء**   لبس الملابس النسائية العادية الساترة الفضفاضة، مع\nكشف الوجه والكفين فقط (يُحظر النقاب والقفازات).',
    '**Men:** two clean white sheets, head uncovered, open sandals that show the heel.\n**Women:** ordinary loose, modest clothes, face and hands uncovered (no niqab or gloves).',
  );

  static const intention = Tx('النية والتلبية', 'Intention & Talbiyah');
  static const intentionBody = Tx(
    'التلفظ بالنية عند الميقات: «لَبَّيْكَ اللَّهُمَّ عُمْرَةً» ثم البدء بالتلبية:\n«لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ...».',
    'At the Miqat say «Labbayk Allahumma Umrah», then start the Talbiyah.',
  );

  static const condition = Tx('هل تخشى وجود عائق يمنعك من إكمال العمرة؟', 'Afraid something may stop your Umrah?');
  static const conditionBody = Tx(
    'إذا كنت تخشى المرض أو حدوث أي ظرف طارئ يمنعك من\nإكمال العمرة، قُل هذا الدعاء عند عقد النية لتتحلل فوراً وبدون فدية\nإذا حبسك عائق: «لَبَّيْكَ اللَّهُمَّ عُمْرَةً، فَإِنْ حَبَسَنِي حَابِسٌ فَمَحِلِّي\nحَيْثُ حَبَسْتَنِي»',
    'If illness or an emergency may stop you, add this to your intention so you can leave Ihram without a sacrifice: «Labbayk Allahumma Umrah, fa in habasani habis fa mahilli haythu habastani».',
  );

  static const prohibitions = Tx('محظورات الإحرام', 'Ihram prohibitions');
  static const prohibitionsBody = Tx(
    'محظورات الإحرام: قص الشعر والأظافر، استعمال العطر بعد\nالدخول في الإحرام، الجماع ومقدماته، وعقد النكاح والصيد البري.\nوللرجال محظورات لباس خاصة، وللنساء أحكام خاصة باللباس أثناء\nالإحرام',
    'Not allowed in Ihram: cutting hair or nails, perfume, intercourse and its preliminaries, marriage contracts and hunting. Men and women also have special clothing rules.',
  );

  static const menRules = Tx('المحظورات الخاصة بالرجال', 'Prohibitions for men');
  static const womenRules = Tx('المحظورات الخاصة بالنساء', 'Prohibitions for women');
}
