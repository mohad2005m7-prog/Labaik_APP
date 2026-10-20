import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_language.dart';
import '../../../../core/theme/figma_spaced_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../domain/entities/personal_dua.dart';
import '../../domain/repositories/duas_repository.dart';
import '../controllers/duas_controller.dart';
import '../cubits/my_duas_cubit.dart';
import '../l10n/duas_text.dart';
import '../widgets/dua_actions.dart';
import '../widgets/duas_tabs.dart';
import '../widgets/my_duas_view.dart';
import '../widgets/suggested_duas_view.dart';

// -------------------------------------------------------------
// الأدعية — Figma "الأدعية" (172:2611 سجل أدعيتي، 174:2863 أدعية مقترحة)
// العنوان والشرح والتبويبين ثابتين، وتحتهم صفحتين بتتبدلوا بالضغط على التبويب أو بالسحب
// بتفتح على "سجل أدعيتي" (أول إطار بالبروتوتايب)
// -------------------------------------------------------------
class DuasScreen extends StatefulWidget {
  final DuasRepository repository;

  const DuasScreen({super.key, required this.repository});

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
  late final _cubit = MyDuasCubit(widget.repository)..load();
  final _pages = PageController(initialPage: DuasTabs.myDuasPage);

  @override
  void dispose() {
    _cubit.close();
    _pages.dispose();
    super.dispose();
  }

  void _select(int page) => _pages.animateToPage(page, duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic);

  // إضافة أو تعديل → بيرجع لسجل أدعيتي وبتتحدث القائمة
  Future<void> _openForm([PersonalDua? dua]) async {
    await DuasController.openForm(context, dua: dua);
    await _cubit.load();
  }

  // ضغطة مطوّلة على دعاء: تعديل / حذف (بعد التأكيد)
  Future<void> _options(PersonalDua dua) async {
    final action = await showDuaActions(context);
    if (!mounted || action == null) return;
    if (action == DuaAction.edit) return _openForm(dua);
    final confirmed = await confirmDeleteDua(context, dua.title);
    if (!confirmed || !mounted) return;
    await _cubit.delete(dua);
    if (mounted) DuasController.showMessage(context, DuasText.deleted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: FigmaPage(
        title: DuasText.title(),
        body: (c) {
          final content = c.at(206);
          return [
            _subtitle(c),
            DuasTabs(c: c, controller: _pages, onSelect: _select),
            c.rect(
              left: 0,
              top: 206,
              width: 393,
              height: 818 - 206,
              child: PageView(
                controller: _pages,
                children: [
                  SuggestedDuasView(c: content, duas: widget.repository.suggestedDuas(), onOpen: (dua) => DuasController.openSuggested(context, dua)),
                  MyDuasView(c: content, onAdd: _openForm, onEdit: _openForm, onOptions: _options),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }

  // SF Compact 556 14 (letter spacing -0.408) — صندوقه بـ Figma على قد النص (327) فالعربي بينضغط لعرضه بالظبط
  // الإنجليزي (مش مصمم بـ Figma) زي باقي نصوص التطبيق
  Widget _subtitle(FigmaCanvas c) {
    final style = c.style(14, FigmaWeight.semiBold, Colors.black);
    if (!AppLanguage.isArabic) return c.text(DuasText.subtitle(), left: 50, top: 113, width: 327, height: 22, style: style);
    return c.rect(
      left: 50,
      top: 113 + FigmaCanvas.baselineFix,
      width: 327,
      height: 22,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: FigmaSpacedText(DuasText.subtitle(), style: style, letterSpacing: c.s.x(-0.408), width: c.s.x(327), maxLines: 1, fitWidth: true),
      ),
    );
  }
}
