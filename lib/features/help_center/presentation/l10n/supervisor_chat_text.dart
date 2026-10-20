import '../../../../core/l10n/tx.dart';

/// نصوص "المحادثة الفردية" مع المشرف من مركز المساعدة (Figma 372:7286)
/// (النصوص المشتركة مع الدردشات: features/chats — ConversationText)
abstract final class SupervisorChatText {
  /// رسالة المشرف الأولى بالتصميم (بتطلع أول المحادثة دايماً) — بنفس سطور Figma
  static const greeting = Tx(
    'أهلاً بك، لنتمكن من مساعدتك، نرجو\nمنك إرسال موقعك الحالي بالنقر على\nالزر أدناه',
    'Welcome! So we can help you, please send your current location by tapping the button below',
  );

  /// الـ placeholder: الإرسال وخانة الكتابة فاضية بيبعت الموقع الحالي
  static const hint = Tx('إرسال موقعي الحالي', 'Send my current location');

  static const locating = Tx('جاري تحديد موقعك…', 'Finding your location…');
}
