import 'dart:math' as math;

import 'package:flutter/widgets.dart';

// -------------------------------------------------------------
// DesignScale — بيحوّل مقاسات Figma لمقاس شاشة الجهاز (نفس فكرة flutter_screenutil)
// إطار Figma: 393×852 — شريط الحالة 59 فوق والـ Home Indicator 34 تحت
// فالمساحة الآمنة بالتصميم = 393×759، وبنقابلها بالمساحة الآمنة الفعلية بالجهاز:
//   x(): الأشياء الأفقية (عرض، مسافات يمين/يسار، خط، أيقونات، radius)
//   y(): الأشياء العمودية (ارتفاع، مسافات فوق/تحت، مواقع top)
// على شاشة بحجم إطار Figma بالظبط (393×852) القيم بتطلع نفسها بدون أي تغيير.
// -------------------------------------------------------------
class DesignScale {
  static const designWidth = 393.0;
  static const designSafeHeight = 852.0 - 59.0 - 34.0; // 759

  final double sx;
  final double sy;

  const DesignScale._(this.sx, this.sy);

  /// لازم ينادى بـ context فوق الـ Scaffold (حتى يكون الـ padding هو تبع النظام)
  factory DesignScale.of(BuildContext context) => DesignScale.forFrame(context);

  /// إطار Figma أطول من 852 (مثل "لائحة أفراد المجموعة" 884): المساحة الآمنة بالتصميم = [frameHeight] − 93
  /// فالإطار كله بيوسع الشاشة بنفس نسبه (العمودي بيصغر شوي)
  factory DesignScale.forFrame(BuildContext context, {double frameHeight = 852}) {
    final size = MediaQuery.sizeOf(context);
    // الأكبر بين padding و viewPadding: لما يفتح الكيبورد padding.bottom بيصير 0 بس viewPadding بيضل
    // (فالشاشة ما بتتحجّم من جديد مع الكيبورد) — وبدون كيبورد الاتنين نفس الشي
    final padding = MediaQuery.paddingOf(context);
    final view = MediaQuery.viewPaddingOf(context);
    final sx = size.width / designWidth;
    final safeHeight = size.height - math.max(padding.top, view.top) - math.max(padding.bottom, view.bottom);
    // حماية للوضع الأفقي والتابلت: الفرق بين الاتجاهين ما بيزيد عن 15%
    final sy = (safeHeight / (frameHeight - 93)).clamp(sx * 0.85, sx * 1.15);
    return DesignScale._(sx, sy);
  }

  double x(double v) => v * sx;
  double y(double v) => v * sy;
}
