import '../../../../core/l10n/tx.dart';

/// نصوص شاشة "هل انت جاهز لنسكك؟"
abstract final class FieldIntroText {
  static const title = Tx('هل انت جاهز لنسكك؟', 'Are you ready for your rite?');
  static const body = Tx(
    'سنرافقك خطوة بخطوة في رحلتك لأداء النسك بدءاً\nمن حالتك الحالية',
    'We will guide you step by step on your journey to perform the rite, starting from your current state',
  );
  static const cardTitle = Tx('ماذا سيساعدك وضع الميدان؟', 'How will field mode help you?');
  static const locationTitle = Tx(' إرشاد حسب موقعك', 'Guidance based on your location');
  static const locationDesc = Tx('نحدد خطواتك بناءً على موقعك ومرحلتك', 'We set your steps based on your location and stage');
  static const stepsTitle = Tx(' خطوة بخطوة', 'Step by step');
  static const stepsDesc = Tx('نرشدك في كل خطوة من مراحل النسك', 'We guide you through every stage of the rite');
  static const roundsTitle = Tx(' متابعة الأشواط', 'Tracking the rounds');
  static const roundsDesc = Tx('نساعدك على متابعة الأشواط وتأكيد إتمام الخطوات', 'We help you track the rounds and confirm completed steps');
  static const button = Tx('انا جاهز لنسكي', "I'm ready for my rite");
  static const note = Tx('يمكنك إيقاف وضع الميدان أو العودة إليه في أي وقت.', 'You can stop field mode or return to it at any time.');
}
