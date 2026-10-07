import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// -------------------------------------------------------------
// كرت اختيار بأيقونة داخل مربع (شاشتي "نوع الحساب" و"نوع الرحلة"):
// 361×56 — حدود #1F3B2E — radius 14 — مربع الأيقونة 36×36 بالبداية
// -------------------------------------------------------------
class IconOptionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const IconOptionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  static const _green = Color(0xFF1F3B2E);
  static const _selectedFill = Color(0x1A4C7A75); // #4C7A75 بشفافية 10%

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? _selectedFill : Colors.white,
          border: Border.all(color: _green, width: selected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _green, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 22, color: _green),
            ),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.tajawal(fontSize: 14, color: const Color(0xFF000000))),
          ],
        ),
      ),
    );
  }
}
