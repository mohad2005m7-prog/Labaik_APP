import '../../../../core/l10n/tx.dart';

/// نصوص "أكّد وصولك" (Figma 165:5962) والنافذة "تم التأكيد" (163:5858)
abstract final class GroupArrivalText {
  static const title = Tx('أكّد وصولك', 'Confirm your arrival');
  static const question = Tx('هل وصلت نقطة التجمع', 'Have you reached the meeting point?');
  static const body = Tx('أكّد وصولك ليعرف مشرف المجموعة أنك وصلت بسلام.', 'Confirm so your group supervisor knows you arrived safely.');
  static const yes = Tx('نعم، وصلت', "Yes, I'm here");
  static const backToNavigation = Tx('العودة إلى الملاحة', 'Back to navigation');
  static const confirmed = Tx('تم التأكيد', 'Confirmed');
  static const backToGroup = Tx('العودة إلى مجموعتي', 'Back to my group');
}
