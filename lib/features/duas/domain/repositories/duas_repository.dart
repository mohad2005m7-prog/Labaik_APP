import '../entities/personal_dua.dart';
import '../entities/suggested_dua.dart';

// -------------------------------------------------------------
// الأدعية: أدعية المعتمر الخاصة (محفوظة لحسابه) + الأدعية المقترحة
// السيرفر لسا ما فيه endpoints للأدعية — فالتطبيق بيحفظ على الجهاز،
// ولما تنضاف بس بتتغير الـ implementation (الشاشات والـ Cubits ما بتتغير)
// -------------------------------------------------------------
abstract class DuasRepository {
  /// أدعية الحساب الحالي — آخر تعديل أول
  Future<List<PersonalDua>> personalDuas();

  Future<PersonalDua> addDua({required String title, required String text});

  /// بيعدّل العنوان والنص وبيحدّث "آخر تعديل"
  Future<PersonalDua> updateDua(PersonalDua dua, {required String title, required String text});

  Future<void> deleteDua(String id);

  List<SuggestedDua> suggestedDuas();
}
