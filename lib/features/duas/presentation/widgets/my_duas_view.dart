import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../domain/entities/personal_dua.dart';
import '../cubits/my_duas_cubit.dart';
import '../l10n/duas_text.dart';
import 'duas_colors.dart';
import 'personal_dua_card.dart';

// -------------------------------------------------------------
// تبويب "سجل أدعيتي" (إطار 172:2611 من تحت التبويبات y206):
// "أدعيتك الخاصة" + شرحها، كروت الأدعية (كل كرت 90 وبينهم 16)، وزر "+ إضافة دعاء" ثابت عند y750
// ما في أدعية تجريبية: الكروت هي أدعية المعتمر نفسه — ولو كترت بتتمرر بين الشرح والزر
// الضغط على دعاء بيفتحه للتعديل، والضغطة المطوّلة: تعديل / حذف
// -------------------------------------------------------------
class MyDuasView extends StatelessWidget {
  /// كانفس بيبدأ عند y206 بإطار Figma
  final FigmaCanvas c;
  final VoidCallback onAdd;
  final ValueChanged<PersonalDua> onEdit;
  final ValueChanged<PersonalDua> onOptions;

  const MyDuasView({super.key, required this.c, required this.onAdd, required this.onEdit, required this.onOptions});

  // الكروت من y289 — منطقة التمرير بتبدأ قبلها بـ 8 وبتخلص قبل الزر بـ 8
  static const _listTop = 281.0;
  static const _listBottom = 742.0;

  @override
  Widget build(BuildContext context) {
    final s = c.s;
    TextStyle style(double size, double weight, Color color) => c.style(size, weight, color, lineHeight: null, letterSpacing: 0);
    return Stack(
      children: [
        c.text(DuasText.myDuasTitle(), left: 28, top: 227, width: 335, height: 24, dy: 1.5, style: style(20, FigmaWeight.semiBold, DuasColors.green)),
        c.text(DuasText.myDuasHint(), left: 81, top: 262, width: 289, height: 14, dy: 1.5, style: style(12, FigmaWeight.sfRegular, Colors.black)),
        c.rect(
          left: 16,
          top: _listTop,
          width: 359,
          height: _listBottom - _listTop,
          child: BlocBuilder<MyDuasCubit, MyDuasState>(
            builder: (context, state) => ListView.separated(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: s.y(8)),
              itemCount: state.duas.length,
              separatorBuilder: (_, _) => SizedBox(height: s.y(16)),
              itemBuilder: (_, i) => PersonalDuaCard(c: c, dua: state.duas[i], onTap: () => onEdit(state.duas[i]), onLongPress: () => onOptions(state.duas[i])),
            ),
          ),
        ),
        c.button(DuasText.addDua(), left: 16, top: 750, onTap: onAdd),
      ],
    );
  }
}
