import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// -------------------------------------------------------------
// هيدر شاشات إعداد الرحلة (393×59 حسب Figma):
// العنوان وسهم الرجوع "<" بنفس السطر.
// بالعربي: العنوان يمين والسهم يسار — بالإنجليزي: السهم يسار والعنوان بعده.
// -------------------------------------------------------------
class SetupHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const SetupHeader({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final back = InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onBack ?? () => Navigator.maybePop(context),
      child: const SizedBox(
        width: 24,
        height: 24,
        // نثبّت اتجاه الأيقونة حتى تضل "<" بالعربي والإنجليزي
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF000000)),
        ),
      ),
    );

    final titleText = Expanded(
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.tajawal(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F3B2E),
        ),
      ),
    );

    return SizedBox(
      height: 59,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: isRtl
              ? [titleText, const SizedBox(width: 12), back]
              : [back, const SizedBox(width: 12), titleText],
        ),
      ),
    );
  }
}
