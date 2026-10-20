import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../../family/presentation/l10n/family_messages_text.dart';
import '../../../family/presentation/widgets/family_code_field.dart';
import '../../../family/presentation/widgets/family_scanner.dart';
import '../../../family/presentation/widgets/family_segmented.dart';
import '../controllers/group_controller.dart';
import '../l10n/group_join_text.dart';

// -------------------------------------------------------------
// "انضم إلى مجموعتك" (Figma) — تبويبين: أكتب الرمز ⇄ إمسح QR
//   وصف (15,124 363×42) — SegmentedPicker (25,169 343×32)
//   الرمز: "أدخل رمز المجموعة" (233) + الخانة (24,263 345×44) + الانضمام (17,338)
//   QR: "امسح رمز QR الخاص بمجموعتك" (233) + مربع المسح 284×284 (54.5,282)
// -------------------------------------------------------------
class GroupJoinScreen extends StatefulWidget {
  const GroupJoinScreen({super.key});

  @override
  State<GroupJoinScreen> createState() => _GroupJoinScreenState();
}

class _GroupJoinScreenState extends State<GroupJoinScreen> {
  final _code = TextEditingController();
  final _codeFocus = FocusNode();
  int _tab = 0;

  @override
  void dispose() {
    _code.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _join() => GroupController.findGroup(context, _code.text);

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: GroupJoinText.joinTitle(),
      titleRight: 348.5,
      chevronLeft: 367,
      headerDy: 2,
      titleSize: 24,
      body: (c) => [
        c.text(GroupJoinText.joinDescription(), left: 15, top: 124, width: 363, height: 22, style: c.style(14, FigmaWeight.semiBold, Colors.black)),
        c.rect(
          left: 25,
          top: 169,
          width: 343,
          height: 32,
          child: FamilySegmented(
            s: c.s,
            labels: [GroupJoinText.codeTab(), GroupJoinText.qrTab()],
            selected: _tab,
            onSelect: (i) {
              FocusScope.of(context).unfocus();
              setState(() => _tab = i);
            },
          ),
        ),
        ...(_tab == 0 ? _codeTab(c) : _qrTab(c)),
      ],
    );
  }

  TextStyle _label(FigmaCanvas c) => c.style(16, FigmaWeight.sfRegular, Colors.black);

  List<Widget> _codeTab(FigmaCanvas c) => [
        c.text(GroupJoinText.enterCode(), left: 247, top: 233, width: 130, height: 22, style: _label(c)),
        c.rect(
          left: 24,
          top: 263,
          width: 345,
          height: 44,
          child: FamilyCodeField(s: c.s, controller: _code, focusNode: _codeFocus, hint: GroupJoinText.codeHint(), onSubmit: _join),
        ),
        c.button(GroupJoinText.join(), left: 17, top: 338, figmaSpacing: true, onTap: _join),
      ];

  List<Widget> _qrTab(FigmaCanvas c) => [
        c.text(GroupJoinText.scanLabel(), left: 165, top: 233, width: 213, height: 22, style: _label(c)),
        c.rect(
          left: 54.5,
          top: 282,
          width: 284,
          height: 284,
          child: FamilyScanner(
            s: c.s,
            onCode: (code) {
              _code.text = code;
              _join();
            },
            onInvalid: () => GroupController.showMessage(context, FamilyMessagesText.invalidQr),
            onCameraError: () => GroupController.showMessage(context, FamilyMessagesText.cameraDenied),
          ),
        ),
      ];
}
