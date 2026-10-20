import '../../../../core/l10n/tx.dart';
import '../l10n/terms_text.dart';

/// فقرة: العنوان الأخضر والنص — [baseline]: خط كتابة أول سطر بإطار Figma
class TermsParagraph {
  final Tx label;
  final Tx body;
  final double baseline;

  const TermsParagraph(this.label, this.body, {required this.baseline});
}

/// قسم = تبويب + كرته (مكان الكرت وطوله وتباعد سطوره من Figma — الكروت "Hug" فأطوالها مش متساوية)
class TermsSection {
  final Tx tab;
  final double top;
  final double height;

  /// المسافة بين السطور (22 — وبكرت سياسة الاسترجاع auto = 19.25)
  final double lineHeight;
  final List<TermsParagraph> paragraphs;

  const TermsSection({required this.tab, required this.top, required this.height, required this.lineHeight, required this.paragraphs});

  // -------------------------------------------------------------
  // إطار Figma عرضه 391 — الأرقام هون بعد توسيطه بشاشة 393 (+1 أفقياً)
  // الكروت: x17 عرض 359 — بينهم 16 — النص من x35.5 لـ x354.5
  // -------------------------------------------------------------
  static const all = [
    TermsSection(
      tab: TermsText.tabTerms,
      top: 199,
      height: 234.5,
      lineHeight: 22,
      paragraphs: [
        TermsParagraph(TermsText.introLabel, TermsText.intro, baseline: 237.25),
        TermsParagraph(TermsText.dutiesLabel, TermsText.duties, baseline: 360.25),
      ],
    ),
    TermsSection(
      tab: TermsText.tabPrivacy,
      top: 449.5,
      height: 234,
      lineHeight: 22,
      paragraphs: [
        TermsParagraph(TermsText.dataLabel, TermsText.data, baseline: 493.5),
        TermsParagraph(TermsText.protectionLabel, TermsText.protection, baseline: 590.5),
      ],
    ),
    TermsSection(
      tab: TermsText.tabRefund,
      top: 699.5,
      height: 163.5,
      lineHeight: 19.25,
      paragraphs: [
        TermsParagraph(TermsText.cancelLabel, TermsText.cancel, baseline: 740.1),
        TermsParagraph(TermsText.refundLabel, TermsText.refund, baseline: 809.1),
      ],
    ),
  ];
}
