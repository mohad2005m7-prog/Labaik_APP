import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/l10n/api_error_text.dart';
import '../../../../core/network/session_events.dart';
import '../../../../core/utils/app_preferences.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../company/presentation/pages/company_shell.dart';
import '../../../family/presentation/controllers/family_controller.dart';
import '../../../group/data/sources/group_realtime.dart';
import '../../../group/presentation/controllers/group_controller.dart';
import '../../../supervisor/data/sources/supervisor_local_source.dart';
import '../../../supervisor/presentation/pages/supervisor_shell.dart';
import '../../../trip_details/data/models/trip_setup_mapper.dart';
import '../../../trip_details/data/repositories/trip_repository_impl.dart';
import '../../data/account_registry.dart';
import '../../data/auth_api_service.dart';
import '../../data/auth_session.dart';
import '../../data/models/account_type.dart';
import '../../data/models/trip_setup_data.dart';
import '../../data/token_refresher.dart';
import '../l10n/auth_messages_text.dart';
import '../l10n/new_password_text.dart';
import '../pages/auth_welcome_screen.dart';
import '../pages/create_new_password_screen.dart';
import '../pages/home_screen.dart';
import '../pages/login_screen.dart';
import '../pages/onboarding_screen.dart';
import '../pages/trip_type_screen.dart';
import '../pages/verification_code_screen.dart';

