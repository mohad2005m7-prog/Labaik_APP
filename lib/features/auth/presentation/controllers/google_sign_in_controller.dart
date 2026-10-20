import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/utils/token_storage.dart';
import '../../data/account_registry.dart';
import '../../data/auth_api_service.dart';
import '../../data/auth_session.dart';
import '../../data/google_auth_config.dart';
import '../l10n/auth_messages_text.dart';
import 'auth_controller.dart';

// -------------------------------------------------------------
// "الدخول عبر Google" (شاشة الدخول وإنشاء الحساب):
// google_sign_in بيعطي ID token → POST /auth/google → نفس رد الدخول (التوكنات و user.roles)
// الإيميل المسجّل من قبل بكلمة مرور بينربط لحاله بالسيرفر — وحساب Google الجديد بدون كلمة مرور
// من "إنشاء حساب" (أو حساب ما إله نوع محفوظ): بيروح لـ "نوع الحساب" — ومن الدخول: لواجهته
// -------------------------------------------------------------
abstract final class GoogleSignInController {
  static Future<void>? _init;

  static Future<void> _initialize() => _init ??= GoogleSignIn.instance.initialize(
        clientId: Platform.isIOS ? GoogleAuthConfig.iosClientId : null,
        serverClientId: GoogleAuthConfig.webClientId.isEmpty ? null : GoogleAuthConfig.webClientId,
      );

  static Future<void> signIn(BuildContext context, {required bool newAccount, required ValueChanged<bool> setLoading}) async {
    // Android بدون Web Client ID: التوكن ما بيوصل بجمهور بيعرفه السيرفر
    if (Platform.isAndroid && GoogleAuthConfig.webClientId.isEmpty) {
      AuthController.showMessage(context, AuthMessagesText.googleNotReady());
      return;
    }
    final GoogleSignInAccount account;
    try {
      await _initialize();
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled && context.mounted) AuthController.showMessage(context, AuthMessagesText.googleFailed());
      return;
    } catch (_) {
      _init = null;
      if (context.mounted) AuthController.showMessage(context, AuthMessagesText.googleFailed());
      return;
    }
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      if (context.mounted) AuthController.showMessage(context, AuthMessagesText.googleFailed());
      return;
    }

    setLoading(true);
    try {
      final response = await AuthApiService.google(idToken: idToken);
      if (response.statusCode != 200) {
        setLoading(false);
        await GoogleSignIn.instance.signOut();
        if (!context.mounted) return;
        // 400 = الـ Client IDs لسا مش مضبوطة بالسيرفر — 401 ExternalEmailNotVerified = بريد Google مش مؤكد
        final message = response.statusCode == 400
            ? AuthMessagesText.googleNotReady()
            : response.body.contains('ExternalEmailNotVerified') || response.body.toLowerCase().contains('not verified')
                ? AuthMessagesText.googleEmailNotVerified()
                : AuthMessagesText.googleFailed();
        AuthController.showMessage(context, message);
        return;
      }
      final tokens = TokenStorage.extractTokens(response.body);
      await TokenStorage.saveTokens(accessToken: tokens['accessToken'], refreshToken: tokens['refreshToken']);
      await AuthSession.saveFromResponse(response.body);
      final email = (await AuthSession.current())?.email ?? account.email;
      newAccount ? await AccountRegistry.registered(email) : await AccountRegistry.signedIn(email);
      final home = await AuthController.homeScreen();
      setLoading(false);
      if (!context.mounted) return;
      if (home == null) {
        AuthController.showMessage(context, AuthMessagesText.dashboardOnly());
        return;
      }
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => home), (route) => false);
    } catch (_) {
      setLoading(false);
      if (context.mounted) AuthController.showMessage(context, AuthMessagesText.googleFailed());
    }
  }
}
