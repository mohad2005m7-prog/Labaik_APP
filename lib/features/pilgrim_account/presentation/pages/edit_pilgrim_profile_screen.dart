import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../auth/presentation/widgets/auth_icons.dart';
import '../../../auth/presentation/widgets/auth_widgets.dart';
import '../../domain/entities/pilgrim_profile.dart';
import '../../domain/repositories/pilgrim_account_repository.dart';
import '../controllers/pilgrim_account_controller.dart';
import '../cubits/edit_pilgrim_profile_cubit.dart';
import '../l10n/edit_pilgrim_profile_text.dart';
import '../widgets/pilgrim_page.dart';

// -------------------------------------------------------------
// تعديل البيانات الشخصية (المعتمر) — مطابقة لـ Figma (112:3125، إطار 915 فبتتمرر 63)
// الصورة: ما في صورة تجريبية — دايرة فاضية وزر الكاميرا بيضيف صورة (كاميرا / معرض)
// الاسم والهاتف (القلم بيفتح تعديله) والإيميل + الجنس (ذكر / أنثى) ← حفظ التغييرات
// -------------------------------------------------------------
class EditPilgrimProfileScreen extends StatefulWidget {
  final PilgrimAccountRepository repository;

  const EditPilgrimProfileScreen({super.key, required this.repository});

  @override
  State<EditPilgrimProfileScreen> createState() => _EditPilgrimProfileScreenState();
}

class _EditPilgrimProfileScreenState extends State<EditPilgrimProfileScreen> {
  static const _green = Color(0xFF1F3B2E);
  static const _label = Color(0xFF2E2D2D);
  static const _hintGrey = Color(0xFF9E9C9C);
  static const _avatarFill = Color(0xFFB6B6B6);

  late final _cubit = EditPilgrimProfileCubit(widget.repository)..load();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _phoneFocus = FocusNode();
  bool _phoneEditable = false;
  bool _filled = false;

  @override
  void dispose() {
    _cubit.close();
    for (final c in [_name, _phone, _email]) {
      c.dispose();
    }
    _phoneFocus.dispose();
    super.dispose();
  }

  void _fill(PilgrimProfile p) {
    _name.text = p.fullName;
    _phone.text = p.phone;
    _email.text = p.email;
  }

  Future<void> _pickPhoto(PilgrimProfile p) async {
    final picked = await PilgrimAccountController.pickPhoto(context, hasPhoto: p.photo != null, color: _green);
    if (picked == null) return;
    picked == 'remove' ? await _cubit.removePhoto() : await _cubit.setPhoto(picked);
  }

