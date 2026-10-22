import 'dart:async';

import 'package:flutter/material.dart';

// -------------------------------------------------------------
// فتح شاشة بتستنى السيرفر أول (صفحة عضو، محادثة فردية...): الضغطة التانية ما بتفتح نسخة تانية،
// ولو الطلب طوّل أكتر من ربع ثانية بتطلع دائرة تحميل فوق الشاشة بدل ما يبين التطبيق معلّق
// -------------------------------------------------------------
abstract final class BusyOverlay {
  static bool _busy = false;

  /// null لو في طلب تاني شغّال
  static Future<T?> run<T>(BuildContext context, Future<T> Function() task) async {
    if (_busy) return null;
    _busy = true;
    final navigator = Navigator.of(context, rootNavigator: true);
    var shown = false;
    final timer = Timer(const Duration(milliseconds: 250), () {
      shown = true;
      showDialog<void>(
        context: navigator.context,
        barrierDismissible: false,
        builder: (_) => const PopScope(canPop: false, child: Center(child: CircularProgressIndicator(color: Colors.white))),
      );
    });
    try {
      return await task();
    } finally {
      timer.cancel();
      if (shown && navigator.mounted) navigator.pop();
      _busy = false;
    }
  }
}
