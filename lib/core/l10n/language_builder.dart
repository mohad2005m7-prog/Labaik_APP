import 'package:flutter/widgets.dart';

import 'app_language.dart';

// -------------------------------------------------------------
// بيعيد بناء كل الشاشات تحته لما تتغير لغة التطبيق:
// حتى الشاشات المفتوحة بالخلفية والتبويبات المحفوظة (اللي ما بتنبني من جديد لحالها)
// بتاخد نصوصها واتجاهها الجديد فوراً — بيصير مرة وحدة عند تغيير اللغة بس
// -------------------------------------------------------------
class LanguageBuilder extends StatefulWidget {
  final WidgetBuilder builder;

  const LanguageBuilder({super.key, required this.builder});

  @override
  State<LanguageBuilder> createState() => _LanguageBuilderState();
}

class _LanguageBuilderState extends State<LanguageBuilder> {
  @override
  void initState() {
    super.initState();
    AppLanguage.notifier.addListener(_rebuildAll);
  }

  @override
  void dispose() {
    AppLanguage.notifier.removeListener(_rebuildAll);
    super.dispose();
  }

  void _rebuildAll() {
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
