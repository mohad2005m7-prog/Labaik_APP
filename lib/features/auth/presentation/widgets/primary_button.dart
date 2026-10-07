import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// -------------------------------------------------------------
// الزر الأساسي حسب مكوّن Button بـ Figma:
// 361×50 — radius 14 — padding (14 / 20) — لون #1F3B2E
// outlined = true → زر أبيض بحدود خضرا (مثل "لاحقًا")
// -------------------------------------------------------------
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
  });

  static const _green = Color(0xFF1F3B2E);

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    const padding = EdgeInsets.symmetric(vertical: 14, horizontal: 20);
    final text = Text(
      label,
      style: GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: outlined ? _green : Colors.white,
      ),
    );

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: _green, width: 1),
                shape: shape,
                padding: padding,
              ),
              child: text,
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                elevation: 0,
                shape: shape,
                padding: padding,
              ),
              child: text,
            ),
    );
  }
}