class AuthController {
  // 0. أول شاشة بعد السبلاش (حفظ التقدم):
  // - مسجّل دخول (توكن محفوظ من إنشاء الحساب أو تسجيل الدخول) → حسابه مباشرة
  // - شاف شاشات الترحيب قبل → اختيار اللغة (لو لسا ما اختار) أو شاشة الدخول/إنشاء الحساب
  // - أول مرة بيفتح التطبيق → شاشات الترحيب
  static Future<Widget> initialScreen() async {
    final token = await TokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      // دخل بكلمة مرور مؤقتة وسكّر التطبيق قبل ما يغيّرها → لازم يغيّرها أول
      if (await AuthSession.mustChangePassword()) return const CreateNewPasswordScreen.change(forced: true);
      return await homeScreen() ?? const AuthWelcomeScreen();
    }
    if (!await AppPreferences.isOnboardingSeen()) return const OnboardingScreen();
    return const AuthWelcomeScreen();
  }

  // وين بيفتح الحساب (حفظ التقدم — AccountRegistry):
  // - لسا ما اختار نوع حسابه بعد إنشائه → "نوع الحساب" | معتمر بنص إعداد رحلته → إعداد الرحلة
  // - مشرف المجموعة → واجهة المشرف (آخر تبويب كان فيه) | معتمر → رئيسية المعتمر
  // - الشركة → واجهة الشركة
  // - نوعه مش معروف (لا بالجهاز ولا بالسيرفر) → رئيسية المعتمر
  static Future<Widget?> homeScreen() async {
    final account = await AccountRegistry.current(askServer: true);
    // السوبر أدمن: لوحة التحكم على الويب بس — ما بيضل داخل بالتطبيق
    if (account?.type == AccountType.superAdmin) {
      await TokenStorage.clearTokens();
      await AuthSession.clear();
      return null;
    }
    switch (account?.setup) {
      case AccountSetup.tripSetup:
        return const TripTypeScreen();
      case AccountSetup.done when account!.type == AccountType.groupSupervisor:
        return SupervisorShell(initialTab: await SupervisorLocalSource().lastTab());
      case AccountSetup.done when account!.type == AccountType.company:
        return const CompanyShell();
      case AccountSetup.done:
      case null:
        return const HomeScreen();
    }
  }

  /// رسالة سريعة تحت الشاشة
  static void showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  // آخر خطوة بإعداد رحلة المعتمر → بتنحفظ رحلته (لشاشة "تفاصيل الرحلة") → رئيسيته (وما بترجعله شاشات الإعداد بعدها)
  static Future<void> finishTripSetup(BuildContext context) async {
    await TripRepositoryImpl().save(TripSetupData.instance.toTrip());
    await AccountRegistry.finishSetup();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  // تجديد الـ accessToken بالـ refreshToken المحفوظ لما ينتهي (حتى يضل المستخدم داخل حسابه)
  // بيرجع التوكن الجديد، أو null لو ما زبط
  static Future<String?> refreshAccessToken() => TokenRefresher.refresh();

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

      if (response.statusCode == 200) {
        // حفظ التوكن محلياً حتى تقدر شاشة الـ Home تجيب بيانات المستخدم
        final tokens = TokenStorage.extractTokens(response.body);
        await TokenStorage.saveTokens(
          accessToken: tokens['accessToken'],
          refreshToken: tokens['refreshToken'],
        );
        // user.roles وبيانات المستخدم مع التوكن
        await AuthSession.saveFromResponse(response.body);
        await AccountRegistry.signedIn(email);

        // كلمة مرور مؤقتة (حساب انعمل من فوق): لازم يغيّرها قبل ما يفوت — السيرفر رافض أي طلب تاني لحد ما يغيّرها
        if (await AuthSession.mustChangePassword()) {
          setLoading(false);
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => CreateNewPasswordScreen.change(forced: true, knownPassword: password)),
            (route) => false,
          );
          return;
        }

        // واجهته حسب نوع حسابه هو (مشرف / معتمر / شركة) — من الحسابات المسجلة أو السيرفر
        final home = await homeScreen();
        setLoading(false);
        if (!context.mounted) return;
        if (home == null) {
          showMessage(context, AuthMessagesText.dashboardOnly());
          return;
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => home),
          (route) => false,
        );
      } else {
        setLoading(false);
        if (!context.mounted) return;
        // الحساب موقوف (من الأدمن أو شركته) أو البريد مش مؤكد — رسالة واضحة بدل "بيانات غير صحيحة"
        final message = switch (AuthApiService.errorCode(response.body)) {
          'Auth.AccountDisabled' => AuthMessagesText.accountDisabled(),
          'Supervisor.Suspended' => AuthMessagesText.supervisorSuspended(),
          'Auth.EmailNotConfirmed' => AuthMessagesText.emailNotConfirmed(),
          'Company.Stopped' => ApiErrorText.companyStopped(),
          'Company.Expired' => ApiErrorText.companyExpired(),
          _ => AuthMessagesText.loginInvalid(),
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      setLoading(false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_failure(e))),
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
          SnackBar(content: Text(AuthMessagesText.registerFailed())),
        );
      }
    } catch (e) {
      setLoading(false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_failure(e))),
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
    // استعادة كلمة المرور: الرمز رمز استعادة (مش تأكيد بريد) — بيتحقق منه reset-password نفسه
    // (كان بينبعت لـ verify-email فالسيرفر يرفضه دايماً وما حدا يقدر يغيّر كلمته)
    if (isPasswordReset) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CreateNewPasswordScreen(email: email, code: code)));
      return;
    }
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
          await AuthSession.saveFromResponse(response.body);
          // حساب جديد → بينضاف للحسابات المسجلة، ونوع الحساب اللي رح يختاره بينحفظ إله
          await AccountRegistry.registered(email);

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AuthMessagesText.accountVerified())),
          );

          // الحاج بس بيسجّل → إعداد رحلته مباشرة (ما في "نوع الحساب")
          final home = await homeScreen() ?? const TripTypeScreen();
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => home),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AuthMessagesText.invalidCode())),
        );
      }
    } catch (e) {
      setLoading(false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_failure(e))),
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
          SnackBar(content: Text(AuthMessagesText.codeResent())),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_failure(e))),
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
          SnackBar(content: Text(AuthMessagesText.sendCodeFailed())),
        );
      }
    } catch (e) {
      setLoading(false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_failure(e))),
      );
    }
  }

  // 5.5 تغيير كلمة المرور وأنا داخل (الحالية + الجديدة) — [forced] = بعد كلمة مرور مؤقتة: بعدها بيفوت على حسابه
  static Future<void> changePassword({
    required BuildContext context,
    required String currentPassword,
    required String newPassword,
    required bool forced,
    required Function(bool) setLoading,
  }) async {
    setLoading(true);
    try {
      final token = await TokenRefresher.validAccessToken();
      if (token == null || token.isEmpty) {
        setLoading(false);
        if (context.mounted) await signOutToWelcome(context);
        return;
      }
      final response = await AuthApiService.changePassword(token: token, currentPassword: currentPassword, newPassword: newPassword);
      if (response.statusCode != 200) {
        setLoading(false);
        if (!context.mounted) return;
        showMessage(context, AuthApiService.errorCode(response.body) == 'Auth.InvalidCredentials' ? NewPasswordText.wrongCurrent() : AuthMessagesText.changeFailed());
        return;
      }
      // توكنات جديدة (والجلسات التانية انلغت)
      final tokens = TokenStorage.extractTokens(response.body);
      await TokenStorage.saveTokens(accessToken: tokens['accessToken'], refreshToken: tokens['refreshToken']);
      await AuthSession.saveFromResponse(response.body);
      final home = forced ? await homeScreen() : null;
      setLoading(false);
      if (!context.mounted) return;
      showMessage(context, AuthMessagesText.passwordChanged());
      if (!forced) {
        Navigator.pop(context);
        return;
      }
      if (home == null) return showMessage(context, AuthMessagesText.dashboardOnly());
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => home), (route) => false);
    } catch (e) {
      setLoading(false);
      if (!context.mounted) return;
      showMessage(context, _failure(e));
    }
  }

  /// خروج بدون ما يكمّل (من شاشة تغيير كلمة المرور الإجباري)
  static Future<void> signOutToWelcome(BuildContext context) async {
    await TokenRefresher.revoke();
    await TokenStorage.clearTokens();
    await AuthSession.clear();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthWelcomeScreen()), (route) => false);
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
          SnackBar(content: Text(AuthMessagesText.passwordChanged())),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        // رمز غلط أو منتهي → نرجعه لشاشة الرمز يطلب جديد
        final code = AuthApiService.errorCode(response.body);
        final message = switch (code) {
          'Otp.Invalid' => AuthMessagesText.invalidCode(),
          'Otp.Expired' => AuthMessagesText.codeExpired(),
          'Otp.TooManyAttempts' => AuthMessagesText.codeExpired(),
          _ => response.statusCode == 422 || response.statusCode == 400 ? AuthMessagesText.weakOrInvalid() : AuthMessagesText.resetFailed(),
        };
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        if (code != null && code.startsWith('Otp.')) Navigator.pop(context);
      }
    } catch (e) {
      setLoading(false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_failure(e))),
      );
    }
  }

  /// رسالة مفهومة بدل نص الخطأ التقني (بلا نت، مهلة، أو غيره)
  static String _failure(Object e) => e is SocketException || e is TimeoutException || e is http.ClientException || e is HandshakeException ? ApiErrorText.offline() : ApiErrorText.failed();

  /// الجلسة انتهت من السيرفر (SessionEvents): لازم يغيّر كلمة المرور → الشاشة الإجبارية
  /// غير هيك (انلغت الجلسة، المشرف موقوف، الحساب معطّل، الشركة موقوفة) → شاشة الدخول مع السبب
  static Future<void> onSessionEnded(String? code) async {
    final navigator = SessionEvents.navigatorKey.currentState;
    if (navigator == null) return SessionEvents.reset();
    if (code == 'Auth.PasswordChangeRequired') {
      navigator.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const CreateNewPasswordScreen.change(forced: true)), (route) => false);
      return;
    }
    await FamilyController.stopLocationSharing();
    await GroupController.stopLocationSharing();
    await TokenStorage.clearTokens();
    await AuthSession.clear();
    GroupRealtime.reset();
    navigator.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
    final message = ApiErrorText.forCode(code) ?? ApiErrorText.sessionEnded;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = SessionEvents.navigatorKey.currentContext;
      if (context != null) showMessage(context, message());
    });
  }
}
