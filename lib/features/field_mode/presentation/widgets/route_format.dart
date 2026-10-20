import 'dart:math' as math;

import '../l10n/route_text.dart';

// -------------------------------------------------------------
// تنسيق المسافة والوقت بنفس شكل Figma ("8 كم" — "2.4 كم" — "300 م" — "12 دقيقة")
// -------------------------------------------------------------
class RouteFormat {
  static String distance(double meters) {
    final roundedMeters = math.max(10, (meters / 10).round() * 10);
    if (roundedMeters < 1000) return RouteText.distanceM('$roundedMeters');

    final km = meters / 1000;
    // أقل من 10 كم برقم عشري واحد (2.4)، وأكتر برقم صحيح (8 — 420)
    final rounded = km < 10 ? (km * 10).round() / 10 : km.roundToDouble();
    final value = rounded == rounded.truncateToDouble() ? _grouped(rounded.toInt()) : rounded.toStringAsFixed(1);
    return RouteText.distanceKm(value);
  }

  // فاصل الآلاف للمسافات الطويلة (مثلاً من غزة: "1,150 كم")
  static String _grouped(int value) {
    final digits = '$value';
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String duration(double seconds) {
    final minutes = math.max(1, (seconds / 60).ceil());
    if (minutes < 60) {
      return RouteText.durationMin(minutes);
    }
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    if (rest == 0) return RouteText.durationHours('$hours');
    return RouteText.durationHoursMin('$hours', '$rest');
  }
}
