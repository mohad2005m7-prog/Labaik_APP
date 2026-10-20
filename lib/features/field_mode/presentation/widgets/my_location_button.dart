import 'package:flutter/material.dart';

import '../../../../core/utils/design_scale.dart';
import '../l10n/field_mode_text.dart';
import 'field_colors.dart';

// -------------------------------------------------------------
// زر "موقعي" فوق الخريطة (زي زر Google: مربع أبيض فوق يمين الخريطة)
// للخريطة البديلة وللموقع التجريبي (زر Google الأصلي بيروح لـ GPS الجهاز بس)
// -------------------------------------------------------------
class MyLocationButton extends StatelessWidget {
  final DesignScale scale;
  final VoidCallback onTap;

  const MyLocationButton({super.key, required this.scale, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = scale.x(38);
    return Positioned(
      top: scale.x(10),
      right: scale.x(10),
      child: Tooltip(
        message: FieldModeText.myLocation(),
        child: Material(
          color: Colors.white,
          elevation: 2,
          borderRadius: BorderRadius.circular(scale.x(8)),
          child: InkWell(
            borderRadius: BorderRadius.circular(scale.x(8)),
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(Icons.my_location, size: scale.x(20), color: FieldColors.green),
            ),
          ),
        ),
      ),
    );
  }
}
