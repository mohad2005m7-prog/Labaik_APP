// -------------------------------------------------------------
// نقاط الوصول البرّية (للقادمين بسيارة خاصة)
// مقسّمة حسب الدولة التي قدم منها المعتمر. تُخزَّن القيمة بالاسم.
// -------------------------------------------------------------
class ArrivalPointGroup {
  final String country; // اسم الدولة (رأس المجموعة)
  final List<String> points; // المنافذ التابعة لها

  const ArrivalPointGroup({required this.country, required this.points});
}

class ArrivalPointsData {
  static const List<ArrivalPointGroup> groups = [
    ArrivalPointGroup(
      country: 'القادمون من الإمارات وسلطنة عُمان',
      points: ['منفذ البطحاء', 'منفذ الربع الخالي'],
    ),
    ArrivalPointGroup(
      country: 'القادمون من دولة قطر',
      points: ['منفذ سلوى'],
    ),
    ArrivalPointGroup(
      country: 'القادمون من دولة الكويت',
      points: ['المنفذ الرقعي', 'منفذ الخفجي'],
    ),
    ArrivalPointGroup(
      country: 'القادمون من مملكة البحرين',
      points: ['منفذ جسر الملك فهد'],
    ),
    ArrivalPointGroup(
      country: 'القادمون من الأردن (ومن يمر عبرها من الشام ومصر)',
      points: ['منفذ الحديثة', 'منفذ حالة عمار', 'منفذ الدرة'],
    ),
    ArrivalPointGroup(
      country: 'القادمون من جمهورية العراق',
      points: ['منفذ جديدة عرعر'],
    ),
    ArrivalPointGroup(
      country: 'القادمون من الجمهورية اليمنية',
      points: ['منفذ الوديعة', 'منفذ الخضراء', 'منفذ علب', 'منفذ الطوال'],
    ),
  ];
}
