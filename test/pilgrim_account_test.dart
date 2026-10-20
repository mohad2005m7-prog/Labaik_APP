import 'package:flutter_test/flutter_test.dart';
import 'package:labaik/features/auth/data/account_registry.dart';
import 'package:labaik/features/pilgrim_account/data/pilgrim_account_repository_impl.dart';
import 'package:labaik/features/pilgrim_account/domain/entities/pilgrim_profile.dart';
import 'package:labaik/features/pilgrim_account/presentation/cubits/edit_pilgrim_profile_cubit.dart';
import 'package:labaik/features/pilgrim_account/presentation/l10n/edit_pilgrim_profile_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -------------------------------------------------------------
// حساب المعتمر (الإعدادات وتعديل البيانات): محفوظ لكل حساب لحاله ومنفصل عن بيانات المشرف
// -------------------------------------------------------------
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({'sup_profile': '{"fullName":"مشرف"}'}));

  test('profile and notifications are saved per account and never touch the supervisor data', () async {
    final repo = PilgrimAccountRepositoryImpl();
    await AccountRegistry.signedIn('a@example.com');
    await repo.saveProfile(const PilgrimProfile(fullName: 'أحمد موسى', email: 'a@example.com', phone: '0599891324', gender: PilgrimGender.male));
    await repo.setNotificationsEnabled(false);

    await AccountRegistry.signedIn('b@example.com');
    expect(await repo.savedProfile(), isNull);
    expect(await repo.notificationsEnabled(), isTrue);

    await AccountRegistry.signedIn('a@example.com');
    final saved = await repo.savedProfile();
    expect(saved?.fullName, 'أحمد موسى');
    expect(saved?.gender, PilgrimGender.male);
    expect(await repo.notificationsEnabled(), isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('sup_profile'), '{"fullName":"مشرف"}');
    expect(prefs.getKeys().where((k) => k.contains('profile')), containsAll(['sup_profile', 'pilgrim_profile:a@example.com']));
  });

  test('edit profile: name required, email/phone validated, gender saved', () async {
    await AccountRegistry.signedIn('c@example.com');
    final cubit = EditPilgrimProfileCubit(PilgrimAccountRepositoryImpl());
    await cubit.load();

    await cubit.save(fullName: 'ab', phone: '', email: '');
    expect(cubit.state.error, EditPilgrimProfileText.errorName);

    await cubit.save(fullName: 'سهاد علي', phone: '', email: 'wrong');
    expect(cubit.state.error, EditPilgrimProfileText.errorEmail);

    await cubit.save(fullName: 'سهاد علي', phone: '12', email: '');
    expect(cubit.state.error, EditPilgrimProfileText.errorPhone);

    cubit.setGender(PilgrimGender.female);
    await cubit.save(fullName: 'سهاد علي', phone: '+966 055 987 654', email: 'suhad@example.com');
    expect(cubit.state.status, EditPilgrimStatus.saved);

    final saved = await PilgrimAccountRepositoryImpl().savedProfile();
    expect(saved, const PilgrimProfile(fullName: 'سهاد علي', email: 'suhad@example.com', phone: '+966 055 987 654', gender: PilgrimGender.female));
    await cubit.close();
  });

  test('photo is saved as soon as it is picked or removed (no "save changes" needed)', () async {
    await AccountRegistry.signedIn('d@example.com');
    final cubit = EditPilgrimProfileCubit(_NoCopyRepository());
    await cubit.load();
    await cubit.setPhoto('/photos/me.jpg');
    await cubit.close(); // رجع بالسهم بدون حفظ

    final reopened = EditPilgrimProfileCubit(_NoCopyRepository());
    await reopened.load();
    expect(reopened.state.profile.photo, '/photos/me.jpg');
    expect(reopened.state.profile.fullName, isEmpty); // الاسم ما انحفظ لأنه ما ضغط حفظ

    await reopened.removePhoto();
    await reopened.close();
    expect((await PilgrimAccountRepositoryImpl().savedProfile())?.photo, isNull);
  });
}

/// نفس المستودع بس بدون نسخ ملف الصورة (ما في مجلد تطبيق بالاختبار)
class _NoCopyRepository extends PilgrimAccountRepositoryImpl {
  @override
  Future<String> storePhoto(String sourcePath) async => sourcePath;
}
