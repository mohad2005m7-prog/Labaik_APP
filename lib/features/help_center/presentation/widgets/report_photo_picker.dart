import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/tx.dart';
import '../l10n/help_messages_text.dart';
import '../l10n/lost_child_text.dart';
import 'help_colors.dart';

/// نتيجة اختيار الصورة: مسار الصورة الجديدة أو حذف الحالية
sealed class ReportPhotoChoice {}

class ReportPhotoPicked extends ReportPhotoChoice {
  final String path;

  ReportPhotoPicked(this.path);
}

class ReportPhotoRemoved extends ReportPhotoChoice {}

// -------------------------------------------------------------
// "إرفاق صورة إذا كانت متوفرة": التقاط بالكاميرا أو من الصور (+ حذف الصورة لو في وحدة)
// null = سكّر بدون اختيار
// -------------------------------------------------------------
abstract final class ReportPhotoPicker {
  static final _picker = ImagePicker();

  static Future<ReportPhotoChoice?> pick(BuildContext context, {required bool hasPhoto}) async {
    Widget option(BuildContext sheet, IconData icon, Tx label, Object value, {Color color = HelpColors.green}) => ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label(),
        style: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 16, color: color),
      ),
      onTap: () => Navigator.pop(sheet, value),
    );
    final source = await showModalBottomSheet<Object>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            option(sheet, Icons.photo_camera_outlined, LostChildText.camera, ImageSource.camera),
            option(sheet, Icons.photo_library_outlined, LostChildText.gallery, ImageSource.gallery),
            if (hasPhoto) option(sheet, Icons.delete_outline_rounded, LostChildText.removePhoto, 'remove', color: const Color(0xFFD32F2F)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return null;
    if (source == 'remove') return ReportPhotoRemoved();
    try {
      final file = await _picker.pickImage(source: source as ImageSource, maxWidth: 1600, imageQuality: 85);
      return file == null ? null : ReportPhotoPicked(file.path);
    } on PlatformException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(HelpMessagesText.photoFailed())));
      }
      return null;
    }
  }
}
