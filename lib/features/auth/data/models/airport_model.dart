// موديل يمثل مطاراً واحداً: الرمز الدولي (IATA) + الاسم المعروض للمستخدم
class Airport {
  final String code; // الرمز، مثلاً RUH (هذا ما يُخزَّن ويُرسل للباك اند)
  final String name; // الاسم المعروض للمستخدم بالقائمة

  const Airport({required this.code, required this.name});
}
