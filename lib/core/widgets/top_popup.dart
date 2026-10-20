import 'package:flutter/material.dart';

import '../utils/design_scale.dart';

// -------------------------------------------------------------
// النوافذ المنبثقة (بوب أب) بتنزل من فوق الشاشة وبتثبت بالنص، ولما تسكّر بترجع لفوق
// ("مع من تريد التتبع؟" و"تم التأكيد") — [height] ارتفاع الكرت بأرقام Figma والكرت بعرض الشاشة
// -------------------------------------------------------------
Future<T?> showTopPopup<T>(BuildContext context, {required String label, required WidgetBuilder builder, bool dismissible = true}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: label,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 320),
    // الصفحة كلها (والكرت بنصها) بتبلش فوق الشاشة بطولها وبتنزل لمكانها
    transitionBuilder: (context, animation, _, child) => SlideTransition(
      position: Tween(begin: const Offset(0, -1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic)),
      child: child,
    ),
    pageBuilder: (context, _, _) => builder(context),
  );
}

/// مكان الكرت: بنص الشاشة
class TopPopup extends StatelessWidget {
  final double height;
  final Widget child;

  const TopPopup({super.key, required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    final s = DesignScale.of(context);
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(width: MediaQuery.sizeOf(context).width, height: s.y(height), child: child),
      ),
    );
  }
}
