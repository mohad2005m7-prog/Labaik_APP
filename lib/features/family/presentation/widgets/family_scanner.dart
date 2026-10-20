import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/utils/design_scale.dart';

// -------------------------------------------------------------
// مربع مسح QR بـ "الانضمام" (Figma "image 4" 200×200): 4 زوايا بخط 6 مدوّرة وخط بالنص
// الضغط عليه بيشغّل الكاميرا جوّاه (mobile_scanner) — أول رمز دائرة بيوصل لـ [onCode] وبتوقف الكاميرا
// [onCameraError]: الكاميرا مرفوضة أو مش متوفرة
// -------------------------------------------------------------
class FamilyScanner extends StatefulWidget {
  final DesignScale s;
  final ValueChanged<String> onCode;
  final VoidCallback onInvalid;
  final VoidCallback onCameraError;

  const FamilyScanner({super.key, required this.s, required this.onCode, required this.onInvalid, required this.onCameraError});

  /// رمز الدائرة من محتوى QR: الرابط (labaik://family/join?code=…) أو الرمز نفسه
  static String? codeFrom(String raw) {
    final text = raw.trim();
    final uri = Uri.tryParse(text);
    final fromLink = uri?.queryParameters['code'];
    final code = (fromLink ?? text).trim().toUpperCase();
    return RegExp(r'^[A-Z0-9]{4,12}$').hasMatch(code) ? code : null;
  }

  @override
  State<FamilyScanner> createState() => _FamilyScannerState();
}

class _FamilyScannerState extends State<FamilyScanner> {
  MobileScannerController? _camera;
  bool _handled = false;

  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }

  void _start() {
    if (_camera != null) return;
    setState(() {
      _handled = false;
      _camera = MobileScannerController(formats: const [BarcodeFormat.qrCode]);
    });
  }

  Future<void> _stop() async {
    final camera = _camera;
    if (camera == null) return;
    setState(() => _camera = null);
    await camera.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      _handled = true;
      final code = FamilyScanner.codeFrom(raw);
      _stop();
      code == null ? widget.onInvalid() : widget.onCode(code);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final camera = _camera;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: camera == null ? _start : _stop,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (camera != null)
            Padding(
              padding: EdgeInsets.all(widget.s.x(9)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.s.x(8)),
                child: MobileScanner(
                  controller: camera,
                  onDetect: _onDetect,
                  errorBuilder: (context, error) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _camera != null) {
                        _stop();
                        widget.onCameraError();
                      }
                    });
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          IgnorePointer(child: CustomPaint(painter: _CornersPainter(scale: widget.s.x(1), light: camera != null))),
        ],
      ),
    );
  }
}

/// الزوايا والخط (مقاسة من لقطة Figma على مربع 200×200)
class _CornersPainter extends CustomPainter {
  final double scale;

  /// فوق الكاميرا: الخط بالنص بيختفي والزوايا بيضا
  final bool light;

  _CornersPainter({required this.scale, required this.light});

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 200;
    final paint = Paint()
      ..color = light ? Colors.white : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // مراكز الخطوط: الزوايا من 10.5 لـ 189 أفقياً ومن 10 لـ 188.5 عمودياً — الأذرع الأفقية 53 والعمودية 47.5 فوق و51 تحت
    const l = 10.5, r = 189.0, t = 10.0, b = 188.5, arm = 53.0, radius = 10.0;
    Path corner(double x, double y, double dx, double dy, double armY) => Path()
      ..moveTo((x + dx * arm) * k, y * k)
      ..lineTo((x + dx * radius) * k, y * k)
      ..quadraticBezierTo(x * k, y * k, x * k, (y + dy * radius) * k)
      ..lineTo(x * k, (y + dy * armY) * k);
    canvas
      ..drawPath(corner(l, t, 1, 1, 47.5), paint)
      ..drawPath(corner(r, t, -1, 1, 47.5), paint)
      ..drawPath(corner(l, b, 1, -1, 51), paint)
      ..drawPath(corner(r, b, -1, -1, 51), paint);
    if (!light) canvas.drawLine(Offset(6 * k, 99 * k), Offset(193 * k, 99 * k), paint);
  }

  @override
  bool shouldRepaint(_CornersPainter old) => old.scale != scale || old.light != light;
}
