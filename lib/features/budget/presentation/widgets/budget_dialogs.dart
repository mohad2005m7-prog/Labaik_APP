import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../l10n/budget_amount_text.dart';
import '../l10n/budget_format.dart';
import 'budget_colors.dart';
import 'budget_input_field.dart';

// -------------------------------------------------------------
// نوافذ الميزانية (مش مصممة بـ Figma — بنفس حقل وزر شاشة الميزانية):
// المبلغ ("+ إضافة مبلغ" / "تعديل الميزانية") وتأكيد حذف مصروف
// -------------------------------------------------------------
const _red = Color(0xFFF44336);

/// بيرجع المبلغ اللي كتبه (موجب) أو null لو سكّر
Future<double?> showBudgetAmountSheet(BuildContext context, {required String title, double? initial}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => _AmountSheet(title: title, initial: initial),
  );
}

class _AmountSheet extends StatefulWidget {
  final String title;
  final double? initial;

  const _AmountSheet({required this.title, this.initial});

  @override
  State<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<_AmountSheet> {
  late final _controller = TextEditingController(text: (widget.initial ?? 0) <= 0 ? '' : BudgetFormat.number(widget.initial!));
  bool _invalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = BudgetFormat.parse(_controller.text);
    if (value == null) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    TextStyle style(double size, double weight, Color color) => figmaText(s, size: size, weight: weight, color: color, lineHeight: null, letterSpacing: 0);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(s.x(16), s.y(20), s.x(16), s.y(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title.replaceFirst('+', '').trim(), style: style(16, FigmaWeight.semiBold, BudgetColors.green)),
              SizedBox(height: s.y(12)),
              BudgetInputField(s: s, controller: _controller, hint: BudgetFormat.amountHint(), amount: true, autofocus: true),
              if (_invalid) ...[
                SizedBox(height: s.y(6)),
                Text(BudgetAmountText.errorAmount(), style: style(12, FigmaWeight.sfRegular, _red)),
              ],
              SizedBox(height: s.y(16)),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _save,
                child: Container(
                  height: s.y(44),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: BudgetColors.green, borderRadius: BorderRadius.circular(s.x(14))),
                  child: Text(BudgetAmountText.save(), style: style(18, FigmaWeight.semiBold, Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> confirmDeleteExpense(BuildContext context, String title) async {
  TextStyle style(Color color) => TextStyle(fontFamily: 'NotoSansArabic', fontSize: 16, color: color);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      backgroundColor: Colors.white,
      title: Text(BudgetAmountText.deleteQuestion(), style: style(BudgetColors.green).copyWith(fontWeight: FontWeight.w600)),
      content: Text(title, style: style(Colors.black)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialog, false), child: Text(BudgetAmountText.cancel(), style: style(BudgetColors.green))),
        TextButton(onPressed: () => Navigator.pop(dialog, true), child: Text(BudgetAmountText.delete(), style: style(_red))),
      ],
    ),
  );
  return confirmed ?? false;
}
