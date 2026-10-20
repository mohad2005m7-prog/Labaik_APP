import '../../../../core/l10n/tx.dart';

/// نصوص الملف الشخصي للشركة وشاشاته (Figma 27.Profile 618:3451، تعديل بيانات الشركة 633:3772،
/// معلومات التواصل 672:4061، إدارة المشرفين 672:4107، إضافة مشرف 681:4159، المساعدة 698:4428، الإعدادات 685:4306)
abstract final class CompanyProfileText {
  // الملف الشخصي
  static const title = Tx('ملفي الشخصي', 'My Profile');
  static const active = Tx('الحساب مفعّل', 'Account active');
  static const companyData = Tx('بيانات الشركة', 'Company data');
  static const licenseNumber = Tx('رقم الترخيص:', 'License No.:');
  static const country = Tx('الدولة:', 'Country:');
  static const city = Tx('المدينة', 'City');
  static const accountManagement = Tx('إدارة الحساب', 'Account management');
  static const contactInfo = Tx('معلومات التواصل', 'Contact information');
  static const supervisors = Tx('إدارة المشرفين', 'Manage supervisors');
  static const help = Tx('المساعدة والدعم', 'Help & support');
  static const loadFailed = Tx('تعذّر تحميل بيانات الشركة — اضغط للمحاولة مرة أخرى', "Couldn't load the company data — tap to retry");

  // تعديل بيانات الشركة
  static const editTitle = Tx('تعديل بيانات الشركة', 'Edit Company Data');
  static const companyName = Tx('اسم الشركة :', 'Company name:');
  static const companyNameHint = Tx('شركة الهدى للحج والعمرة', 'Al Huda Hajj & Umrah');
  static const logo = Tx('شعار الشركة', 'Company logo');
  static const licenseLabel = Tx('رقم الترخيص :', 'License number:');
  static const licenseHint = Tx('LAB-2026-014', 'LAB-2026-014');
  static const countryLabel = Tx('الدولة :', 'Country:');
  static const countryHint = Tx('اختر الدولة', 'Choose the country');
  static const cityLabel = Tx('المدينة', 'City');
  static const cityHint = Tx('اكتب المدينة', 'Enter the city');
  static const save = Tx('حفظ التعديلات', 'Save changes');
  static const saved = Tx('تم حفظ التعديلات', 'Changes saved');
  static const required = Tx('اسم الشركة ورقم الترخيص واسم المسؤول مطلوبين', 'Company name, license number and contact name are required');
  static const licenseTaken = Tx('رقم الترخيص مستخدم لشركة ثانية', 'This license number is used by another company');
  static const logoSoon = Tx('رفع الشعار بيشتغل لما يضيف السيرفر رفع الملفات', 'Logo upload works once the server supports file uploads');

  // معلومات التواصل
  static const officialEmail = Tx('البريد الإلكتروني الرسمي', 'Official email');
  static const phone = Tx('رقم الهاتف', 'Phone number');
  static const contactName = Tx('اسم مسؤول الشركة', 'Company contact name');
  static const emailHint = Tx('info@example.com', 'info@example.com');
  static const phoneHint = Tx('0592222222', '0592222222');
  static const contactNameHint = Tx('الاسم الكامل', 'Full name');

  // إدارة المشرفين
  static const searchSupervisors = Tx('بحث عن مشرف', 'Search supervisors');
  static const supervisorsSection = Tx('المشرفون', 'Supervisors');
  static const showAll = Tx('عرض الكل', 'Show all');
  static const groupSupervisor = Tx('مشرف مجموعة', 'Group supervisor');
  static const noGroup = Tx('بلا مجموعة', 'No group');
  static String groupsCount(int n) => n <= 1 ? groupSupervisor() : tr('مشرف $n مجموعات', 'Supervises $n groups');
  static const noSupervisors = Tx('لا يوجد مشرفين بعد', 'No supervisors yet');
  static const addSupervisor = Tx('إضافة مشرف', 'Add supervisor');

