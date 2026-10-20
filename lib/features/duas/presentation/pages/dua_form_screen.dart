import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/personal_dua.dart';
import '../../domain/repositories/duas_repository.dart';
import '../controllers/duas_controller.dart';
import '../cubits/dua_form_cubit.dart';
import '../l10n/dua_form_text.dart';
import '../widgets/dua_input_field.dart';
import '../widgets/duas_colors.dart';

// -------------------------------------------------------------
// إضافة دعاء جديد — Figma "الأدعية" (174:2746) — ونفس الشاشة لتعديل دعاء ([dua] مكتوب فيها)
// عنوان الدعاء + نص الدعاء (الاتنين مطلوبين) ← "حفظ الدعاء" بيحفظه لحساب المعتمر وبيرجع لسجل أدعيتي
// "إلغاء" بيرجع بدون حفظ
// -------------------------------------------------------------
class DuaFormScreen extends StatefulWidget {
  final DuasRepository repository;

  /// null = دعاء جديد
  final PersonalDua? dua;

  const DuaFormScreen({super.key, required this.repository, this.dua});

  @override
  State<DuaFormScreen> createState() => _DuaFormScreenState();
}

class _DuaFormScreenState extends State<DuaFormScreen> {
  late final _cubit = DuaFormCubit(widget.repository, dua: widget.dua);
  late final _title = TextEditingController(text: widget.dua?.title);
  late final _text = TextEditingController(text: widget.dua?.text);

  @override
  void dispose() {
    _cubit.close();
    _title.dispose();
    _text.dispose();
    super.dispose();
  }

  void _onState(BuildContext context, DuaFormState state) {
    if (state.error != null) DuasController.showMessage(context, state.error!());
    if (state.status == DuaFormStatus.saved) {
      DuasController.showMessage(context, DuaFormText.saved());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DuaFormCubit, DuaFormState>(
      bloc: _cubit,
      listener: _onState,
      child: FigmaPage(
        title: widget.dua == null ? DuaFormText.addTitle() : DuaFormText.editTitle(),
        body: (c) => [
          _label(c, DuaFormText.duaTitle(), left: 30, top: 127),
          DuaInputField(c: c, top: 153, height: 49, textTop: 10, controller: _title, hint: DuaFormText.duaTitleHint()),
          _label(c, DuaFormText.duaText(), left: 32, top: 221),
          DuaInputField(c: c, top: 253, height: 418, textTop: 9, controller: _text, hint: DuaFormText.duaTextHint(), multiline: true),
          c.button(
            DuaFormText.save(),
            left: 16,
            top: 691,
            onTap: () => _cubit.save(title: _title.text, text: _text.text),
          ),
          c.button(DuaFormText.cancel(), left: 16, top: 750, outlined: true, borderColor: Colors.black, onTap: () => Navigator.maybePop(context)),
        ],
      ),
    );
  }

  // عنوان الحقل: SF Compact 556 15 #1F3B2E
  Widget _label(FigmaCanvas c, String text, {required double left, required double top}) =>
      c.text(text, left: left, top: top, width: 345, height: 18, dy: 0, style: c.style(15, FigmaWeight.semiBold, DuasColors.green, lineHeight: null, letterSpacing: 0));
}
