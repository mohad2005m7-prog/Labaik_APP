import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:labaik/core/network/api_exception.dart';
import 'package:labaik/core/network/api_client.dart';
import 'package:labaik/core/network/session_events.dart';
import 'package:labaik/core/l10n/app_language.dart';
import 'package:labaik/core/utils/token_storage.dart';
import 'package:labaik/features/auth/data/auth_api_service.dart';
import 'package:labaik/features/auth/data/auth_session.dart';
import 'package:labaik/features/auth/presentation/controllers/auth_controller.dart';
import 'package:labaik/features/auth/presentation/pages/create_new_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _jwt(Map<String, Object?> claims) => 'h.${base64Url.encode(utf8.encode(jsonEncode(claims))).replaceAll('=', '')}.s';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLanguage.notifier.value = 'ar';
  });

  test('mustChangePassword comes from the pwd_change claim in the access token', () async {
    expect(await AuthSession.mustChangePassword(), isFalse);
    await TokenStorage.saveTokens(accessToken: _jwt({'sub': 'u1', 'pwd_change': 'true'}), refreshToken: 'r');
    expect(await AuthSession.mustChangePassword(), isTrue);
    await TokenStorage.saveTokens(accessToken: _jwt({'sub': 'u1'}), refreshToken: 'r2');
    expect(await AuthSession.mustChangePassword(), isFalse);
  });

  test('server error code is read from ProblemDetails', () {
    expect(AuthApiService.errorCode('{"title":"x","code":"Supervisor.Suspended"}'), 'Supervisor.Suspended');
    expect(AuthApiService.errorCode('not json'), isNull);
    expect(AuthApiService.errorCode(''), isNull);
  });

  test('a signed-in account with a temporary password opens the required change screen', () async {
    await TokenStorage.saveTokens(accessToken: _jwt({'sub': 'u1', 'pwd_change': 'true'}), refreshToken: 'r');
    final screen = await AuthController.initialScreen();
    expect(screen, isA<CreateNewPasswordScreen>());
    expect((screen as CreateNewPasswordScreen).forced, isTrue);
  });

  testWidgets('forced change: no back, temporary-password note, sign out instead of forgot, validation', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: Directionality(textDirection: TextDirection.rtl, child: CreateNewPasswordScreen.change(forced: true, knownPassword: 'Tmp#2026ab'))));
    await tester.pumpAndSettle();
    Finder text(String v) => find.text(v, findRichText: true);
    expect(text('تم إنشاء حسابك بكلمة مرور مؤقتة، يرجى تغييرها للمتابعة'), findsOneWidget);
    expect(text('تسجيل الخروج'), findsOneWidget);
    expect(text('نسيت كلمة المرور؟'), findsNothing);
    expect(find.text('Tmp#2026ab'), findsOneWidget); // المؤقتة مكتوبة بالحقل (مخفية)
    await tester.tap(text('تحديث كلمة المرور'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(text('يرجى إدخال كلمة المرور الجديدة'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(1), 'Tmp#2026ab');
    await tester.enterText(find.byType(TextField).at(2), 'Tmp#2026ab');
    await tester.tap(text('تحديث كلمة المرور'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(text('كلمة المرور الجديدة لازم تختلف عن الحالية'), findsOneWidget);
  });

  testWidgets('password reset: the code goes to the new password screen (reset-password checks it), no verify-email call', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (c) {
      ctx = c;
      return const SizedBox();
    })));
    var loading = false;
    await AuthController.verifyEmail(context: ctx, email: 'sup@x.test', code: '123456', isPasswordReset: true, setLoading: (v) => loading = v);
    await tester.pumpAndSettle();
    final screen = tester.widget<CreateNewPasswordScreen>(find.byType(CreateNewPasswordScreen));
    expect((screen.email, screen.code, screen.isChange, loading), ('sup@x.test', '123456', false, false));
  });

  test('session ended: a 401 after refresh and 403 Auth.PasswordChangeRequired reach the handler once', () async {
    final codes = <String?>[];
    SessionEvents.handler = codes.add;
    addTearDown(() {
      SessionEvents.handler = null;
      SessionEvents.reset();
    });
    ApiClient client(int status, String? code) => ApiClient(
          baseUrl: 'https://x/api/v1',
          accessToken: () async => 't',
          refreshToken: () async => null,
          client: MockClient((_) async => http.Response(jsonEncode({'status': status, 'code': ?code}), status, headers: {'content-type': 'application/json'})),
        );
    await expectLater(client(401, null).getJson('/supervisor/groups'), throwsA(isA<ApiException>()));
    await expectLater(client(401, null).getJson('/home'), throwsA(isA<ApiException>()));
    expect(codes, ['Auth.Unauthorized']); // مرة وحدة لحد ما يدخل من جديد
    SessionEvents.reset();
    await expectLater(client(403, 'Auth.PasswordChangeRequired').getJson('/home'), throwsA(isA<ApiException>()));
    expect(codes.last, 'Auth.PasswordChangeRequired');
    SessionEvents.reset();
    await expectLater(client(403, 'Company.ServiceDisabled').getJson('/chats'), throwsA(isA<ApiException>()));
    expect(codes, hasLength(2)); // خدمة مقفلة مش انتهاء جلسة
  });
}
