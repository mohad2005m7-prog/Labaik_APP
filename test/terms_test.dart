import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labaik/core/l10n/app_language.dart';
import 'package:labaik/core/utils/figma_canvas.dart';
import 'package:labaik/features/auth/data/account_registry.dart';
import 'package:labaik/features/pilgrim_account/data/pilgrim_account_repository_impl.dart';
import 'package:labaik/features/pilgrim_account/presentation/pages/pilgrim_settings_screen.dart';
import 'package:labaik/features/terms/presentation/pages/terms_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -------------------------------------------------------------
// الشروط والأحكام: بتنفتح من إعدادات المعتمر، والتبويب المختار بيعلّم كرته (حد أخضر كامل)
// -------------------------------------------------------------
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLanguage.notifier.value = 'ar';
  });

  testWidgets('settings → terms; each tab highlights its card', (tester) async {
    await AccountRegistry.signedIn('t@example.com');
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    tester.view.viewPadding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
        home: PilgrimSettingsScreen(repository: PilgrimAccountRepositoryImpl()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('الشروط والأحكام والسياسات'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(TermsScreen), findsOneWidget);
    expect(find.text('سياسة الخصوصية'), findsOneWidget);
    expect(find.textContaining('المقدمة:', findRichText: true), findsOneWidget);

    // حدود الكروت بالترتيب: المختار #1F3B2E كامل والباقي 25%
    List<Color> borders() => [
          for (final box in tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)))
            if ((box.decoration! as BoxDecoration).boxShadow != null) ((box.decoration! as BoxDecoration).border! as Border).top.color,
        ];
    expect(borders(), [FigmaCanvas.green, const Color(0x401F3B2E), const Color(0x401F3B2E)]);

    await tester.tap(find.text('سياسة الاسترجاع'));
    await tester.pumpAndSettle();
    expect(borders(), [const Color(0x401F3B2E), const Color(0x401F3B2E), FigmaCanvas.green]);

    // الرجوع للإعدادات
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.byType(TermsScreen), findsNothing);
  });
}
