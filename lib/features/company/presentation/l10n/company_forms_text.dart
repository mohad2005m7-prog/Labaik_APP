import '../../../../core/l10n/tx.dart';

/// نصوص نماذج الشركة: إنشاء مجموعة، إضافة عضو، المشرفين، ورسائل الحفظ (مش بـ Figma)
abstract final class CompanyFormsText {
  // عامة
  static const fillRequired = Tx('عبّي الحقول المطلوبة', 'Please fill in the required fields');
  static const invalidEmail = Tx('البريد الإلكتروني غير صحيح', 'Invalid email address');
  static const invalidData = Tx('تحقق من البيانات وحاول مرة أخرى', 'Check the data and try again');
  static const loadFailed = Tx('تعذّر تحميل البيانات', "Couldn't load the data");
  static const retry = Tx('إعادة المحاولة', 'Retry');

  // إنشاء رحلة
  static const tripCreateFailed = Tx('تعذّر إنشاء الرحلة', "Couldn't create the trip");
  static const tripMissing = Tx('عبّي اسم الرحلة والوجهات وتاريخ الذهاب ومكان الانطلاق والعدد', 'Fill in the name, destinations, departure date, departure place and count');
  static const returnBeforeDeparture = Tx('تاريخ العودة لازم يكون بعد تاريخ الذهاب', 'Return date must be after the departure date');

  // إنشاء مجموعة
  static const createGroupTitle = Tx('إنشاء مجموعة', 'Create group');
  static const createGroupSubtitle = Tx('بعد الإنشاء بيطلعلك رمز المجموعة — شاركه مع المعتمرين حتى ينضموا', 'You get a join code after creating — share it with pilgrims');
  static const trip = Tx('الرحلة :', 'Trip:');
  static const groupName = Tx('اسم المجموعة :', 'Group name:');
  static const groupNameHint = Tx('مجموعة أ', 'Group A');
  static const create = Tx('إنشاء', 'Create');
  static const needTripFirst = Tx('أنشئ رحلة أولاً، وبعدها أضف مجموعاتها', 'Create a trip first, then add its groups');
  static String groupCreated(Object code) => tr('تم إنشاء المجموعة — رمزها $code', 'Group created — code $code');

  // إضافة عضو
  static const addMemberTitle = Tx('إضافة معتمر', 'Add pilgrim');
  static const addMemberSubtitle = Tx('لو ما عنده حساب، بنعمله حساب وبتوصله كلمة مرور مؤقتة على بريده', "If they have no account, one is created and a temporary password is emailed");
  static const email = Tx('البريد الإلكتروني :', 'Email:');
  static const emailHint = Tx('name@example.com', 'name@example.com');
  static const fullName = Tx('الاسم الكامل (اختياري) :', 'Full name (optional):');
  static const fullNameRequired = Tx('الاسم الكامل :', 'Full name:');
  static const fullNameHint = Tx('أحمد علي', 'Ahmad Ali');
  static const phone = Tx('رقم الجوال (اختياري) :', 'Phone (optional):');
  static const phoneHint = Tx('+966 5x xxx xxxx', '+966 5x xxx xxxx');
  static const add = Tx('إضافة', 'Add');
  static const memberExists = Tx('هذا الشخص عضو بالمجموعة من قبل', 'Already a member of this group');
  static const noMembers = Tx('لا يوجد أعضاء بعد', 'No members yet');
  static const memberAdded = Tx('تمت إضافة العضو', 'Member added');

  // المشرفين
  static const assignTitle = Tx('مشرف المجموعة', 'Group supervisor');
  static const assignSubtitle = Tx('اختر مشرف من مشرفي الشركة', "Pick one of your company's supervisors");
  static const supervisor = Tx('المشرف :', 'Supervisor:');
  static const assign = Tx('تعيين', 'Assign');
  static const assigned = Tx('تم تعيين المشرف', 'Supervisor assigned');
  static const newSupervisor = Tx('إضافة مشرف جديد', 'Add a new supervisor');
  static const newSupervisorSubtitle = Tx('بتوصله كلمة مرور مؤقتة على بريده، وبيدخل من التطبيق كمشرف', 'They get a temporary password by email and log in as a supervisor');
  static const supervisorExists = Tx('هذا المشرف موجود بقائمة الشركة، أو هو حساب الشركة نفسه', "Already on your roster, or it's the company account itself");
  static const supervisorNotOnRoster = Tx('المشرف مش موجود بقائمة الشركة', 'Supervisor is not on your roster');
  static const supervisorAdded = Tx('تمت إضافة المشرف', 'Supervisor added');
  static const noSupervisor = Tx('بلا مشرف بعد', 'No supervisor yet');
  static String supervisorLine(Object name) => tr('المشرف: $name', 'Supervisor: $name');

  // تفاصيل المجموعة
  static const joinCode = Tx('رمز الانضمام', 'Join code');
  static const codeCopied = Tx('تم نسخ الرمز', 'Code copied');
  static const supervisorAction = Tx('المشرف', 'Supervisor');

  // صفحة العضو
  static const supervisorRole = Tx('مشرف المجموعة', 'Group supervisor');
  static String pilgrimNumber(Object n) => tr('معتمر رقم $n', 'Pilgrim #$n');
  static const pilgrim = Tx('معتمر', 'Pilgrim');
  static const present = Tx('حاضر', 'Present');
  static const absent = Tx('غير حاضر', 'Absent');
  static const nationality = Tx('الجنسية', 'Nationality');
  static const healthNotes = Tx('ملاحظات صحية', 'Health notes');
  static const notes = Tx('ملاحظات', 'Notes');
  static const attendance = Tx('الحضور', 'Attendance');

  // كل الحجاج والمعتمرين (كرت "حجاج / معتمرين" بالرئيسية)
  static const pilgrimsTitle = Tx('الحجاج والمعتمرون', 'Pilgrims');
  static const searchPilgrims = Tx('بحث بالاسم أو الإيميل', 'Search by name or email');
  static const noPilgrims = Tx('لا يوجد حجاج أو معتمرون بعد', 'No pilgrims yet');
  static String pilgrimsCount(int n) => tr('العدد: $n', 'Total: $n');
  static const supervisorNotFound = Tx('هذا المشرف غير موجود في قائمة مشرفي الشركة', 'This supervisor is not on the company roster');
  static const chooseGroup = Tx('اختر المجموعة', 'Choose a group');
  static const pickPilgrim = Tx('اختر معتمراً من معتمري الشركة', 'Choose one of your pilgrims');
  static const addByEmail = Tx('+ إضافة معتمر جديد بالإيميل', '+ Add a new pilgrim by email');
  static const noEmail = Tx('لا يوجد بريد إلكتروني لهذا المعتمر', 'This pilgrim has no email');
}
