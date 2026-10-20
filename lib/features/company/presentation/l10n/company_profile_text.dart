import '../../../../core/l10n/tx.dart';

/// نصوص شاشات الملف الشخصي للشركة: البروفايل، الإعدادات، بيانات الشركة، معلومات التواصل
abstract final class CompanyProfileText {
  // تبويب الملف الشخصي (27.Profile)
  static const accountData = Tx('بيانات الحساب', 'Account Data');
  static const accountSettings = Tx('إعدادات الحساب', 'Account Settings');
  static const companyData = Tx('بيانات الشركة', 'Company Data');
  static const contactInfo = Tx('معلومات التواصل', 'Contact Info');
  static const settings = Tx('الإعدادات', 'Settings');

  // بيانات الشركة (FigmaPage)
  static const companyDataTitle = Tx('بيانات الشركة', 'Company Data');
  static const companyName = Tx('اسم الشركة :', 'Company name:');
  static const licenseNumber = Tx('رقم الترخيص :', 'License number:');
  static const address = Tx('العنوان :', 'Address:');
  static const companyNameHint = Tx('أدخل اسم الشركة', 'Enter company name');
  static const licenseNumberHint = Tx('أدخل رقم الترخيص', 'Enter license number');
  static const addressHint = Tx('أدخل عنوان الشركة', 'Enter company address');
  static const saveButton = Tx('حفظ', 'Save');

  // معلومات التواصل (FigmaPage)
  static const contactTitle = Tx('معلومات التواصل', 'Contact Info');
  static const phone = Tx('رقم الهاتف :', 'Phone number:');
  static const email = Tx('البريد الإلكتروني :', 'Email:');
  static const website = Tx('الموقع الإلكتروني :', 'Website:');
  static const phoneHint = Tx('أدخل رقم الهاتف', 'Enter phone number');
  static const emailHint = Tx('أدخل البريد الإلكتروني', 'Enter email address');
  static const websiteHint = Tx('أدخل رابط الموقع', 'Enter website URL');

  // الإعدادات (FigmaPage frameHeight:938)
  static const settingsTitle = Tx('الإعدادات', 'Settings');
  static const changePassword = Tx('تغيير كلمة المرور', 'Change Password');
  static const notifications = Tx('الإشعارات', 'Notifications');
  static const language = Tx('اللغة', 'Language');
  static const about = Tx('عن التطبيق', 'About App');
  static const privacyPolicy = Tx('سياسة الخصوصية', 'Privacy Policy');
  static const termsOfUse = Tx('شروط الاستخدام', 'Terms of Use');
  static const logout = Tx('تسجيل الخروج', 'Log Out');
}
