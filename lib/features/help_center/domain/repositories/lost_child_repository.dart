import '../entities/lost_child_report.dart';

// -------------------------------------------------------------
// إرسال بلاغ الطفل المفقود للمشرف (ولمستخدمي التطبيق القريبين لو وافق على المشاركة)
// -------------------------------------------------------------
abstract class LostChildRepository {
  /// ApiException لو فشل الإرسال
  Future<void> submit(LostChildReport report, {required bool shareWithNearby});
}
