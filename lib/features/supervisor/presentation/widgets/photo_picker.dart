import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/tx.dart';
import '../controllers/supervisor_controller.dart';
import '../l10n/photo_picker_text.dart';
import 'supervisor_colors.dart';

// -------------------------------------------------------------
// اختيار صورة: التقاط بالكاميرا أو من المعرض (+ حذف الصورة الحالية لو [onRemove])
// بيرجع مسار الصورة المؤقت (اللي بيستدعيه بينسخها لمجلد التطبيق عن طريق الـ Repository)
// -------------------------------------------------------------
class SupPhotoPicker {
  static final _picker = ImagePicker();

  static Future<String?> pick(BuildContext context, {VoidCallback? onRemove}) async {
    final source = await showModalBottomSheet<Object>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _option(context, Icons.photo_camera_outlined, PhotoPickerText.camera, ImageSource.camera),
            _option(context, Icons.photo_library_outlined, PhotoPickerText.gallery, ImageSource.gallery),
            if (onRemove != null) _option(context, Icons.delete_outline_rounded, PhotoPickerText.remove, 'remove', color: SupColors.red),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return null;
    if (source == 'remove') {
      onRemove?.call();
      return null;
    }
    try {
      final file = await _picker.pickImage(source: source as ImageSource, maxWidth: 1600, imageQuality: 85);
      return file?.path;
    } on PlatformException {
      if (context.mounted) SupervisorController.showMessage(context, PhotoPickerText.error);
      return null;
    }
  }

  static Widget _option(BuildContext context, IconData icon, Tx label, Object value, {Color color = SupColors.green}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label(), style: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 16, color: color)),
      onTap: () => Navigator.pop(context, value),
    );
  }
}
