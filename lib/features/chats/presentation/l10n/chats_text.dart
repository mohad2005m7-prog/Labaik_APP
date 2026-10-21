import '../../../../core/l10n/tx.dart';

/// نصوص "قائمة المحادثات" (Figma 111:6879)
abstract final class ChatsText {
  static const title = Tx('المحادثات', 'Chats');
  static const search = Tx('البحث', 'Search');

  // حالات القائمة (مش بـ Figma)
  static const empty = Tx('لا توجد محادثات بعد', 'No chats yet');
  static const noResults = Tx('لا توجد نتائج', 'No results');
  static const location = Tx('📍 موقع', '📍 Location');
  // الضغط المطوّل على محادثة
  static const pin = Tx('تثبيت المحادثة', 'Pin chat');
  static const unpin = Tx('إلغاء التثبيت', 'Unpin chat');
  static const markRead = Tx('تعليم كمقروءة', 'Mark as read');
  static const mapFailed = Tx('تعذّر فتح الخريطة', "Couldn't open the map");
}
