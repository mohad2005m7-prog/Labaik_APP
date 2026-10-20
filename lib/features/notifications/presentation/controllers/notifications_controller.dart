import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/common_text.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../cubits/notifications_cubit.dart';
import '../pages/notifications_screen.dart';

// -------------------------------------------------------------
// التنقل بالإشعارات (بروتوتايب Figma): جرس الرئيسية (118:10757) → الاشعارات (114:10192)
//   كرت "إعلان جديد للمجموعة" → تفاصيل الإعلان (372:7642) — لسا ما انبنت ("قريباً")
// -------------------------------------------------------------
abstract final class NotificationsController {
  // مصدر البيانات: السيرفر — الاختبارات بتبدّله
  static NotificationsRepository Function() repository = NotificationsRepositoryImpl.new;

  static Future<void> open(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => NotificationsCubit(repository())..start(), child: const NotificationsScreen())),
      );

  /// "تفاصيل الإعلان" للمعتمر لسا ما انبنت
  static void openAnnouncement(BuildContext context, AppNotification notification) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(CommonText.comingSoon()), duration: const Duration(milliseconds: 1600)));
  }
}
