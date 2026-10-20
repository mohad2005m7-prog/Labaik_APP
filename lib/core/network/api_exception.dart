// -------------------------------------------------------------
// خطأ من السيرفر: [statusCode] = رد غير 2xx — أو null لما ما في اتصال (انقطاع/مهلة)
// -------------------------------------------------------------
class ApiException implements Exception {
  final int? statusCode;

  const ApiException(this.statusCode);

  /// ما في إنترنت أو السيرفر ما رد بالوقت
  bool get isOffline => statusCode == null;

  /// الـ endpoint لسا مش موجود على السيرفر (الباك إند ما ضافه بعد)
  bool get isMissingOnServer => statusCode == 404 || statusCode == 405 || statusCode == 501;

  /// الجلسة انتهت ومش قادرين نجدد التوكن
  bool get isUnauthorized => statusCode == 401;

  /// ما إله صلاحية (دوره، أو مش مشرف المجموعة) — حتى بعد تجديد التوكن
  bool get isForbidden => statusCode == 403;

  @override
  String toString() => 'ApiException(${statusCode ?? 'offline'})';
}