  // القلم: بيفتح تعديل رقم الهاتف
  void _editPhone() {
    setState(() => _phoneEditable = true);
    _phoneFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<EditPilgrimProfileCubit, EditPilgrimProfileState>(
        listener: (context, state) {
          // أول ما تنحمل البيانات بتنكتب بالحقول
          if (state.status == EditPilgrimStatus.editing && !_filled) {
            _filled = true;
            _fill(state.profile);
          }
          if (state.error != null) PilgrimAccountController.showMessage(context, state.error!());
          if (state.status == EditPilgrimStatus.saved) {
            PilgrimAccountController.showMessage(context, EditPilgrimProfileText.saved());
            Navigator.maybePop(context);
          }
        },
        builder: (context, state) {
          final p = state.profile;
          return PilgrimPage(
            frameHeight: 915,
            builder: (c) => [
              // Frame 38: العنوان وسهم الرجوع ">" بنهايته
              authBack(c, context, left: 365.75, top: 72.5, width: 8, height: 15, stroke: 2),
              c.text(EditPilgrimProfileText.title(), left: 110, top: 67, width: 239, height: 26, dy: 0, style: _style(c, 20, FigmaWeight.sfBold, _green)),

              ..._avatar(c, p),

              _labelText(c, EditPilgrimProfileText.fullName(), top: 284),
              _field(
                c,
                top: 313.5,
                controller: _name,
                hint: EditPilgrimProfileText.fullNameHint(),
                hintColor: _green,
                icon: authPersonIcon(c.s, color: _label),
                iconLeft: 341,
                iconTop: 334,
                keyboard: TextInputType.name,
              ),

              _labelText(c, EditPilgrimProfileText.phone(), top: 398),
              _field(
                c,
                top: 428.5,
                controller: _phone,
                hint: EditPilgrimProfileText.phoneHint,
                hintColor: _green,
                latin: true,
                icon: AuthIconView(AuthIcon.call, size: c.s.x(24), color: _label),
                iconLeft: 341,
                iconTop: 449,
                keyboard: TextInputType.phone,
                focusNode: _phoneFocus,
                readOnly: !_phoneEditable,
              ),
              c.rect(
                left: 23,
                top: 443.5,
                width: 36,
                height: 30,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _editPhone,
                  child: Icon(Icons.edit_outlined, size: c.s.x(24), color: _label),
                ),
              ),

              _labelText(c, EditPilgrimProfileText.email(), top: 514),
              _field(
                c,
                top: 542.5,
                controller: _email,
                hint: EditPilgrimProfileText.emailHint,
                hintColor: _hintGrey,
                latin: true,
                icon: AuthIconView(AuthIcon.mail, size: c.s.x(24), color: _label),
                iconLeft: 342,
                iconTop: 564,
                keyboard: TextInputType.emailAddress,
              ),

              // الجنس (Cairo 700 16 بـ Figma) — الخيار المختار عليه حد
              c.text(EditPilgrimProfileText.gender(), left: 34, top: 627, width: 342, height: 22, dy: 0, style: _style(c, 14.5, FigmaWeight.sfBold, _label)),
              ..._genderOption(c, top: 664, gender: PilgrimGender.male, label: EditPilgrimProfileText.male(), selected: p.gender == PilgrimGender.male),
              ..._genderOption(c, top: 718, gender: PilgrimGender.female, label: EditPilgrimProfileText.female(), selected: p.gender == PilgrimGender.female),

              // حفظ التغييرات (Component 23): 361×48 أبيض بحد #1F3B2E
              c.rect(
                left: 18,
                top: 786,
                width: 361,
                height: 48,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: state.status == EditPilgrimStatus.saving ? null : () => _cubit.save(fullName: _name.text, phone: _phone.text, email: _email.text),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(c.s.x(14)),
                      border: Border.all(color: _green, width: c.s.x(1)),
                    ),
                    child: Center(
                      child: state.status == EditPilgrimStatus.saving
                          ? SizedBox.square(
                              dimension: c.s.x(20),
                              child: CircularProgressIndicator(strokeWidth: c.s.x(2), color: _green),
                            )
                          : Text(EditPilgrimProfileText.save(), style: _style(c, 16, FigmaWeight.sfBold, _green)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  TextStyle _style(FigmaCanvas c, double size, double weight, Color color) => c.style(size, weight, color, lineHeight: null, letterSpacing: 0);

  // عنوان الحقل (Cairo 700 16 #2E2D2D) — طرفه عند 375
  Widget _labelText(FigmaCanvas c, String text, {required double top}) => c.text(text, left: 200, top: top, width: 175, height: 22, dy: 0, style: _style(c, 14.5, FigmaWeight.sfBold, _label));

  // الصورة 100×100 (#B6B6B6 لحد ما يضيف صورة) + زر الكاميرا 30×30 أبيض بحد تحتها من البداية
  List<Widget> _avatar(FigmaCanvas c, PilgrimProfile p) {
    final s = c.s;
    final photo = p.photo;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final empty = ColoredBox(
      color: _avatarFill,
      child: Icon(Icons.person_rounded, size: s.x(62), color: Colors.white),
    );
    return [
      c.rect(
        left: 150,
        top: 145,
        width: 100,
        height: 100,
        child: Center(
          child: SizedBox.square(
            dimension: s.x(100),
            child: ClipOval(
              child: photo == null
                  ? empty
                  : Image(
                      image: ResizeImage(FileImage(File(photo)), width: (s.x(100) * dpr).round()),
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      // ملف الصورة انحذف من الجهاز → الدايرة الفاضية
                      errorBuilder: (_, _, _) => empty,
                    ),
            ),
          ),
        ),
      ),
      c.rect(
        left: 160.75,
        top: 220.75,
        width: 30,
        height: 30,
        child: Center(
          child: Container(
            width: s.x(30),
            height: s.x(30),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _green, width: s.x(1)),
            ),
            alignment: Alignment.center,
            child: Image.asset('assets/images/supervisor/ic_camera.png', width: s.x(20), height: s.x(20.6), color: const Color(0xFF4C7A75), colorBlendMode: BlendMode.srcIn),
          ),
        ),
      ),
      c.tapArea(left: 150, top: 145, width: 100, height: 108, onTap: () => _pickPhoto(p)),
    ];
  }

  // حقل: 360×54 أبيض — حد #1F3B2E — radius 14 — ظل (0,4) blur 4
  // الأيقونة 24 بمكانها بـ Figma (أوطى شوي من النص) والنص بينتهي قبلها بـ 6
  Widget _field(
    FigmaCanvas c, {
    required double top,
    required TextEditingController controller,
    required String hint,
    required Color hintColor,
    required Widget icon,
    required double iconLeft,
    required double iconTop,
    TextInputType? keyboard,
    bool latin = false,
    bool readOnly = false,
    FocusNode? focusNode,
  }) {
    final s = c.s;
    final style = latin ? TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: s.x(14.5), color: _green, height: 1.2) : _style(c, 17, FigmaWeight.semiBold, _green);
    final fieldLeft = 15.5, fieldWidth = 360.0, fieldHeight = 54.0;
    return c.rect(
      left: fieldLeft,
      top: top,
      width: fieldWidth,
      height: fieldHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(s.x(14)),
          border: Border.all(color: _green, width: s.x(1)),
          boxShadow: [c.shadow],
        ),
        child: Stack(
          children: [
            // الأيقونة (من بداية الحقل)
            PositionedDirectional(
              start: s.x(fieldLeft + fieldWidth - iconLeft - 24),
              top: s.y(iconTop - top + 12) - s.x(12),
              child: SizedBox.square(dimension: s.x(24), child: icon),
            ),
            PositionedDirectional(
              start: s.x(fieldLeft + fieldWidth - iconLeft + 6),
              end: s.x(56),
              top: 0,
              bottom: s.y(4),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  readOnly: readOnly,
                  keyboardType: keyboard,
                  cursorColor: _green,
                  textAlignVertical: TextAlignVertical.center,
                  style: style,
                  decoration: InputDecoration.collapsed(
                    hintText: hint,
                    hintStyle: style.copyWith(color: hintColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // خيار الجنس: 224×38 radius 16 — الدايرة 22 (حد 2) بالبداية والنص بعدها — المختار عليه حد ونقطة
  List<Widget> _genderOption(FigmaCanvas c, {required double top, required PilgrimGender gender, required String label, required bool selected}) {
    final s = c.s;
    return [
      c.box(left: 152, top: top, width: 224, height: 38, radius: 16, color: Colors.white, borderColor: selected ? _green : null),
      c.rect(
        left: 342,
        top: top + 6.5,
        width: 22,
        height: 22,
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _green, width: s.x(2)),
            ),
            alignment: Alignment.center,
            child: selected
                ? Container(
                    width: s.x(9),
                    height: s.x(9),
                    decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
                  )
                : null,
          ),
        ),
      ),
      c.text(label, left: 200, top: top + 8, width: 128, height: 22, dy: 0, style: _style(c, 17, FigmaWeight.sfBold, _label)),
      c.tapArea(left: 152, top: top, width: 224, height: 38, onTap: () => _cubit.setGender(gender)),
    ];
  }
}
