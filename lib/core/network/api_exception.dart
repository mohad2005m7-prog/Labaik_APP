// -------------------------------------------------------------
// خطأ من السيرفر: [statusCode] = رد غير 2xx — أو null لما ما في اتصال (انقطاع/مهلة)
// [code] = "code" من ProblemDetails (Group.CapacityReached، Company.Stopped، Chat.Muted، ...) لو السيرفر بعته
// -------------------------------------------------------------
class ApiException implements Exception {
  final int? statusCode;
  final String? code;

  const ApiException(this.statusCode, [this.code]);

  /// ما في إنترنت أو السيرفر ما رد بالوقت
  bool get isOffline => statusCode == null;

  /// الـ endpoint لسا مش موجود على السيرفر (الباك إند ما ضافه بعد)
  bool get isMissingOnServer => statusCode == 404 || statusCode == 405 || statusCode == 501;

  /// الجلسة انتهت ومش قادرين نجدد التوكن
  bool get isUnauthorized => statusCode == 401;

  /// ما إله صلاحية (دوره، أو مش مشرف المجموعة) — حتى بعد تجديد التوكن
  bool get isForbidden => statusCode == 403;

  @override
  String toString() => 'ApiException(${statusCode ?? 'offline'}${code == null ? '' : ', $code'})';
}
