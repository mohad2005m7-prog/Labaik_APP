import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../domain/repositories/supervisor_repository.dart';
import '../controllers/supervisor_controller.dart';
import '../cubits/edit_profile_cubit.dart';
import '../cubits/supervisor_profile_cubit.dart';
import '../l10n/edit_profile_text.dart';
import '../widgets/photo_picker.dart';
import '../widgets/supervisor_colors.dart';
import '../widgets/supervisor_page.dart';
import '../widgets/supervisor_widgets.dart';

// -------------------------------------------------------------
// تعديل الملف الشخصي — مطابقة لـ Figma "28.Edit Profile" (251:4703)
// الحقول معبّاة بالبيانات المحفوظة. الكاميرا → صورة من الكاميرا أو المعرض (أو حذفها)
// "حفظ التغييرات": الاسم مطلوب والإيميل والهاتف لازم يكونوا صحاح — بعدها بيبيّن بكل الشاشات فوراً
// -------------------------------------------------------------
class EditSupervisorProfileScreen extends StatelessWidget {
  const EditSupervisorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => EditProfileCubit(context.read<SupervisorRepository>(), context.read<SupervisorProfileCubit>()), child: const _EditView());
  }
}

class _EditView extends StatefulWidget {
  const _EditView();

  @override
  State<_EditView> createState() => _EditViewState();
}

class _EditViewState extends State<_EditView> {
  late final _profile = context.read<SupervisorProfileCubit>().state.profile;
  late final _name = TextEditingController(text: _profile.fullName);
  late final _email = TextEditingController(text: _profile.email);
  late final _phone = TextEditingController(text: _profile.phone);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditProfileCubit>();
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state.status == EditProfileStatus.saved) {
          SupervisorController.showMessage(context, EditProfileText.saved);
          Navigator.maybePop(context);
        } else if (state.error != null) {
          SupervisorController.showMessage(context, state.error!);
        }
      },
      builder: (context, state) => SupervisorPage(
        builder: (c) => [
          c.rect(
            left: 157,
            top: 122,
            width: 80,
            height: 80,
            child: SupPhoto(photo: state.photo, size: c.s.x(80), name: _name.text),
          ),
          c.box(left: 182, top: 182, width: 30, height: 30, color: SupColors.avatarPlaceholder, radius: 15),
          c.image('$supAssets/ic_camera.png', left: 186, top: 185.5, width: 22, height: 22.5),
          c.tapArea(left: 157, top: 122, width: 80, height: 92, onTap: () => _changePhoto(context, cubit, hasPhoto: state.photo != null)),

          ..._field(c, top: 243.5, height: 43, controller: _name, hint: EditProfileText.fullName, icon: 'ic_field_user', iconRect: const Rect.fromLTWH(338.5, 253, 17.5, 22.5), textRight: 326, textTop: 10),
          ..._field(
            c,
            top: 301.5,
            height: 45,
            controller: _email,
            hint: EditProfileText.email,
            icon: 'ic_field_mail',
            iconRect: const Rect.fromLTWH(335, 313, 24, 22),
            textRight: 321,
            textTop: 10,
            keyboard: TextInputType.emailAddress,
            ltr: true,
          ),
          ..._field(
            c,
            top: 361.5,
            height: 45,
            controller: _phone,
            hint: EditProfileText.phone,
            icon: 'ic_field_phone',
            iconRect: const Rect.fromLTWH(340, 372, 22, 22),
            textRight: 329,
            textTop: 8,
            keyboard: TextInputType.phone,
            ltr: true,
          ),

          c.rect(
            left: 24,
            top: 438,
            width: 345,
            height: 50,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: state.status == EditProfileStatus.editing
                  ? () {
                      FocusScope.of(context).unfocus();
                      cubit.save(name: _name.text, email: _email.text, phone: _phone.text);
                    }
                  : null,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(color: SupColors.green, borderRadius: BorderRadius.circular(c.s.x(14))),
                child: Text(EditProfileText.saveChanges(), maxLines: 1, style: c.style(16.25, FigmaWeight.semiBold, Colors.white)),
              ),
            ),
          ),
          ...supBackArrow(c, context, left: 368, top: 68, trailing: true),
        ],
      ),
    );
  }

  // حقل 346 عرض — #4C7A75 10% — حد #1F3B2E — radius 10 — النص Poppins Regular 16 والأيقونة يمين
  // [ltr]: الإيميل والهاتف بينكتبوا من اليسار لليمين
  List<Widget> _field(
    FigmaCanvas c, {
    required double top,
    required double height,
    required TextEditingController controller,
    required Tx hint,
    required String icon,
    required Rect iconRect,
    required double textRight,
    required double textTop,
    TextInputType keyboard = TextInputType.text,
    bool ltr = false,
  }) {
    final style = c.style(16, FigmaWeight.poppinsRegular, SupColors.grey);
    return [
      c.box(left: 27.5, top: top, width: 346, height: height, color: SupColors.cardFill, radius: 10, borderColor: SupColors.green),
      c.image('$supAssets/$icon.png', left: iconRect.left, top: iconRect.top, width: iconRect.width, height: iconRect.height),
      c.rect(
        left: 40,
        top: top + textTop,
        width: textRight - 40,
        height: 26,
        child: TextField(
          controller: controller,
          keyboardType: keyboard,
          textInputAction: TextInputAction.next,
          cursorColor: SupColors.green,
          textAlignVertical: TextAlignVertical.center,
          // الإيميل والهاتف LTR بس بنفس محاذاة الصفحة (يمين بالعربي زي Figma)
          textAlign: ltr ? (Directionality.of(context) == TextDirection.rtl ? TextAlign.right : TextAlign.left) : TextAlign.start,
          textDirection: ltr ? TextDirection.ltr : null,
          style: style.copyWith(color: SupColors.green),
          decoration: InputDecoration.collapsed(hintText: hint(), hintStyle: style),
        ),
      ),
    ];
  }

  Future<void> _changePhoto(BuildContext context, EditProfileCubit cubit, {required bool hasPhoto}) async {
    final path = await SupPhotoPicker.pick(context, onRemove: hasPhoto ? cubit.removePhoto : null);
    if (path != null) await cubit.pickPhoto(path);
  }
}
