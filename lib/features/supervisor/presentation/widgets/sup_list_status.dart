import 'package:flutter/material.dart';

import '../../../../core/l10n/tx.dart';
import 'supervisor_colors.dart';

/// نصوص حالة القوائم (مش بـ Figma)
abstract final class SupListStatusText {
  static const failed = Tx('تعذّر تحميل البيانات، تحقق من اتصالك', "Couldn't load the data, check your connection");
  static const retry = Tx('إعادة المحاولة', 'Try again');
  static const noGroups = Tx('لم تتم إضافتك كمشرف لأي مجموعة بعد', "You haven't been added as a supervisor to any group yet");
  static const noChats = Tx('لا توجد محادثات بعد', 'No chats yet');
  static const noNotifications = Tx('لا توجد إشعارات بعد', 'No notifications yet');
  static const noAnnouncements = Tx('لا توجد إعلانات سابقة', 'No previous announcements');
  static const noMembers = Tx('لا يوجد معتمرون هنا', 'No pilgrims here');
}

// -------------------------------------------------------------
// حالة قائمة المشرف بدل الفراغ: قبل ما يرد السيرفر دائرة تحميل — فشل وما في بيانات: رسالة + "إعادة المحاولة"
// — وصل وفاضي: [empty] — وفيه بيانات: ولا إشي (القائمة نفسها بتنعرض)
// -------------------------------------------------------------
class SupListStatus extends StatelessWidget {
  final bool loaded;
  final bool failed;
  final bool isEmpty;
  final Tx empty;
  final VoidCallback onRetry;

  const SupListStatus({super.key, required this.loaded, required this.failed, required this.isEmpty, required this.empty, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (!isEmpty) return const SizedBox.shrink();
    const text = TextStyle(fontFamily: 'NotoSansArabic', fontSize: 14, color: Color(0xFF717171));
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!loaded)
            const SizedBox.square(dimension: 32, child: CircularProgressIndicator(strokeWidth: 2.4, color: SupColors.green))
          else if (failed) ...[
            Text(SupListStatusText.failed(), textAlign: TextAlign.center, style: text),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: Text(SupListStatusText.retry(), style: const TextStyle(fontFamily: 'NotoSansArabic', fontWeight: FontWeight.w600, color: SupColors.green))),
          ] else
            Text(empty(), textAlign: TextAlign.center, style: text),
        ],
      ),
    );
  }
}
