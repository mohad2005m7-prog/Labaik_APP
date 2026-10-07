import 'package:flutter/material.dart';
import '../../data/auth_api_service.dart';
import '../../../../core/utils/token_storage.dart';
import '../pages/account_type_screen.dart';
import '../pages/create_new_password_screen.dart';
import '../pages/login_screen.dart';
import '../pages/verification_code_screen.dart';
import '../pages/home_screen.dart';

class AuthController {
  // 1. تسجيل الدخول
  static Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
    required Function(bool) setLoading,
  }) async {
    setLoading(true);
    try {
      final response = await AuthApiService.login(
        email: email,
        password: password,
      );
      setLoading(false);
      if (!context.mounted) return;

      if (response.statusCode == 200) {
        // حفظ التوكن محلياً حتى تقدر شاشة الـ Home تجيب بيانات المستخدم
        final tokens = TokenStorage.extractTokens(response.body);
        await TokenStorage.saveTokens(
          accessToken: tokens['accessToken'],
          refreshToken: tokens['refreshToken'],
        );

        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('بيانات الدخول غير صحيحة')),
        );
      }
    } catch (e) {
      setLoading(false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  // 2. إنشاء حساب جديد
  static Future<void> register({
    required BuildContext context,
    required String fullName,
    required String email,
    required String password,
    required Function(bool) setLoading,
  }) async {
    setLoading(true);
    try {
      final response = await AuthApiService.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      setLoading(false);
      if (!context.mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationCodeScreen(email: email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء إنشاء الحساب')),
        );
      }
    } catch (e) {
      setLoading(false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  // 3. تأكيد الرمز عبر الـ API
  // ملاحظة: endpoint الـ verify-email حسب توثيق الـ API بيرجع tokens مباشرة
  // (يعني تأكيد الرمز = تسجيل دخول تلقائي)، فما في داعي نطلب من المستخدم
  // يسجل دخول يدوياً بعدها.
  static Future<void> verifyEmail({
    required BuildContext context,
    required String email,
    required String code,
    required bool isPasswordReset,
    required Function(bool) setLoading,
  }) async {
    setLoading(true);

    try {
      final response = await AuthApiService.verifyEmail(email: email, code: code);
      setLoading(false);
      if (!context.mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (isPasswordReset) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CreateNewPasswordScreen(email: email, code: code),
            ),
          );
        } else {
          // تسجيل حساب جديد: نحفظ التوكن (تسجيل دخول تلقائي بالخلفية)
          // ثم نبدأ سلسلة إعداد الحساب (نوع الحساب -> نوع الرحلة -> ... -> الرئيسية)
          final tokens = TokenStorage.extractTokens(response.body);
          await TokenStorage.saveTokens(
            accessToken: tokens['accessToken'],
            refreshToken: tokens['refreshToken'],
          );

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تأكيد الحساب بنجاح!')),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AccountTypeScreen()),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رمز التحقق غير صحيح، يرجى المحاولة مجدداً')),
        );
      }
    } catch (e) {
      setLoading(false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في الاتصال: $e')),
      );
    }
  }

  // 4. إعادة إرسال الرمز
  static Future<void> resendCode(BuildContext context, String email) async {
    try {
      final response = await AuthApiService.resendCode(email: email);
      if (!context.mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إعادة إرسال الرمز بنجاح')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إعادة إرسال الرمز: $e')),
      );
    }
  }

  // 5. طلب نسيت كلمة المرور
  static Future<void> forgotPassword({
    required BuildContext context,
    required String email,
    required Function(bool) setLoading,
  }) async {
    setLoading(true);
    try {
      final response = await AuthApiService.forgotPassword(email: email);
      setLoading(false);
      if (!context.mounted) return;

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationCodeScreen(
              email: email,
              isPasswordReset: true,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء إرسال الرمز')),
        );
      }
    } catch (e) {
      setLoading(false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  // 6. تعيين كلمة المرور الجديدة
  static Future<void> resetPassword({
    required BuildContext context,
    required String email,
    required String code,
    required String newPassword,
    required Function(bool) setLoading,
  }) async {
    setLoading(true);
    try {
      final response = await AuthApiService.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      setLoading(false);
      if (!context.mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في إعادة تعيين كلمة المرور')),
        );
      }
    } catch (e) {
      setLoading(false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }
}
