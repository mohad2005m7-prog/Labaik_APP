import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labaik/core/l10n/app_language.dart';
import 'package:labaik/features/auth/data/account_registry.dart';
import 'package:labaik/features/duas/data/repositories/duas_repository_impl.dart';
import 'package:labaik/features/duas/presentation/controllers/duas_controller.dart';
import 'package:labaik/features/duas/presentation/cubits/dua_form_cubit.dart';
import 'package:labaik/features/duas/presentation/l10n/dua_form_text.dart';
import 'package:labaik/features/duas/presentation/pages/dua_form_screen.dart';
import 'package:labaik/features/duas/presentation/pages/duas_screen.dart';
import 'package:labaik/features/duas/presentation/pages/suggested_dua_screen.dart';
import 'package:labaik/features/duas/presentation/widgets/suggested_dua_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -------------------------------------------------------------
// الأدعية: حفظ أدعية كل حساب لحاله، التعديل والحذف، التحقق من الحقول، والتنقل
// -------------------------------------------------------------
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLanguage.notifier.value = 'ar';
  });

  test('personal duas are saved per account, last edited first; edit and delete', () async {
    final repo = DuasRepositoryImpl();
    await AccountRegistry.signedIn('a@example.com');
    final family = await repo.addDua(title: 'دعاء لأهلي', text: 'اللهم احفظ أهلي');
    await repo.addDua(title: 'دعاء لنفسي', text: 'اللهم اغفر لي');

    await AccountRegistry.signedIn('b@example.com');
    expect(await repo.personalDuas(), isEmpty);

    await AccountRegistry.signedIn('a@example.com');
    expect([for (final d in await repo.personalDuas()) d.title], ['دعاء لنفسي', 'دعاء لأهلي']);

    // التعديل بيغيّر النص وبيطلّعه أول القائمة
    await repo.updateDua(family, title: 'دعاء لأهلي', text: 'اللهم احفظ أهلي وبارك لهم');
    final duas = await repo.personalDuas();
    expect(duas.first.text, 'اللهم احفظ أهلي وبارك لهم');
    expect(duas, hasLength(2));

    await repo.deleteDua(family.id);
    expect([for (final d in await repo.personalDuas()) d.title], ['دعاء لنفسي']);
  });

  test('every suggested dua has a Figma card for each text', () {
    final duas = DuasRepositoryImpl().suggestedDuas();
    expect(duas, hasLength(suggestedDuaLayouts.length));
    for (final dua in duas) {
      expect(dua.texts, hasLength(suggestedDuaLayouts[dua.number - 1].length), reason: 'الدعاء ${dua.number}');
      expect(dua.texts.every((t) => t.trim().isNotEmpty), isTrue);
    }
  });

  test('dua form: title and text are required', () async {
    await AccountRegistry.signedIn('c@example.com');
    final cubit = DuaFormCubit(DuasRepositoryImpl());

    await cubit.save(title: '  ', text: 'نص');
    expect(cubit.state.error, DuaFormText.errorTitle);
    await cubit.save(title: 'عنوان', text: '');
    expect(cubit.state.error, DuaFormText.errorText);

    await cubit.save(title: 'عنوان', text: 'نص الدعاء');
    expect(cubit.state.status, DuaFormStatus.saved);
    expect((await DuasRepositoryImpl().personalDuas()).single.text, 'نص الدعاء');
    await cubit.close();
  });

  testWidgets('flow: home → duas → add/edit return to my duas → delete; suggested → dua screen', (tester) async {
    await AccountRegistry.signedIn('d@example.com');
    // شاشة بحجم إطار Figma (393×852)
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Builder(builder: (context) => Scaffold(body: TextButton(onPressed: () => DuasController.open(context), child: const Text('home')))),
      ),
    ));
    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();
    expect(find.text('أدعيتك الخاصة'), findsOneWidget);

    // إضافة → حفظ الدعاء → سجل أدعيتي
    await tester.tap(find.textContaining('إضافة دعاء'));
    await tester.pumpAndSettle();
    expect(find.text('إضافة دعاء جديد'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'دعاء السفر');
    await tester.enterText(find.byType(TextField).at(1), 'اللهم هون علينا سفرنا هذا');
    await tester.tap(find.text('حفظ الدعاء'));
    await tester.pumpAndSettle();
    expect(find.byType(DuaFormScreen), findsNothing);
    expect(find.byType(DuasScreen), findsOneWidget);
    expect(find.text('دعاء السفر'), findsOneWidget);

    // الضغط على الدعاء → نفس الشاشة فيها نصه → تعديل → سجل أدعيتي
    await tester.tap(find.text('دعاء السفر'));
    await tester.pumpAndSettle();
    expect(find.text('تعديل الدعاء'), findsOneWidget);
    expect(find.text('اللهم هون علينا سفرنا هذا'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'دعاء السفر والرجوع');
    await tester.tap(find.text('حفظ الدعاء'));
    await tester.pumpAndSettle();
    expect(find.text('دعاء السفر والرجوع'), findsOneWidget);

    // ضغطة مطوّلة → حذف → تأكيد
    await tester.longPress(find.text('دعاء السفر والرجوع'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف'));
    await tester.pumpAndSettle();
    expect(find.text('حذف الدعاء؟'), findsOneWidget);
    await tester.tap(find.text('حذف').last);
    await tester.pumpAndSettle();
    expect(find.text('دعاء السفر والرجوع'), findsNothing);
    expect(await DuasRepositoryImpl().personalDuas(), isEmpty);

    await tester.tap(find.text('أدعية مقترحة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الدعاء الأول'));
    await tester.pumpAndSettle();
    expect(find.byType(SuggestedDuaScreen), findsOneWidget);
    expect(find.text('الدعاء الأول'), findsOneWidget);
  });
}
