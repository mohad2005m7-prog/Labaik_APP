import '../network/api_exception.dart';
import 'tx.dart';

/// رسائل أخطاء السيرفر المشتركة (مش بـ Figma)
abstract final class ApiErrorText {
  static const offline = Tx('تحقق من اتصالك بالإنترنت وحاول مرة أخرى', 'Check your internet connection and try again');
  static const notOnServer = Tx('هذه الخدمة لسا مش مفعّلة على السيرفر', "This service isn't enabled on the server yet");
  static const sessionEnded = Tx('انتهت الجلسة، سجّل الدخول من جديد', 'Your session ended, please log in again');
  static const forbidden = Tx('ليس لديك صلاحية لهذا الإجراء', "You don't have permission to do this");
  static const failed = Tx('صار خطأ، حاول مرة أخرى', 'Something went wrong, please try again');

  /// الرسالة حسب نوع الخطأ
  static Tx of(Object error) {
    if (error is! ApiException) return failed;
    if (error.isOffline) return offline;
    if (error.isMissingOnServer) return notOnServer;
    if (error.isUnauthorized) return sessionEnded;
    if (error.isForbidden) return forbidden;
    return failed;
  }
}
