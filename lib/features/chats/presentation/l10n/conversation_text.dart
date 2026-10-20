import '../../../../core/l10n/tx.dart';

/// نصوص المحادثة (Figma 111:7045 و 372:7286)
abstract final class ConversationText {
  /// الـ placeholder بخانة الكتابة — نفس Figma (مكوّن iOS)
  static const hint = Tx('iMessage', 'iMessage');

  /// فقاعة الموقع
  static const myLocation = Tx('موقعي الحالي', 'My current location');

  // فواصل الوقت بين الرسائل — زي Figma ("Yesterday 9:41")
  static const today = Tx('Today', 'Today');
  static const yesterday = Tx('Yesterday', 'Yesterday');

  static const notSent = Tx('لم تُرسل — اضغط لإعادة المحاولة', 'Not sent — tap to retry');
}
