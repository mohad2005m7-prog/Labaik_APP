import 'account_type.dart';
import 'arrival_method_enum.dart';
import 'stay_type.dart';
import 'trip_type.dart';

// -------------------------------------------------------------
// بيانات إعداد الرحلة — مخزن واحد مشترك بين شاشات الإعداد.
// كل شاشة بتحفظ اختيار المستخدم هون، والشاشات اللي بعدها بتقرأ منه.
// -------------------------------------------------------------
class TripSetupData {
  TripSetupData._();
  static final TripSetupData instance = TripSetupData._();

  AccountType? accountType; // نوع الحساب
  TripType? tripType; // نوع الرحلة
  bool? locationEnabled; // هل اختار تفعيل الموقع

  ArrivalMethod? arrivalMethod; // طائرة / حافلة / سيارة
  String? arrivalPlace; // رمز المطار أو اسم المنفذ/نقطة الوصول

  // المدن اللي اختارها المستخدم بشاشة "ما مسار رحلتك؟" (بالترتيب)
  List<String> routeCities = [];

  // نوع الإقامة لكل مدينة (فندق / مكان اخر)
  final Map<String, StayType?> stayTypes = {};

  // مكان الإقامة الفعلي لكل مدينة (اسم الفندق أو المكان)
  final Map<String, String?> stayPlaces = {};

  bool stayNotDecided = false;

  // حسب Figma: لو ما اختار مدن، بنعرض المدينة المنورة ومكة المكرمة
  List<String> get stayCities =>
      routeCities.isEmpty ? const ['المدينة المنورة', 'مكة المكرمة'] : routeCities;
}
