import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/common_text.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../auth/data/auth_session.dart';
import '../../../auth/data/token_refresher.dart';
import '../../../auth/presentation/pages/auth_welcome_screen.dart';
import '../../../auth/presentation/pages/create_new_password_screen.dart';
import '../../../family/presentation/controllers/family_controller.dart';
import '../../../group/data/sources/group_realtime.dart';
import '../../../group/presentation/controllers/group_controller.dart';
import '../../data/pilgrim_account_repository_impl.dart';
import '../../domain/repositories/pilgrim_account_repository.dart';
import '../l10n/edit_pilgrim_profile_text.dart';
import '../pages/edit_pilgrim_profile_screen.dart';
import '../pages/pilgrim_settings_screen.dart';

// -------------------------------------------------------------
// التنقل بشاشات حساب المعتمر — منفصل تماماً عن المشرف (SupervisorController):
// رئيسية المعتمر (القائمة ≡) → الإعدادات → تعديل البيانات الشخصية / تغيير كلمة المرور / تسجيل الخروج
// -------------------------------------------------------------
class PilgrimAccountController {
  static final PilgrimAccountRepository _repository = PilgrimAccountRepositoryImpl();
  static final _picker = ImagePicker();

  static Future<void> openSettings(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => PilgrimSettingsScreen(repository: _repository)));

  static Future<void> openEditProfile(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => EditPilgrimProfileScreen(repository: _repository)));

  /// الاسم اللي حفظه المعتمر بتعديل البيانات (null = ما عدّل)
  static Future<String?> savedName() async {
    final name = (await _repository.savedProfile())?.fullName;
    return name == null || name.isEmpty ? null : name;
  }

  /// صورة المعتمر على الجهاز (null = ما أضاف صورة) — بتطلع جنب رسائله بالمحادثات
  static Future<String?> savedPhoto() async => (await _repository.savedProfile())?.photo;

  /// "تغيير كلمة المرور" → نفس مسار نسيت كلمة المرور (رمز على الإيميل ثم كلمة مرور جديدة)
  static void changePassword(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateNewPasswordScreen.change()));

  static void showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(milliseconds: 1600)));
  }

  static void comingSoon(BuildContext context) => showMessage(context, CommonText.comingSoon());

  /// تسجيل الخروج: حذف التوكن والرجوع لشاشة الدخول/إنشاء الحساب
  /// (بيانات الحساب ونوعه بيضلوا محفوظين — بيرجعوا لما يسجل دخول من جديد)
  static Future<void> logout(BuildContext context) async {
    await FamilyController.stopLocationSharing();
    await GroupController.stopLocationSharing();
    await TokenRefresher.revoke();
    await TokenStorage.clearTokens();
    await AuthSession.clear();
    GroupRealtime.reset();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const AuthWelcomeScreen()), (route) => false);
  }

  /// اختيار صورة: كاميرا / معرض (+ حذف لو في صورة) — بيرجع مسار الصورة المؤقت، أو 'remove'
  static Future<String?> pickPhoto(BuildContext context, {required bool hasPhoto, required Color color}) async {
    Widget option(BuildContext sheet, IconData icon, String label, Object value, {Color? tint}) => ListTile(
          leading: Icon(icon, color: tint ?? color),
          title: Text(label, style: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 16, color: tint ?? color)),
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
            option(sheet, Icons.photo_camera_outlined, EditPilgrimProfileText.photoCamera(), ImageSource.camera),
            option(sheet, Icons.photo_library_outlined, EditPilgrimProfileText.photoGallery(), ImageSource.gallery),
            if (hasPhoto) option(sheet, Icons.delete_outline_rounded, EditPilgrimProfileText.photoRemove(), 'remove', tint: const Color(0xFFF44336)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null || source == 'remove') return source as String?;
    try {
      final file = await _picker.pickImage(source: source as ImageSource, maxWidth: 1600, imageQuality: 85);
      return file?.path;
    } catch (_) {
      if (context.mounted) showMessage(context, EditPilgrimProfileText.photoError());
      return null;
    }
  }
}
