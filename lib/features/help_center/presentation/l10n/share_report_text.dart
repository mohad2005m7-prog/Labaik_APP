import '../../../../core/l10n/tx.dart';

/// نصوص "مشاركة البلاغ مع المستخدمين القريبين" (Figma 111:6094) — بنفس سطور وكتابة Figma
abstract final class ShareReportText {
  static const title = Tx('هل ترغب بمشاركة البلاغ؟', 'Share the report?');
  static const description = Tx(
    'قد تساعد مشاركة المعلومات الضرورية مع المعتمرين القريبين في\nالتعرّف على الطفل المفقود.',
    'Sharing the necessary details with nearby pilgrims may help identify the lost child.',
  );
  static const nearby = Tx(
    'يمكنك اختيار مشاركة البلاغ مع مستخدمي التطبيق الموجودين\nبالقرب من آخر مكان شوهد فيه الطفل.',
    'You can share the report with app users near the place where the child was last seen.',
  );
  static const beforeTitle = Tx('قبل المشاركة', 'Before sharing');
  static const before = Tx(
    'تأكّد من صحة المعلومات. ستتم مشاركة التفاصيل اللازمة للتعرّف\nعلى الطفل فقط، وتجنّب نشر معلومات شخصية غير ضرورية.',
    'Check the details are correct. Only what helps identify the child will be shared.',
  );
  static const yes = Tx('نعم , مشاركة البلاغ', 'Yes, share the report');
  static const no = Tx('لا , شكرا', 'No, thanks');
}
