import '../../../../core/l10n/tx.dart';

/// نصوص شاشة منفذ الدخول
abstract final class EntryPortText {
  static const title = Tx('ما منفذ دخولك؟', 'What is your entry port?');
  static const description = Tx('اختر منفذ الدخول الذي ستستخدمه للوصول إلى السعودية.', 'Choose the entry port you will use to reach Saudi Arabia.');
  static const chooseFirst = Tx('الرجاء اختيار منفذ الدخول أولاً', 'Please choose your entry port first');
  static const search = Tx('ابحث عن منفذ دخولك', 'Search for your entry port');
}
