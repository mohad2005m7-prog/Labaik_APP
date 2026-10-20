import '../../../../core/l10n/tx.dart';

/// نصوص "الطريق إلى نقطة التجمع" (Figma 111:6809) — [direction] من نقطة التجمع ("باب الملك فهد")
abstract final class GroupRouteText {
  static const title = Tx('الطريق إلى نقطة التجمع', 'Route to the meeting point');
  static String step(String direction) => tr(
        'تابع السير إلى الأمام، ثم اتبع الطريق باتجاه $direction.\nاستمر في المسار الحالي حتى تصل إلى الباب.',
        'Keep going forward, then follow the road towards $direction. Stay on this route until you reach the gate.',
      );
  static String hint(String direction) => tr('تابع المسار الحالي باتجاه $direction.', 'Stay on this route towards $direction.');
  static const arrived = Tx('وصلت إلى نقطة التجمع', "I've reached the meeting point");
  static const meetingPoint = Tx('نقطة التجمع', 'Meeting point');
  static const currentLocation = Tx('موقعك الحالي', 'Your location');
}
