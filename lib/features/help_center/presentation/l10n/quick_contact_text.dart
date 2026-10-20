import '../../../../core/l10n/tx.dart';

/// نصوص "التواصل السريع مع المشرف" (Figma 111:5972) — الشرح بنفس سطور Figma
abstract final class QuickContactText {
  static const title = Tx('محتاج مساعدة؟ إحنا معك', "Need help? We're with you");
  static const description = Tx('تواصل مع مشرف مجموعتك بسرعة، وشارك موقعك عشان يقدر\nيساعدك.', 'Reach your group supervisor quickly and share your location so they can help you.');
  static const role = Tx('مشرف المجموعة', 'Group supervisor');
  static const call = Tx('اتصال هاتفي', 'Phone call');
  static const chat = Tx('محادثة المشرف', 'Chat with supervisor');
}
