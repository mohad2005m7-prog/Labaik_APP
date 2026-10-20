import '../../../../core/l10n/tx.dart';

/// نصوص شاشة برنامج الرحلة
abstract final class TripProgramText {
  static const title = Tx('برنامج الرحلة', 'Trip program');
  static String day(Object n) => tr('اليوم ($n)', 'Day ($n)');

  // البرنامج فاضي / إضافة نشاط (مش بـ Figma)
  static const empty = Tx('لا يوجد برنامج للرحلة بعد', 'No trip program yet');
  static const emptyHint = Tx('أضف أنشطة الرحلة يوماً بيوم، وبتظهر للمعتمرين وبكرت "الرحلة القادمة"', 'Add the trip activities day by day — pilgrims see them and the "Next trip" card shows the next one');
  static const add = Tx('+ إضافة نشاط', '+ Add activity');
  static const addTitle = Tx('إضافة نشاط للبرنامج', 'Add a program activity');
  static const activityTitle = Tx('اسم النشاط :', 'Activity:');
  static const activityTitleHint = Tx('الاستعداد للعمرة', 'Preparing for Umrah');
  static const date = Tx('اليوم :', 'Day:');
  static const time = Tx('الوقت :', 'Time:');
  static const timeHint = Tx('اختر الوقت', 'Choose the time');
  static const place = Tx('المكان :', 'Place:');
  static const placeHint = Tx('نقطة التجمع', 'Gathering point');
  static const save = Tx('إضافة', 'Add');
  static const needTitle = Tx('اكتب اسم النشاط', 'Enter the activity name');
  static const noTrip = Tx('المجموعة مش مربوطة برحلة — الشركة لازم تنشئها تحت رحلة', 'This group is not linked to a trip');
  static const loadFailed = Tx('تعذّر تحميل البرنامج — اضغط للمحاولة مرة أخرى', "Couldn't load the program — tap to retry");
  static const added = Tx('تمت إضافة النشاط', 'Activity added');
}
