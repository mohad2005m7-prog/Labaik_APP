import '../entities/supervisor_contact.dart';

// -------------------------------------------------------------
// مشرف مجموعة المعتمر الحالي
// -------------------------------------------------------------
abstract class SupervisorRepository {
  /// آخر بيانات وصلت من السيرفر ومحفوظة على الجهاز (للاتصال حتى بدون إنترنت)
  Future<SupervisorContact?> cached();

  /// من السيرفر — null = المعتمر لسا مش مربوط بمشرف — ApiException لو فشل الطلب
  Future<SupervisorContact?> fetch();
}
