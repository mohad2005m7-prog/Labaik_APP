import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labaik/core/l10n/app_language.dart';
import 'package:labaik/features/auth/data/account_registry.dart';
import 'package:labaik/features/auth/data/models/arrival_method_enum.dart';
import 'package:labaik/features/auth/data/models/trip_setup_data.dart';
import 'package:labaik/features/auth/data/models/trip_type.dart';
import 'package:labaik/features/auth/presentation/l10n/departure_text.dart';
import 'package:labaik/features/trip_details/data/models/trip_setup_mapper.dart';
import 'package:labaik/features/trip_details/data/repositories/trip_repository_impl.dart';
import 'package:labaik/features/trip_details/domain/entities/trip.dart';
import 'package:labaik/features/trip_details/presentation/controllers/trip_details_controller.dart';
import 'package:labaik/features/trip_details/presentation/l10n/trip_edit_text.dart';
import 'package:labaik/features/trip_details/presentation/pages/edit_departure_screen.dart';
import 'package:labaik/features/trip_details/presentation/pages/trip_details_screen.dart';
import 'package:labaik/features/trip_details/presentation/pages/edit_stay_types_screen.dart';
import 'package:labaik/features/trip_details/presentation/pages/edit_stay_places_screen.dart';
import 'package:labaik/features/trip_details/presentation/pages/edit_about_trip_screen.dart';
import 'package:labaik/features/trip_details/presentation/l10n/trip_stay_text.dart';
import 'package:labaik/features/trip_details/presentation/l10n/trip_about_text.dart';
import 'package:labaik/features/trip_details/presentation/l10n/trip_success_text.dart';
import 'package:labaik/features/auth/presentation/l10n/stay_text.dart';
import 'package:labaik/features/auth/data/models/stay_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labaik/features/trip_details/presentation/cubits/trip_edit_cubit.dart';
import 'package:labaik/features/trip_details/presentation/l10n/trip_picker_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -------------------------------------------------------------
// تفاصيل الرحلة: الحفظ لكل حساب، رحلة إعداد الحساب، وشاشات التعديل لحد الحفظ
// -------------------------------------------------------------
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppLanguage.notifier.value = 'ar';
  });

  test('trip is saved per account and the setup answers become the saved trip', () async {
    final repo = TripRepositoryImpl();
    await AccountRegistry.signedIn('a@example.com');
    final setup = TripSetupData.instance
      ..tripType = TripType.umrah
      ..arrivalMethod = ArrivalMethod.airplane
      ..arrivalPlace = 'MED'
      ..routeCities = ['المدينة المنورة', 'مكة المكرمة']
      ..departureDate = DateTime(2026, 9, 25)
      ..departureMinute = 600;
    await repo.save(setup.toTrip());

    await AccountRegistry.signedIn('b@example.com');
    expect(await repo.load(), Trip.empty);

    await AccountRegistry.signedIn('a@example.com');
    final trip = await repo.load();
    expect(trip.type, TripType.umrah);
    expect(trip.arrivalPlace, 'MED');
    expect(trip.routeCities, ['المدينة المنورة', 'مكة المكرمة']);
    expect(trip.departureDate, DateTime(2026, 9, 25));
    expect(trip.departureMinute, 600);
  });

  testWidgets('details → edit all steps → saved, success → home, details show the new trip', (tester) async {
    await AccountRegistry.signedIn('c@example.com');
    await TripRepositoryImpl().save(const Trip(type: TripType.umrah, arrivalMethod: ArrivalMethod.airplane, arrivalPlace: 'MED'));
    // شاشة بحجم إطار Figma (393×852)
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(onPressed: () => TripDetailsController.open(context), child: const Text('home')),
          ),
        ),
      ),
    );
    Future<void> tap(String text) async {
      await tester.tap(find.text(text).last, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    await tap('home');
    expect(find.byType(TripDetailsScreen), findsOneWidget);
    expect(find.textContaining('رحلتك الحالية : عمرة', findRichText: true), findsOneWidget);
    expect(find.textContaining('مطار الأمير محمد بن عبد العزيز الدولي', findRichText: true), findsOneWidget);

    await tap('تعديل تفاصيل الرحلة');
    await tap('حج');
    await tap('متابعة');
    await tap('حافلة');
    await tap('متابعة');
    // تغيير الوسيلة بيمسح المطار → لازم يختار منفذ
    await tap('التالي');
    expect(find.text('الرجاء اختيار منفذ الدخول أولاً'), findsOneWidget);
    await tap('ابحث عن منفذ دخولك');
    await tap('منفذ الحديثة');
    await tap('التالي');
    await tap('ابحث عن وجهتك الاولى');
    // البحث بقائمة المدن
    await tester.enterText(find.byType(TextField).last, 'المنورة');
    await tester.pumpAndSettle();
    await tap('المدينة المنورة');
    await tap('التالي');
    expect(find.byType(EditDepartureScreen), findsOneWidget);
    await tap('التالي');
    expect(find.text(TripEditText.chooseDeparture()), findsOneWidget);
    await tap(DepartureText.arrivalNotDecided());
    await tap('التالي');

    // أين ستقيم؟ (مدينة المسار) — لازم يختار
    expect(find.byType(EditStayTypesScreen), findsOneWidget);
    expect(find.text(StayText.inCity('المدينة المنورة')), findsOneWidget);
    await tap('التالي');
    expect(find.text(TripStayText.chooseStay()), findsOneWidget);
    await tap(StayText.hotel());
    await tap('التالي');

    // الفندق من قائمة فنادق المدينة
    expect(find.byType(EditStayPlacesScreen), findsOneWidget);
    await tap('التالي');
    expect(find.text(TripStayText.enterStay()), findsOneWidget);
    await tap(StayText.search());
    await tester.enterText(find.byType(TextField).last, 'سوفيتيل');
    await tester.pumpAndSettle();
    await tap('فندق سوفيتيل شهد المدينة');
    await tap('التالي');

    // أخبرنا اكثر عن رحلتك؟ (للحج نفس الجمل بكلمة الحج)
    expect(find.byType(EditAboutTripScreen), findsOneWidget);
    await tap('التالي');
    expect(find.text(TripAboutText.answerAll()), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'محمد');
    await tap(TripAboutText.firstYes(true));
    await tap(TripAboutText.family());
    await tap(TripAboutText.group());
    await tap('التالي');

    // تمت إضافة التفاصيل بنجاح! → الرئيسية
    expect(find.text(TripSuccessText.title()), findsOneWidget);
    await tap(TripSuccessText.goHome());
    expect(find.text('home'), findsOneWidget);
    expect(find.byType(TripDetailsScreen), findsNothing);

    final saved = await TripRepositoryImpl().load();
    expect(saved.type, TripType.hajj);
    expect(saved.arrivalMethod, ArrivalMethod.bus);
    expect(saved.arrivalPlace, 'منفذ الحديثة');
    expect(saved.routeCities, ['المدينة المنورة']);
    expect(saved.departureNotDecided, isTrue);
    expect(saved.stayTypes, {'المدينة المنورة': StayType.hotel});
    expect(saved.stayPlaces, {'المدينة المنورة': 'فندق سوفيتيل شهد المدينة'});
    expect(saved.travelerName, 'محمد');
    expect(saved.firstTime, isTrue);
    expect(saved.companions, {TravelCompanion.family, TravelCompanion.group});

    // الرحلة المحفوظة بتطلع بتفاصيل الرحلة
    await tap('home');
    expect(find.textContaining('رحلتك الحالية : حج', findRichText: true), findsOneWidget);
    expect(find.textContaining('منفذ الحديثة', findRichText: true), findsOneWidget);
  });

  testWidgets('stay places: hotels are a drop list for every city — Riyadh from the source, a typed hotel elsewhere', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);
    const trip = Trip(routeCities: ['الرياض', 'الدرعية'], stayTypes: {'الرياض': StayType.hotel, 'الدرعية': StayType.hotel});
    final cubit = TripEditCubit(TripRepositoryImpl(), trip);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
        home: BlocProvider.value(value: cubit, child: const EditStayPlacesScreen()),
      ),
    );
    Future<void> tap(Finder finder) async {
      await tester.tap(finder, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    // ما في حقول كتابة — الحقلين قوائم منسدلة
    expect(find.byType(TextField), findsNothing);
    await tap(find.text(StayText.search()).first);
    await tap(find.text('فندق الفيصلية'));
    expect(cubit.state.stayPlaces['الرياض'], 'فندق الفيصلية');

    // الدرعية ما إلها فنادق بالمصدر: بيكتب فندقه ويختاره
    await tap(find.text(StayText.search()));
    await tester.enterText(find.byType(TextField).last, 'فندق المثال');
    await tester.pumpAndSettle();
    await tap(find.text(TripPickerText.useTyped('فندق المثال')));
    expect(cubit.state.stayPlaces['الدرعية'], 'فندق المثال');
  });
}
