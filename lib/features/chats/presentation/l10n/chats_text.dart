import '../../../../core/l10n/tx.dart';

/// نصوص "قائمة المحادثات" (Figma 111:6879)
abstract final class ChatsText {
  static const title = Tx('المحادثات', 'Chats');
  static const search = Tx('البحث', 'Search');

  // حالات القائمة (مش بـ Figma)
  static const empty = Tx('لا توجد محادثات بعد', 'No chats yet');
  static const noResults = Tx('لا توجد نتائج', 'No results');
  static const location = Tx('📍 موقع', '📍 Location');
  static const mapFailed = Tx('تعذّر فتح الخريطة', "Couldn't open the map");
}
