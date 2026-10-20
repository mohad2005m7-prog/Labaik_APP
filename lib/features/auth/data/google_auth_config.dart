// -------------------------------------------------------------
// تسجيل الدخول بـ Google — معرّفات Google Cloud (مش أسرار):
//   iOS: بيطلع ID token جمهوره هالمعرّف (ومكتوب كمان بـ ios/Runner/Info.plist)
//   Android: لازم Web Client ID كـ serverClientId (حتى يحمل التوكن جمهور بيعرفه السيرفر)
//   Android Client ID نفسه ما بينكتب بالكود: Google بيتعرّف على التطبيق من اسم الحزمة وبصمة SHA-1
// والسيرفر لازم يكون ضابط نفس المعرّفات بإعداداته (وإلا بيرجّع 400 "Google sign-in is not available")
// -------------------------------------------------------------
abstract final class GoogleAuthConfig {
  static const iosClientId = '917896923874-umei7rgbtp8uru0lulc3o9n30n0524ir.apps.googleusercontent.com';

  /// Web Client ID — جمهور التوكن على Android (serverClientId) — والسيرفر بيقبله كمان
  static const webClientId = '917896923874-7gpjas419i0b05ef8n25s9t6nfervr1i.apps.googleusercontent.com';
}
