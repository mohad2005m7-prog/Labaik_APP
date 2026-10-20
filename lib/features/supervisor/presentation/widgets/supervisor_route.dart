import 'package:flutter/material.dart';

// -------------------------------------------------------------
// انتقال شاشات المشرف: سريع وخفيف (250ms) — دخول من جهة النهاية مع fade
// (أخف من انتقال Android الافتراضي، وبيحترم الاتجاه: بالعربي بتدخل من اليسار)
// -------------------------------------------------------------
class SupervisorRoute<T> extends PageRouteBuilder<T> {
  SupervisorRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (context, _, _) => builder(context),
          transitionsBuilder: (context, animation, _, child) {
            final rtl = Directionality.of(context) == TextDirection.rtl;
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween(begin: Offset(rtl ? -0.12 : 0.12, 0), end: Offset.zero).animate(curved),
                child: child,
              ),
            );
          },
        );
}
