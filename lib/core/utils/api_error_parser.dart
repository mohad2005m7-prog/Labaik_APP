import 'dart:convert';

// -------------------------------------------------------------
// ApiErrorParser
// بيفهم شكل أخطاء الباك اند (ASP.NET ValidationProblemDetails):
// { "status": 422, "errors": { "Password": ["..."] } }
// وبيرجع رسالة عربية مناسبة للمستخدم بدل ما نعرضله الخطأ الخام.
// -------------------------------------------------------------
class ApiErrorParser {
  static String parse(String responseBody) {
    try {
      final Map<String, dynamic> json = jsonDecode(responseBody);

      // 1) أخطاء تحقق فيها خريطة errors لكل حقل (422)
      if (json['errors'] is Map && (json['errors'] as Map).isNotEmpty) {
        final errors = json['errors'] as Map<String, dynamic>;
        final field = errors.keys.first;
        final messages = errors[field];
        final rawMessage =
            (messages is List && messages.isNotEmpty) ? messages.first.toString() : '';
        return _friendlyFieldMessage(field, rawMessage);
      }

      // 2) خطأ عام فيه title بس (401/404/...)
      if (json['title'] != null) {
        return _friendlyTitleMessage(json['title'].toString());
      }

      // 3) شكل بسيط { "message": "..." }
      if (json['message'] != null) {
        return json['message'].toString();
      }
    } catch (_) {
      // تجاهل فشل الـ parsing (مثلاً السيرفر رجع نص عادي مش JSON)
    }
    return 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى.';
  }

  // ترجمة خطأ حقل معيّن لرسالة عربية مفهومة
  static String _friendlyFieldMessage(String field, String rawMessage) {
    final msg = rawMessage.toLowerCase();

    switch (field.toLowerCase()) {
      case 'password':
        if (msg.contains('character')) {
          return 'كلمة السر قصيرة جداً، يجب أن تحتوي على 8 أحرف على الأقل مع رقم وحرف كبير ورمز.';
        }
        return 'كلمة السر غير مطابقة للشروط المطلوبة، حاول كلمة أقوى.';

      case 'newpassword':
        return 'كلمة السر الجديدة غير مطابقة للشروط المطلوبة، حاول كلمة أقوى.';

      case 'email':
        if (msg.contains('already') || msg.contains('exist') || msg.contains('taken')) {
          return 'هذا البريد الإلكتروني مستخدم من قبل.';
        }
        if (msg.contains('valid') || msg.contains('format')) {
          return 'صيغة البريد الإلكتروني غير صحيحة.';
        }
        return 'يرجى التحقق من البريد الإلكتروني المدخل.';

      case 'fullname':
        return 'يرجى إدخال الاسم الكامل بشكل صحيح.';

      case 'code':
        return 'رمز التحقق غير صحيح أو منتهي الصلاحية.';

      default:
        return 'يرجى التحقق من البيانات المدخلة والمحاولة مرة أخرى.';
    }
  }

  // ترجمة خطأ عام (401/404/...)
  static String _friendlyTitleMessage(String title) {
    final t = title.toLowerCase();
    if (t.contains('unauthorized')) {
      return 'البريد الإلكتروني أو كلمة السر غير صحيحة.';
    }
    if (t.contains('not found')) {
      return 'لم يتم العثور على الحساب.';
    }
    return 'حدث خطأ، يرجى المحاولة مرة أخرى.';
  }
}
