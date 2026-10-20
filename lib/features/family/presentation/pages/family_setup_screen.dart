import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/common_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../../help_center/presentation/widgets/help_text.dart';
import '../controllers/family_controller.dart';
import '../cubits/family_setup_cubit.dart';
import '../l10n/family_messages_text.dart';
import '../l10n/family_setup_text.dart';
import '../widgets/family_button.dart';
import '../widgets/family_code_box.dart';
import '../widgets/family_code_field.dart';
import '../widgets/family_qr_box.dart';
import '../widgets/family_scanner.dart';
import '../widgets/family_segmented.dart';

// -------------------------------------------------------------
// "أنشئ دائرة عائلتك" (Figma 111:5131) ⇄ "انضم إلى دائرة عائلتك" (111:5165) — نفس الشاشة بتبويبين:
//   إنشاء: QR دائرتي (163×163 من 115,259) + "رمز المجموعة :" + الرمز (20,493.5 357×40) + مشاركة الدعوة (17,566)
//   انضمام: مربع المسح (200×200 من 107,259) + "أدخل رمز المجموعة" + الخانة (19,529 357.5×40) + متابعة (16,602)
// الدائرة بتنعمل بالسيرفر أول ما يفتح الإنشاء — ولما ينضم أول فرد الشاشة بتكمل لحالها (مشاركة الموقع)
// -------------------------------------------------------------
class FamilySetupScreen extends StatefulWidget {
  const FamilySetupScreen({super.key});

  @override
  State<FamilySetupScreen> createState() => _FamilySetupScreenState();
}

class _FamilySetupScreenState extends State<FamilySetupScreen> {
  final _code = TextEditingController();
  final _codeFocus = FocusNode();

  FamilySetupCubit get _cubit => context.read<FamilySetupCubit>();

  @override
  void dispose() {
    _code.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _select(int index) {
    FocusScope.of(context).unfocus();
    _cubit.select(FamilySetupTab.values[index]);
  }

  void _find() => FamilyController.findCircle(context, _code.text);

  void _scanned(String code) {
    _code.text = code;
    FamilyController.findCircle(context, code);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FamilySetupCubit, FamilySetupState>(
      // أول فرد انضم لدائرتي → مشاركة الموقع (أو القائمة)
      listenWhen: (previous, current) => previous.circle?.hasOthers != true && current.circle?.hasOthers == true,
      listener: (context, state) => FamilyController.continueWith(context, state.circle!),
      builder: (context, state) {
        final create = state.tab == FamilySetupTab.create;
        return FigmaPage(
          title: create ? FamilySetupText.createTitle() : FamilySetupText.joinTitle(),
          titleRight: 348.5,
          chevronLeft: 367,
          headerDy: 2,
          titleSize: 24,
          body: (c) => [
            if (create)
              HelpText.paragraph(c, FamilySetupText.createDescription(), left: 16, top: 119, width: 361, lines: 2, style: _description(c))
            else
              HelpText.paragraph(c, FamilySetupText.joinDescription(), left: 12, top: 119, width: 366, lines: 2, style: _description(c)),
            c.rect(
              left: 25,
              top: 187,
              width: 343,
              height: 32,
              child: FamilySegmented(s: c.s, labels: [FamilySetupText.createTab(), FamilySetupText.joinTab()], selected: state.tab.index, onSelect: _select),
            ),
            ...(create ? _createTab(c, state) : _joinTab(c, state)),
          ],
        );
      },
    );
  }

  static TextStyle _description(FigmaCanvas c) => c.style(14, FigmaWeight.semiBold, Colors.black);

  List<Widget> _createTab(FigmaCanvas c, FamilySetupState state) {
    final circle = state.circle;
    final error = state.createError;
    return [
      c.rect(
        left: 115,
        top: 259.5,
        width: 163,
        height: 163,
        child: FamilyQrBox(
          s: c.s,
          data: circle == null ? null : FamilyQrBox.payload(circle.code, circle.inviteLink),
          error: error == null || state.creating ? null : FamilyMessagesText.forError(error)(),
          onRetry: _cubit.ensureCircle,
        ),
      ),
      HelpText.line(c, FamilySetupText.codeLabel(), right: 378, top: 458, boxWidth: 89, room: 361, style: c.style(16, FigmaWeight.sfRegular, Colors.black)),
      c.rect(
        left: 20,
        top: 493.5,
        width: 357,
        height: 40,
        child: FamilyCodeBox(s: c.s, code: circle?.code, onCopied: () => FamilyController.showMessage(context, FamilyMessagesText.codeCopied)),
      ),
      c.button(
        FamilySetupText.shareInvite(),
        left: 17,
        top: 566,
        figmaSpacing: true,
        onTap: () {
          final ready = state.circle;
          if (ready == null) {
            if (!state.creating) _cubit.ensureCircle();
            return;
          }
          FamilyController.shareInvite(context, ready);
        },
      ),
    ];
  }

  List<Widget> _joinTab(FigmaCanvas c, FamilySetupState state) {
    return [
      c.rect(
        left: 107,
        top: 259,
        width: 200,
        height: 200,
        child: FamilyScanner(
          s: c.s,
          onCode: _scanned,
          onInvalid: () => FamilyController.showMessage(context, FamilyMessagesText.invalidQr),
          onCameraError: () => FamilyController.showMessage(context, FamilyMessagesText.cameraDenied),
        ),
      ),
      HelpText.line(c, FamilySetupText.enterCode(), right: 378.5, top: 494.5, boxWidth: 117, room: 361, style: c.style(16, FigmaWeight.sfRegular, Colors.black)),
      c.rect(
        left: 19,
        top: 529,
        width: 357.5,
        height: 40,
        child: FamilyCodeField(s: c.s, controller: _code, focusNode: _codeFocus, hint: FamilySetupText.codeHint(), onSubmit: _find),
      ),
      familyButton(c, CommonText.continueLabel(), left: 16, top: 602, busy: state.lookingUp, onTap: _find),
    ];
  }
}
