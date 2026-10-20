import 'package:flutter/material.dart';

import '../../../../core/utils/figma_canvas.dart';
import '../../domain/entities/expense.dart';
import '../l10n/budget_format.dart';
import 'budget_colors.dart';
import 'expense_texts.dart';

// -------------------------------------------------------------
// قائمة "كل المصروفات" ("Rectangle 137" — 362×565 أبيض بحد أسود 1 و radius 10)
// كل مصروف: اسمه ووقته ("اليوم، 2:30 م") والمبلغ — صف كل 81 (أول صف عند y281 زي Figma)
// لما تكتر بتتمرر جوّا الصندوق بشريط Figma: خط أسود 5 وفوقه #717171 3 (من y277 لـ y796)
// ضغطة مطوّلة على مصروف: حذفه
// -------------------------------------------------------------
class AllExpensesList extends StatefulWidget {
  final FigmaCanvas c;
  final List<Expense> expenses;
  final ValueChanged<Expense> onLongPress;

  const AllExpensesList({super.key, required this.c, required this.expenses, required this.onLongPress});

  @override
  State<AllExpensesList> createState() => _AllExpensesListState();
}

class _AllExpensesListState extends State<AllExpensesList> {
  static const _boxLeft = 16.0, _boxTop = 247.0, _boxWidth = 362.0, _boxHeight = 565.0;
  static const _firstRow = 281.0, _rowPitch = 81.0;

  // شريط التمرير (Line 15): طرفه عند x373.5، من y277 لـ y796
  static const _barEdge = 373.5, _barTop = 277.0, _barBottom = 796.0;

  // الشريط ظاهر دايماً (لما القائمة أطول من الصندوق) فبدو controller خاص فيه
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c, expenses = widget.expenses;
    final s = c.s;
    final viewportTop = _boxTop + 1, viewportBottom = _boxTop + _boxHeight - 1;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final barInset = s.x(FigmaCanvas.frameWidth - _barEdge);
    final row = c.at(_firstRow);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.box(left: _boxLeft, top: _boxTop, width: _boxWidth, height: _boxHeight, color: Colors.white, radius: 10, borderColor: Colors.black),
        c.rect(
          left: 0,
          top: viewportTop,
          width: FigmaCanvas.frameWidth,
          height: viewportBottom - viewportTop,
          child: RawScrollbar(
            controller: _scroll,
            thumbVisibility: true,
            trackVisibility: true,
            thickness: s.x(3),
            crossAxisMargin: s.x(1),
            thumbColor: BudgetColors.grey,
            trackColor: Colors.black,
            trackBorderColor: Colors.transparent,
            radius: Radius.zero,
            scrollbarOrientation: rtl ? ScrollbarOrientation.right : ScrollbarOrientation.left,
            padding: EdgeInsets.only(
              top: s.y(_barTop - viewportTop),
              bottom: s.y(viewportBottom - _barBottom),
              right: rtl ? barInset : 0,
              left: rtl ? 0 : barInset,
            ),
            child: ListView.builder(
              controller: _scroll,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: s.y(_firstRow - viewportTop)),
              itemCount: expenses.length,
              itemExtent: s.y(_rowPitch),
              itemBuilder: (_, i) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPress: () => widget.onLongPress(expenses[i]),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: expenseTexts(
                    row,
                    expenses[i],
                    when: BudgetFormat.dayTime(expenses[i].createdAt),
                    titleTop: _firstRow,
                    whenTop: 312,
                    amountTop: _firstRow,
                    titleRight: 369,
                    whenRight: 367,
                    amountLeft: 19.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
