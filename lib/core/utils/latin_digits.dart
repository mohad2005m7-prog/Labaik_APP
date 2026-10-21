/// الأرقام العربية (٠-٩) والفارسية (۰-۹) → لاتينية — حتى "٤٠" من كيبورد عربي تنقرأ رقم
String latinDigits(String text) {
  const eastern = '٠١٢٣٤٥٦٧٨٩', persian = '۰۱۲۳۴۵۶۷۸۹';
  final out = StringBuffer();
  for (final ch in text.split('')) {
    final i = eastern.indexOf(ch);
    final j = persian.indexOf(ch);
    out.write(i >= 0 ? '$i' : j >= 0 ? '$j' : ch);
  }
  return out.toString();
}
