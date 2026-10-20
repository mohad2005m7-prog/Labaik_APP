import 'package:flutter/material.dart';

import '../../../../core/l10n/tx.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/design_scale.dart';
import '../../data/models/crowd_level.dart';
import '../../data/models/destination_info_dto.dart';
import '../l10n/gate_text.dart';
import 'field_colors.dart';

// -------------------------------------------------------------
// بطاقة الباب (بتطلع من تحت الخريطة لما المستخدم يضغط على باب):
//   صورة الباب (رابط من السيرفر imageUrl — وقبل ما توصل: مكان الصورة مع رقم الباب)
//   اسم الباب بلغة التطبيق وتحته باللغة الثانية — رقم الباب — حالة الازدحام (لو السيرفر بعتها)
//   "اتجه إلى هذا الباب" (أو "وجهتك الحالية" إذا هو الوجهة) — وزر إغلاق
// -------------------------------------------------------------
class GateInfoCard extends StatelessWidget {
  final DestinationInfoDto gate;
  final DesignScale scale;
  final bool isDestination;
  final VoidCallback onGo;
  final VoidCallback onClose;

  const GateInfoCard({
    super.key,
    required this.gate,
    required this.scale,
    required this.isDestination,
    required this.onGo,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final language = AppLanguage.code;
    final imageSize = s.x(92);

    return Container(
      // فوق حقوق الخريطة (تحت) بشوي حتى تضل ظاهرة
      margin: EdgeInsetsDirectional.fromSTEB(s.x(10), 0, s.x(10), s.x(26)),
      padding: EdgeInsetsDirectional.all(s.x(10)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s.x(14)),
        boxShadow: [BoxShadow(color: const Color(0x331F3B2E), blurRadius: s.x(12), offset: Offset(0, s.x(4)))],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(s.x(10)),
                child: SizedBox(width: imageSize, height: imageSize, child: _GateImage(gate: gate, scale: s)),
              ),
              SizedBox(width: s.x(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(end: s.x(26)),
                      child: Text(
                        gate.name(language),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: figmaText(s, size: 16, weight: FigmaWeight.semiBold, color: FieldColors.green, lineHeight: 22),
                      ),
                    ),
                    Text(
                      gate.otherName(language),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: language == 'ar' ? TextDirection.ltr : TextDirection.rtl,
                      style: figmaText(s, size: 12, weight: FigmaWeight.sfRegular, color: FieldColors.grey, lineHeight: 18),
                    ),
                    SizedBox(height: s.x(6)),
                    Wrap(
                      spacing: s.x(6),
                      runSpacing: s.x(4),
                      children: [
                        if (gate.gateNumber != null)
                          _Chip(
                            scale: s,
                            text: GateText.number('${gate.gateNumber}'),
                            color: FieldColors.accent,
                          ),
                        if (gate.crowdLevel != null) _Chip(scale: s, text: _crowdText(gate.crowdLevel!)(), color: _crowdColor(gate.crowdLevel!)),
                      ],
                    ),
                    SizedBox(height: s.x(8)),
                    isDestination ? _CurrentDestination(scale: s) : _GoButton(scale: s, onTap: onGo),
                  ],
                ),
              ),
            ],
          ),
          PositionedDirectional(
            top: -s.x(4),
            end: -s.x(4),
            child: Tooltip(
              message: GateText.close(),
              child: InkResponse(
                onTap: onClose,
                radius: s.x(18),
                child: Padding(
                  padding: EdgeInsets.all(s.x(4)),
                  child: Icon(Icons.close_rounded, size: s.x(20), color: FieldColors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Tx _crowdText(CrowdLevel level) => switch (level) {
    CrowdLevel.low => GateText.crowdLow,
    CrowdLevel.medium => GateText.crowdMedium,
    CrowdLevel.high => GateText.crowdHigh,
  };

  static Color _crowdColor(CrowdLevel level) => switch (level) {
    CrowdLevel.low => const Color(0xFF2E7C58),
    CrowdLevel.medium => const Color(0xFFC98A1B),
    CrowdLevel.high => const Color(0xFFC0392B),
  };
}

/// صورة الباب من السيرفر (بتظهر بنعومة) — أو مكانها مع رقم الباب
class _GateImage extends StatelessWidget {
  final DestinationInfoDto gate;
  final DesignScale scale;

  const _GateImage({required this.gate, required this.scale});

  @override
  Widget build(BuildContext context) {
    final url = gate.imageUrl;
    if (url == null) return _placeholder();
    return Image.network(
      url,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, synchronous) => synchronous
          ? child
          : AnimatedOpacity(opacity: frame == null ? 0 : 1, duration: const Duration(milliseconds: 250), child: child),
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Stack(
              fit: StackFit.expand,
              children: [
                _placeholder(),
                Center(
                  child: SizedBox(
                    width: scale.x(22),
                    height: scale.x(22),
                    child: const CircularProgressIndicator(strokeWidth: 2, color: FieldColors.accent),
                  ),
                ),
              ],
            ),
      errorBuilder: (context, error, stack) => _placeholder(),
    );
  }

  Widget _placeholder() => ColoredBox(
    color: FieldColors.cardFill,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.door_front_door_outlined, size: scale.x(30), color: FieldColors.accent),
        if (gate.gateNumber != null)
          Text('${gate.gateNumber}', style: figmaText(scale, size: 14, weight: FigmaWeight.semiBold, color: FieldColors.accent, lineHeight: 18)),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  final DesignScale scale;
  final String text;
  final Color color;

  const _Chip({required this.scale, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: scale.x(8), vertical: scale.x(2)),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(scale.x(8))),
      child: Text(text, style: figmaText(scale, size: 11, weight: FigmaWeight.semiBold, color: color, lineHeight: 18)),
    );
  }
}

class _GoButton extends StatelessWidget {
  final DesignScale scale;
  final VoidCallback onTap;

  const _GoButton({required this.scale, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FieldColors.green,
      borderRadius: BorderRadius.circular(scale.x(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(scale.x(10)),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: scale.x(12), vertical: scale.x(5)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_walk_rounded, size: scale.x(16), color: Colors.white),
              SizedBox(width: scale.x(4)),
              Text(GateText.go(), style: figmaText(scale, size: 13, weight: FigmaWeight.semiBold, color: Colors.white, lineHeight: 20)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentDestination extends StatelessWidget {
  final DesignScale scale;

  const _CurrentDestination({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, size: scale.x(16), color: FieldColors.accent),
        SizedBox(width: scale.x(4)),
        Text(GateText.current(), style: figmaText(scale, size: 13, weight: FigmaWeight.semiBold, color: FieldColors.accent, lineHeight: 20)),
      ],
    );
  }
}
