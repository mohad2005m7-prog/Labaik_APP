import 'field_destination.dart';
import 'ihram_status.dart';

// -------------------------------------------------------------
// بيانات وضع الميدان — مخزن واحد مشترك بين شاشات وضع الميدان.
// كل شاشة بتحفظ اختيار المستخدم هون، والشاشات اللي بعدها بتقرأ منه.
// -------------------------------------------------------------
class FieldModeData {
  FieldModeData._();
  static final FieldModeData instance = FieldModeData._();

  IhramStatus? ihramStatus; // "ما حالة إحرامك؟"
  FieldDestination? chosenDestination; // "أين تريد التوجه الآن؟" (الفندق / المسجد الحرام)
}
