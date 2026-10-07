import 'package:flutter/material.dart';

// -------------------------------------------------------------
// CircleIconButton
// زر دائري بأيقونة بخلفية بيضاء وحدود رمادية فاتحة.
// مستخدم بهيدر شاشة الرئيسية (القائمة/التنبيهات)، وقابل لإعادة
// الاستخدام بأي هيدر تاني بالتطبيق.
// -------------------------------------------------------------
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(size),
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE3E6E4)),
        ),
        child: Icon(icon, size: size * 0.48, color: const Color(0xFF1E1E1E)),
      ),
    );
  }
}