  // تفاصيل المشرف (التحكم)
  static const supervisorTitle = Tx('بيانات المشرف', 'Supervisor');
  static const suspendedBadge = Tx('الحساب موقوف', 'Account suspended');
  static const activeBadge = Tx('الحساب مفعّل', 'Account active');
  static const emailLabel = Tx('البريد الإلكتروني', 'Email');
  static const phoneLabel = Tx('رقم الهاتف', 'Phone');
  static const groupsLabel = Tx('المجموعات', 'Groups');
  static const noGroups = Tx('لا يشرف على أي مجموعة بعد', 'Not supervising any group yet');
  static const actions = Tx('التحكم بالحساب', 'Account control');
  static const tempPassword = Tx('إصدار كلمة مرور مؤقتة', 'Issue a temporary password');
  static const tempPasswordDone = Tx('تم إرسال كلمة مرور مؤقتة جديدة إلى بريد المشرف، وسيُطلب منه تغييرها عند أول دخول', 'A new temporary password was emailed to the supervisor; they will be asked to change it at first sign-in');
  static String tempPasswordValue(Object p) => tr('كلمة المرور المؤقتة: $p', 'Temporary password: $p');
  static const suspend = Tx('إيقاف الحساب', 'Suspend account');
  static const resume = Tx('تفعيل الحساب', 'Reactivate account');
  static const suspendConfirm = Tx('إيقاف حساب المشرف؟ لن يستطيع تسجيل الدخول حتى تعيد تفعيله.', "Suspend this supervisor? They can't log in until you reactivate them.");
  static const suspended = Tx('تم إيقاف الحساب', 'Account suspended');
  static const resumed = Tx('تم تفعيل الحساب', 'Account reactivated');
  static const remove = Tx('حذف من الشركة', 'Remove from company');
  static const removeConfirm = Tx('حذف المشرف من قائمة الشركة؟ لازم أولاً تغيّر مشرف مجموعاته.', 'Remove this supervisor from your company? Reassign their groups first.');
  static const removed = Tx('تم حذف المشرف', 'Supervisor removed');
  static const removeHasGroups = Tx('المشرف لسا مسؤول عن مجموعات — غيّر مشرفها أولاً', 'Still supervising groups — reassign them first');
  static const notOnServer = Tx('هذه العملية غير متاحة على الخادم بعد (بانتظار إبراهيم)', 'Not available on the server yet');
  static const confirm = Tx('تأكيد', 'Confirm');
  static const cancel = Tx('إلغاء', 'Cancel');
  static const call = Tx('اتصال', 'Call');

  // إضافة مشرف جديد
  static const addTitle = Tx('إضافة مشرف جديد', 'Add New Supervisor');
  static const fullName = Tx('الاسم الكامل *', 'Full name *');
  static const fullNameHint = Tx('الاسم الكامل للمشرف', "Supervisor's full name");
  static const email = Tx('البريد الإلكتروني *', 'Email *');
  static const supervisorEmailHint = Tx('example@email.com', 'example@email.com');
  static const phoneRequired = Tx('رقم الهاتف *', 'Phone number *');
  static const phoneEnter = Tx('أدخل رقم الهاتف', 'Enter the phone number');
  static const inviteNote = Tx('سيتم إرسال دعوة إلى البريد الإلكتروني للمشرف لتفعيل حسابه وتعيين كلمة المرور.', "An invitation will be emailed to the supervisor to activate the account and set a password.");
  static const add = Tx('إضافة المشرف', 'Add Supervisor');
  static const added = Tx('تمت إضافة المشرف ووصلته دعوة على بريده', 'Supervisor added and invited by email');
  static const fillAll = Tx('عبّي الاسم والبريد ورقم الهاتف', 'Fill in the name, email and phone');
  static const invalidEmail = Tx('البريد الإلكتروني غير صحيح', 'Invalid email address');
  static const exists = Tx('هذا المشرف موجود بقائمة الشركة، أو هو حساب الشركة نفسه', "Already on your roster, or it's the company account itself");

  // المساعدة والدعم
  static const to = Tx('إلى', 'To');
  static const supportEmailLabel = Tx('البريد الإلكتروني لدعم لبيك', 'Labaik support email');
  static const subject = Tx('الموضوع', 'Subject');
  static const subjectDefault = Tx('طلب مساعدة بخصوص حساب الشركة', 'Help request about the company account');
  static const message = Tx('نص الرسالة', 'Message');
  static String messageDefault(Object company) => tr(
        'مرحبًا فريق لبيك،\nنواجه مشكلة أو لدينا استفسار بخصوص حساب شركتنا، ونرجو مساعدتنا.\nنوع الطلب: تغيير كلمة المرور / مشكلة في الحساب / استفسار آخر.\nاسم الشركة: $company\nشكرًا لكم.',
        'Hello Labaik team,\nWe have an issue or a question about our company account and would appreciate your help.\nRequest type: password change / account issue / other.\nCompany name: $company\nThank you.',
      );
  static const send = Tx('إرسال', 'Send');
  static const noMailApp = Tx('ما في تطبيق بريد على الجهاز — راسلنا على', 'No mail app on this device — email us at');

  // الإعدادات (Figma 12.Settings للشركة)
  static const settingsTitle = Tx('الإعدادات', 'Settings');
  static const sectionAccount = Tx('الحساب', 'Account');
  static const editCompany = Tx('تعديل بيانات الشركة', 'Edit company data');
  static const changePassword = Tx('تغيير كلمة المرور', 'Change password');
  static const sectionPreferences = Tx('التفضيلات', 'Preferences');
  static const notifications = Tx('إعدادات الإشعارات', 'Notification settings');
  static const appLanguage = Tx('لغة التطبيق', 'App language');
  static const sectionOther = Tx('أخرى', 'Other');
  static const terms = Tx('الشروط والأحكام والسياسات', 'Terms & policies');
  static const helpCenter = Tx('مركز المساعدة والدعم', 'Help & support center');
  static const logout = Tx('تسجيل الخروج', 'Log out');
}
