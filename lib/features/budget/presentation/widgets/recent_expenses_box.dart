import 'package:flutter/material.dart';

import '../../../../core/utils/figma_canvas.dart';
import '../../domain/entities/expense.dart';
import '../l10n/budget_format.dart';
import 'budget_colors.dart';
import 'expense_texts.dart';

// -------------------------------------------------------------
// "آخر المصروفات" ("Group 36787" — 362×164 أبيض بحد أسود 1 و radius 10): 3 خانات بينها خطوط #717171
// كل خانة: شو اشترى ويومه — والمبلغ "−80 ر.س" بالطرف التاني (أحدث 3 مصروفات)
// فاضي: نفس الصندوق بخطوطه — والخطوط بمكانها بإطار Figma اللي فيه مصروفات / الفاضي
// ضغطة مطوّلة على مصروف: حذفه
// -------------------------------------------------------------
class RecentExpensesBox extends StatelessWidget {
  final FigmaCanvas c;
  final List<Expense> expenses;
  final ValueChanged<Expense> onLongPress;

  const RecentExpensesBox({super.key, required this.c, required this.expenses, required this.onLongPress});

  static const _left = 15.0, _top = 646.0, _width = 362.0, _height = 164.0;

  // الخطوط بين الخانات (y بإطار Figma)
  static const _linesWithData = [702.0, 754.0];
  static const _linesEmpty = [693.5, 746.0];

  // كل خانة: أعلاها وأعلى صناديق نصوصها (إطار Figma اللي فيه مصروفات)
  static const _slots = [
    (top: 646.0, title: 655.5, day: 679.0, amount: 656.0, titleRight: 371.5, dayRight: 366.0),
    (top: 702.0, title: 714.5, day: 737.5, amount: 715.0, titleRight: 370.0, dayRight: 365.0),
    (top: 754.0, title: 761.5, day: 784.5, amount: 762.5, titleRight: 368.0, dayRight: 364.5),
  ];

  @override
  Widget build(BuildContext context) {
    final lines = expenses.isEmpty ? _linesEmpty : _linesWithData;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        c.box(left: _left, top: _top, width: _width, height: _height, color: Colors.white, radius: 10, borderColor: Colors.black),
        for (final y in lines) c.box(left: _left + 0.5, top: y - 0.5, width: _width - 1, height: 1, color: BudgetColors.grey),
        for (final (i, e) in expenses.take(_slots.length).indexed) ...[
          ...expenseTexts(
            c,
            e,
            when: BudgetFormat.day(e.createdAt),
            titleTop: _slots[i].title,
            whenTop: _slots[i].day,
            amountTop: _slots[i].amount,
            titleRight: _slots[i].titleRight,
            whenRight: _slots[i].dayRight,
            amountLeft: 20.5,
          ),
          c.rect(
            left: _left,
            top: _slots[i].top,
            width: _width,
            height: (i + 1 < _slots.length ? _slots[i + 1].top : _top + _height) - _slots[i].top,
            child: GestureDetector(behavior: HitTestBehavior.opaque, onLongPress: () => onLongPress(e)),
          ),
        ],
      ],
    );
  }
}
