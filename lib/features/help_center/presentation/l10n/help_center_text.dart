import '../../../../core/l10n/tx.dart';

/// نصوص "مركز المساعدة" (Figma 112:3793) — نفس كتابة Figma
abstract final class HelpCenterText {
  static const title = Tx('كيف بنقدر نساعدك؟', 'How can we help you?');
  static const subtitle = Tx('اختار المساعدة اللي بتحتاجها خلال رحلتك.', 'Choose the help you need during your trip.');

  static const lostTitle = Tx('تائه ؟ تواصل مع مشرفك', 'Lost? Contact your supervisor');
  static const lostSub = Tx('اتصل أو افتح المحادثة وأرسل موقعك.', 'Call or open the chat and send your location.');

  static const hotelTitle = Tx('رجّعني للفندق', 'Back to my hotel');
  static const hotelSub = Tx('ابدأ طريق العودة.', 'Start the way back.');

  static const familyTitle = Tx('رؤية العائلة', 'See my family');
  static const familySub = Tx('افتح خريطة أفراد العائلة.', 'Open the family map.');

  static const childTitle = Tx('الإبلاغ عن طفل مفقود', 'Report a lost child');
  static const childSub = Tx('أرسل تفاصيل البلاغ للمشرف.', 'Send the report to your supervisor.');

  static const askTitle = Tx('اسأل عن التطبيق والمناسك', 'Ask about the app and rituals');
  static const askSub = Tx('اعثر على إجابات لأسئلتك.', 'Find answers to your questions.');
}
