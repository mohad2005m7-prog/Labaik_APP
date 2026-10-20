import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../l10n/trip_picker_text.dart';
import 'trip_colors.dart';

// -------------------------------------------------------------
// قائمة الاختيار لما ينضغط حقل البحث (مش مصممة بـ Figma — بنفس ألوان وخطوط الشاشة):
// خانة بحث فوق، والعناصر مقسّمة لمجموعات (المطارات الدولية/الإقليمية، الدول، المناطق)
// -------------------------------------------------------------
class TripPickerGroup {
  final String title;

  /// (القيمة المحفوظة، النص المعروض)
  final List<(String, String)> items;

  const TripPickerGroup(this.title, this.items);
}

/// بيرجع قيمة العنصر المختار أو null لو سكّر
/// [allowTyped]: لو اللي كتبه بالبحث مش بالقائمة بيقدر يختاره هو (مثل فندق مش بقائمة المدينة)
Future<String?> showTripPicker(BuildContext context, {required String hint, required List<TripPickerGroup> groups, String? selected, bool allowTyped = false}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => _PickerSheet(hint: hint, groups: groups, selected: selected, allowTyped: allowTyped),
  );
}

class _PickerSheet extends StatefulWidget {
  final String hint;
  final List<TripPickerGroup> groups;
  final String? selected;
  final bool allowTyped;

  const _PickerSheet({required this.hint, required this.groups, required this.selected, required this.allowTyped});

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    TextStyle style(double size, double weight, Color color) => figmaText(s, size: size, weight: weight, color: color, lineHeight: null, letterSpacing: 0);
    final rows = <Widget>[];
    final typed = _query.trim();
    if (widget.allowTyped && typed.isNotEmpty && !widget.groups.any((g) => g.items.any((i) => i.$2 == typed))) {
      rows.add(InkWell(
        onTap: () => Navigator.pop(context, typed),
        child: Padding(
          padding: EdgeInsets.fromLTRB(s.x(16), s.y(14), s.x(16), s.y(10)),
          child: Text(TripPickerText.useTyped(typed), style: style(16, FigmaWeight.semiBold, TripColors.green)),
        ),
      ));
    }
    for (final group in widget.groups) {
      final items = group.items.where((i) => i.$2.contains(_query.trim())).toList();
      if (items.isEmpty) continue;
      rows.add(Padding(
        padding: EdgeInsets.fromLTRB(s.x(16), s.y(14), s.x(16), s.y(6)),
        child: Text(group.title, style: style(13, FigmaWeight.semiBold, TripColors.teal)),
      ));
      for (final (value, label) in items) {
        final chosen = value == widget.selected;
        rows.add(InkWell(
          onTap: () => Navigator.pop(context, value),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: s.x(16), vertical: s.y(10)),
            child: Text(label, style: style(16, chosen ? FigmaWeight.semiBold : FigmaWeight.sfRegular, TripColors.green)),
          ),
        ));
      }
    }
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(s.x(16), s.y(16), s.x(16), s.y(4)),
              child: Container(
                height: s.y(38),
                padding: EdgeInsets.symmetric(horizontal: s.x(12)),
                alignment: AlignmentDirectional.centerStart,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(s.x(10)), border: Border.all(color: TripColors.green, width: s.x(1))),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: style(16, FigmaWeight.sfRegular, Colors.black),
                  cursorColor: TripColors.green,
                  decoration: InputDecoration.collapsed(hintText: widget.hint, hintStyle: style(16, FigmaWeight.sfRegular, const Color(0xFF717171))),
                ),
              ),
            ),
            Expanded(child: ListView(padding: EdgeInsets.only(bottom: s.y(16)), children: rows)),
          ],
        ),
      ),
    );
  }
}
