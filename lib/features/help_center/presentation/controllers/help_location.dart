import 'package:flutter/material.dart';

import '../../../../core/utils/geo_utils.dart';
import '../../../../core/utils/location_service.dart';
import '../l10n/help_messages_text.dart';

// -------------------------------------------------------------
// الموقع الحالي الفعلي (GPS) لإرساله للمشرف أو إرفاقه بالبلاغ
// بيطلب الصلاحية لو لازم — ولو الموقع مطفي أو مرفوض نهائياً بيعرض زر "الإعدادات"
// -------------------------------------------------------------
abstract final class HelpLocation {
  static Future<GeoPoint?> current(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final access = await LocationService.requestAccess();
    if (access != LocationAccess.granted) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(HelpMessagesText.locationDenied()),
            action: access == LocationAccess.denied ? null : SnackBarAction(label: HelpMessagesText.settings(), onPressed: () => LocationService.openSettings(access)),
          ),
        );
      return null;
    }
    final point = await LocationService.currentPosition() ?? await LocationService.lastKnownPosition();
    if (point == null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(HelpMessagesText.locationFailed())));
    }
    return point;
  }
}
