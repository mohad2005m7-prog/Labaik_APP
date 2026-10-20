import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import 'family_colors.dart';

// -------------------------------------------------------------
// رمز QR لدائرتي (Figma 163×163 أسود على أبيض) — محتواه رابط الانضمام (labaik://family/join?code=…)
// لحد ما ينشئ السيرفر الدائرة: دوّارة — ولو فشل: سبب الخطأ والضغط بيعيد المحاولة
// -------------------------------------------------------------
class FamilyQrBox extends StatelessWidget {
  final DesignScale s;
  final String? data;
  final String? error;
  final VoidCallback onRetry;

  const FamilyQrBox({super.key, required this.s, required this.data, required this.error, required this.onRetry});

  static String payload(String code, String? inviteLink) => inviteLink ?? 'labaik://family/join?code=$code';

  @override
  Widget build(BuildContext context) {
    final value = data;
    if (value != null) {
      return QrImageView(
        data: value,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
      );
    }
    final message = error;
    if (message == null) {
      return Center(child: SizedBox.square(dimension: s.x(26), child: const CircularProgressIndicator(strokeWidth: 2.5, color: FamilyColors.green)));
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onRetry,
      child: Center(
        child: Text(message, textAlign: TextAlign.center, style: figmaText(s, size: 13, weight: FigmaWeight.sfRegular, color: FamilyColors.grey, lineHeight: null, letterSpacing: 0)),
      ),
    );
  }
}
