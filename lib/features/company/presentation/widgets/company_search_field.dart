import 'package:flutter/material.dart';

import '../../../../core/l10n/app_language.dart';
import '../../../../core/theme/figma_spaced_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import 'company_colors.dart';

// -------------------------------------------------------------
// حقل البحث (مكوّن SearchField 345×36): #767680 12% — radius 10
// العدسة 15.63×15.78 على بعد 30.4 من البداية، والنص SF Compact 457 16 على بعد 52 (#3C3C43 60%)
// التلميح بيضيق زي Figma (letter spacing -0.408) — والمكتوب أسود
// -------------------------------------------------------------
class CompanySearchField extends StatefulWidget {
  final DesignScale s;
  final String hint;
  final ValueChanged<String> onChanged;

  const CompanySearchField({super.key, required this.s, required this.hint, required this.onChanged});

  @override
  State<CompanySearchField> createState() => _CompanySearchFieldState();
}

class _CompanySearchFieldState extends State<CompanySearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final style = figmaText(s, size: 16, weight: FigmaWeight.sfRegular, color: CompanyColors.secondaryLabel, lineHeight: 22, letterSpacing: 0);
    return DecoratedBox(
      decoration: BoxDecoration(color: CompanyColors.searchFill, borderRadius: BorderRadius.circular(s.x(10))),
      child: Stack(
        children: [
          PositionedDirectional(
            start: s.x(52),
            end: s.x(8),
            top: 0,
            bottom: 0,
            child: Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) => value.text.isNotEmpty
                      ? const SizedBox.shrink()
                      : IgnorePointer(
                          child: AppLanguage.isArabic
                              ? FigmaSpacedText(widget.hint, style: style, letterSpacing: s.x(-0.408), width: s.x(285), maxLines: 1)
                              : Text(widget.hint, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
                        ),
                ),
                TextField(
                  controller: _controller,
                  onChanged: widget.onChanged,
                  cursorColor: CompanyColors.green,
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.search,
                  style: style.copyWith(color: Colors.black),
                  decoration: const InputDecoration.collapsed(hintText: null),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            start: s.x(345 - 8 - 285 - 6 - 15.63),
            top: 0,
            bottom: 0,
            child: IgnorePointer(child: Center(child: Image.asset('$companyAssets/ic_search.png', width: s.x(15.63), height: s.x(15.78)))),
          ),
        ],
      ),
    );
  }
}
