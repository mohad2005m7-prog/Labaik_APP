import '../network/api_exception.dart';
import 'tx.dart';

/// رسائل أخطاء السيرفر المشتركة (مش بـ Figma)
abstract final class ApiErrorText {
  static const offline = Tx('تحقق من اتصالك بالإنترنت وحاول مرة أخرى', 'Check your internet connection and try again');
  static const notOnServer = Tx('هذه الخدمة لسا مش مفعّلة على السيرفر', "This service isn't enabled on the server yet");
  static const sessionEnded = Tx('انتهت الجلسة، سجّل الدخول من جديد', 'Your session ended, please log in again');
  static const forbidden = Tx('ليس لديك صلاحية لهذا الإجراء', "You don't have permission to do this");
  static const failed = Tx('صار خطأ، حاول مرة أخرى', 'Something went wrong, please try again');

  // حسب "code" من السيرفر (أدق من رقم الحالة)
  static const companyStopped = Tx('حساب الشركة موقوف، تواصل مع إدارة لبيك', 'The company account is stopped, contact Labaik');
  static const companyExpired = Tx('انتهى اشتراك الشركة، تواصل مع إدارة لبيك', "The company's subscription has expired, contact Labaik");
  static const serviceDisabled = Tx('هذه الخدمة غير مفعّلة لشركتك', 'This service is not enabled for your company');
  static const limitReached = Tx('وصلت الشركة للحد الأقصى في باقتها', 'The company reached its plan limit');
  static const groupFull = Tx('المجموعة ممتلئة (وصلت العدد الأقصى)', 'The group is full');
  static const groupHasMembers = Tx('احذف معتمري المجموعة أولاً', "Remove the group's pilgrims first");
  static const alreadyMember = Tx('هذا الشخص عضو بالمجموعة من قبل', 'Already a member of this group');
  static const chatMuted = Tx('كتمك المشرف مؤقتاً في دردشة المجموعة', 'The supervisor muted you in the group chat');
  static const chatSupervisorOnly = Tx('الكتابة في هذه المجموعة للمشرف فقط', 'Only the supervisor can write in this group');
  static const chatNotAllowed = Tx('المراسلة متاحة بين المعتمر ومشرفه فقط', 'Messaging is only between a pilgrim and their supervisor');
  static const passwordChangeRequired = Tx('غيّر كلمة المرور المؤقتة أولاً', 'Change your temporary password first');
  static const accountDisabled = Tx('هذا الحساب موقوف', 'This account is disabled');
  static const supervisorSuspended = Tx('حسابك كمشرف موقوف من الشركة', 'Your supervisor account is suspended by your company');

  /// رسالة خاصة بكود السيرفر (null = ما في)
  static Tx? forCode(String? code) => switch (code) {
        'Company.Stopped' => companyStopped,
        'Company.Expired' => companyExpired,
        'Company.ServiceDisabled' => serviceDisabled,
        'Company.LimitReached' => limitReached,
        'Group.CapacityReached' => groupFull,
        'Group.HasMembers' => groupHasMembers,
        'Group.AlreadyMember' => alreadyMember,
        'Chat.Muted' => chatMuted,
        'Chat.SupervisorOnly' => chatSupervisorOnly,
        'Chat.NotAllowed' => chatNotAllowed,
        'Auth.PasswordChangeRequired' => passwordChangeRequired,
        'Auth.AccountDisabled' => accountDisabled,
        'Supervisor.Suspended' => supervisorSuspended,
        _ => null,
      };

  /// الرسالة حسب نوع الخطأ
  static Tx of(Object error) {
    if (error is! ApiException) return failed;
    final byCode = forCode(error.code);
    if (byCode != null) return byCode;
    if (error.isOffline) return offline;
    if (error.isMissingOnServer) return notOnServer;
    if (error.isUnauthorized) return sessionEnded;
    if (error.isForbidden) return forbidden;
    return failed;
  }
}
