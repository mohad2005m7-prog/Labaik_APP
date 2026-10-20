import '../../../../core/l10n/tx.dart';

/// نصوص رئيسية المعتمر وشريط التنقل تحت
abstract final class HomeText {
  static const greeting = Tx('السلام عليكم', 'Assalamu Alaikum');
  static String greetingName(Object name) => tr('السلام عليكم، $name', 'Assalamu Alaikum, $name');
  static const welcome = Tx('أهلاً بك في لبيك 🤍', 'Welcome to Labaik 🤍');
  static const readyQuestion = Tx('هل أنت جاهز لنسكك؟', 'Are you ready for your rite?');
  static const fieldMode = Tx('جاهز لوضع الميدان', 'Ready for field mode');
  static const stageTitle = Tx('مرحلة الإستعدادك للعمرة', 'Your Umrah preparation stage');
  static const stageDescription = Tx(
    'راجع أهم ما تحتاج معرفته قبل أداء العمرة، خطوة بخطوة.',
    'Review the most important things you need to know before performing Umrah, step by step.',
  );

  /// الخطوة التالية حسب تقدّم المعتمر بمراحل التعلم ([completed] = عدد المراحل اللي خلصها)
  static String nextStep(int completed) {
    const stages = [('الإحرام', 'Ihram'), ('الطواف', 'Tawaf'), ('السعي', "Sa'i"), ('التحلل', 'Tahallul')];
    if (completed >= stages.length) return tr('أكملت التعلم عن مراحل العمرة', 'You have completed all Umrah stages');
    final (ar, en) = stages[completed];
    return tr('الخطوة التالية : أكمل التعلم عن $ar', 'Next step: continue learning about $en');
  }

  static const continueLearning = Tx('تابع التعلم', 'Continue learning');
  static const assistant = Tx('المساعد الذكي', 'Smart Assistant');
  static const assistantSub = Tx('إجابات موثوقة لرحلتك', 'Reliable answers for your trip');
  static const budget = Tx('الميزانية', 'Budget');
  static const budgetSub = Tx('خطط نفقاتك بذكاء', 'Plan your expenses wisely');
  static const duas = Tx('أدعية', 'Duas');
  static const duasSub = Tx('ادعية من القران والسنة', 'Duas from the Quran and Sunnah');
  static const tripDetails = Tx('تفاصيل الرحلة', 'Trip Details');
  static const tripDetailsSub = Tx('عدل بياناتك بحرية تامة', 'Edit your details freely');
  static const navHome = Tx('الرئيسية', 'Home');
  static const navChats = Tx('الدردشات', 'Chats');
  static const navPeople = Tx('الأفراد', 'Members');
  static const navMap = Tx('الخريطة', 'Map');
  static const navHelp = Tx('مركز المساعدة', 'Help Center');
}
