import 'package:flutter/widgets.dart';

// -------------------------------------------------------------
// الجلسة انتهت من السيرفر (الطلب رجع 401 حتى بعد التجديد، أو التجديد نفسه انرفض لأن الحساب موقوف/معطّل،
// أو 403 Auth.PasswordChangeRequired) — بدل ما تضل الشاشات فاضية بصمت، التطبيق بيرجّع المستخدم للشاشة الصح
// [handler] بيتحدد بـ main (طبقة الـ core ما بتعرف شاشات الـ features) — بالاختبارات null = ما بيصير إشي
// -------------------------------------------------------------
abstract final class SessionEvents {
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// [code] = كود السيرفر (Supervisor.Suspended، Auth.AccountDisabled، Company.Stopped، Auth.PasswordChangeRequired، ...)
  static void Function(String? code)? handler;

  static bool _handling = false;

  static void report(String? code) {
    final h = handler;
    if (h == null || _handling) return;
    _handling = true;
    h(code);
  }

  /// دخل من جديد (أو غيّر كلمة المرور) — الجاي بينعالج
  static void reset() => _handling = false;
}
