import 'package:flutter/material.dart';

// -------------------------------------------------------------
// شريط التقدم (Slider) بأعلى شاشات إعداد الرحلة.
// حسب Figma: 7 خطوط، ارتفاع 3، مسافة 16 بينهم، ويمتلئ من جهة البداية.
// thickness / spacing قابلين للتغيير (كرت الاستعداد بالرئيسية: سمك 7 ومسافة 6)
// -------------------------------------------------------------
class CustomStepProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double thickness;
  final double spacing;

  const CustomStepProgress({
    super.key,
    required this.currentStep,
    this.totalSteps = 7,
    this.thickness = 4,
    this.spacing = 16,
  });

  static const _activeColor = Color(0xFF1F3B2E);
  static const _inactiveColor = Color(0x801F3B2E); // #717171 بشفافية 60%

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        return Expanded(
          child: Container(
            height: thickness,
            margin: EdgeInsetsDirectional.only(start: index == 0 ? 0 : spacing),
            decoration: BoxDecoration(
              color: index < currentStep ? _activeColor : _inactiveColor,
              borderRadius: BorderRadius.circular(thickness / 2),
            ),
          ),
        );
      }),
    );
  }
}
