import '../../../../core/l10n/tx.dart';

/// نصوص "لائحة أفراد عائلتي" (111:5255 و 111:5373) — بنفس كتابة Figma
abstract final class FamilyMembersText {
  static const title = Tx('أفراد عائلتي', 'My family');
  static const subtitle = Tx('عائلتك قريبة منك أثناء الرحلة 🤍', 'Your family is close during the trip 🤍');
  static const search = Tx('بحث', 'Search');

  /// اسمي بكرتي
  static const me = Tx('انت', 'You');

  static const locationAvailable = Tx('موقعه متاح', 'Location available');
  static const locationUnavailable = Tx('موقعه غير متاح', 'Location unavailable');
  static const locationNotShared = Tx('لم يشارك موقعه', "Hasn't shared location");

  static const online = Tx('متصل الان', 'Online now');

  /// "اخر ظهور 18 د" — د دقايق، س ساعات، ي أيام
  static String lastSeen(DateTime? at, {DateTime? now}) {
    if (at == null) return tr('غير متصل', 'Offline');
    final gap = (now ?? DateTime.now()).difference(at);
    if (gap.inMinutes < 60) return tr('اخر ظهور ${gap.inMinutes < 1 ? 1 : gap.inMinutes} د', 'Last seen ${gap.inMinutes < 1 ? 1 : gap.inMinutes} m');
    if (gap.inHours < 24) return tr('اخر ظهور ${gap.inHours} س', 'Last seen ${gap.inHours} h');
    return tr('اخر ظهور ${gap.inDays} ي', 'Last seen ${gap.inDays} d');
  }

  // قائمة الثلاث نقاط
  static const startChat = Tx('بدء محادثة', 'Start chat');
  static const showLocation = Tx('عرض الموقع', 'Show location');
  static const remove = Tx('حذف من الدائرة', 'Remove from circle');

  // بقائمة كرتي (مش بـ Figma): إيقاف/تشغيل مشاركة موقعي بأي وقت (زي ما بتقول شاشة الموافقة)
  static const stopSharing = Tx('إيقاف مشاركة موقعي', 'Stop sharing location');
  static const startSharing = Tx('مشاركة موقعي', 'Share my location');

  static const showOnMap = Tx('عرض قائمة أفراد العائلة على الخريطة', 'Show family on the map');
  static const showMeetingPoint = Tx('عرض نقطة التجمع', 'Show meeting point');

  // مش بـ Figma
  static const empty = Tx('لا يوجد أفراد بعد', 'No members yet');
  static const noResults = Tx('لا توجد نتائج', 'No results');
  static String removeQuestion(String name) => tr('حذف $name من الدائرة؟', 'Remove $name from the circle?');
  static const cancel = Tx('إلغاء', 'Cancel');
  static const confirmRemove = Tx('حذف', 'Remove');
  static Tx removed(String name) => Tx('تم حذف $name من الدائرة', '$name was removed from the circle');
}
