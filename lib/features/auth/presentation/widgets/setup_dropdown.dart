import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// -------------------------------------------------------------
// القائمة المنسدلة لشاشات الوصول (SearchField بـ Figma):
// 331×38 — خلفية #767680 بشفافية 12% — النص الإرشادي #3C3C43 بشفافية 54%
// العناصر مقسّمة لمجموعات، وكل مجموعة إلها عنوان غير قابل للاختيار.
// -------------------------------------------------------------
class SetupDropdownItem {
  final String value; // القيمة المخزّنة (مثلاً رمز المطار)
  final String label; // النص المعروض
  const SetupDropdownItem(this.value, this.label);
}

class SetupDropdownGroup {
  final String title;
  final List<SetupDropdownItem> items;
  const SetupDropdownGroup(this.title, this.items);
}

class SetupDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<SetupDropdownGroup> groups;
  final ValueChanged<String?> onChanged;

  const SetupDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.groups,
    required this.onChanged,
  });

  static const _green = Color(0xFF1F3B2E);
  static const _fill = Color(0x1F767680); // #767680 بشفافية 12%
  static const _hintColor = Color(0x8A3C3C43); // #3C3C43 بشفافية 54%

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<String>>[];
    for (final g in groups) {
      items.add(
        DropdownMenuItem<String>(
          enabled: false,
          child: Text(
            g.title,
            style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.bold, color: _green),
          ),
        ),
      );
      for (final i in g.items) {
        items.add(
          DropdownMenuItem<String>(
            value: i.value,
            child: Text(
              i.label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(fontSize: 13, color: const Color(0xFF000000)),
            ),
          ),
        );
      }
    }

    return Container(
      width: 331,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _fill,
        border: Border.all(color: const Color(0xFF717171), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: GoogleFonts.tajawal(fontSize: 14, color: _hintColor)),
          icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: _green),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
