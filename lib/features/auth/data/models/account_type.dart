// نوع الحساب الذي يختاره المستخدم بعد تأكيد التسجيل مباشرة
enum AccountType { pilgrim, groupSupervisor }

extension AccountTypeLabel on AccountType {
  String get arabicLabel {
    switch (this) {
      case AccountType.pilgrim:
        return 'معتمر / حاج';
      case AccountType.groupSupervisor:
        return 'مشرف المجموعة';
    }
  }
}