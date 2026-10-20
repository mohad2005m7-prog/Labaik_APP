import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/figma_text.dart';
import 'supervisor_widgets.dart';

// -------------------------------------------------------------
// عارض الصور (زي انستغرام): الصورة بتكبر من مكانها (Hero) لخلفية سودا
//   - الصورة الشخصية بتطلع فوراً بنسختها المصغّرة (موجودة بالذاكرة) والنسخة الكاملة بتظهر فوقها أول ما تجهز
//   - تكبير بإصبعين أو بضغطتين
//   - سحب لتحت (أو لفوق) بيسكّر العارض والخلفية بتختفي تدريجياً
// [avatar]: صورة شخص (مربعة، بتتحول من دايرة) — غير هيك (مرفق إعلان) بتنعرض كاملة بنسبتها
// -------------------------------------------------------------
class SupPhotoViewer extends StatefulWidget {
  final String photo;
  final Object heroTag;
  final String? title;
  final bool avatar;

  const SupPhotoViewer({super.key, required this.photo, required this.heroTag, this.title, this.avatar = true});

  static Future<void> open(BuildContext context, {required String photo, required Object heroTag, String? title, bool avatar = true}) {
    // فك الصورة الكاملة بيبدأ مع الانتقال (مش بعده)
    precacheImage(supImageProvider(photo), context);
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, _, _) => SupPhotoViewer(photo: photo, heroTag: heroTag, title: title, avatar: avatar),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<SupPhotoViewer> createState() => _SupPhotoViewerState();
}

class _SupPhotoViewerState extends State<SupPhotoViewer> with SingleTickerProviderStateMixin {
  final _zoom = TransformationController();
  late final _settle = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  double _drag = 0;
  double _settleFrom = 0;
  Offset _doubleTapAt = Offset.zero;

  bool get _zoomed => _zoom.value.getMaxScaleOnAxis() > 1.01;

  @override
  void initState() {
    super.initState();
    _settle.addListener(() => setState(() => _drag = _settleFrom * (1 - Curves.easeOut.transform(_settle.value))));
  }

  @override
  void dispose() {
    _zoom.dispose();
    _settle.dispose();
    super.dispose();
  }

  // السحب بإصبع واحد والصورة مش مكبّرة = تسكير
  // (Listener بيشوف حركة الإصبع بدون ما ينافس InteractiveViewer على التكبير بإصبعين)
  final _pointers = <int>{};
  VelocityTracker? _velocity;

  void _onDown(PointerDownEvent e) {
    _pointers.add(e.pointer);
    _velocity = VelocityTracker.withKind(e.kind)..addPosition(e.timeStamp, e.position);
  }

  void _onMove(PointerMoveEvent e) {
    if (_pointers.length != 1 || _zoomed) return;
    _velocity?.addPosition(e.timeStamp, e.position);
    setState(() => _drag += e.delta.dy);
  }

  void _onUp(PointerEvent e) {
    _pointers.remove(e.pointer);
    if (_pointers.isNotEmpty) return;
    if (_zoomed) {
      setState(() {});
      return;
    }
    if (_drag == 0) return;
    final v = _velocity?.getVelocity().pixelsPerSecond.dy ?? 0;
    if (_drag.abs() > 110 || v.abs() > 900) {
      Navigator.maybePop(context);
      return;
    }
    _settleFrom = _drag;
    _settle.forward(from: 0);
  }

  void _toggleZoom() {
    if (_zoomed) {
      setState(() => _zoom.value = Matrix4.identity());
      return;
    }
    const scale = 2.5;
    final p = _doubleTapAt;
    setState(
      () => _zoom.value = Matrix4.identity()
        ..translateByDouble(-p.dx * (scale - 1), -p.dy * (scale - 1), 0, 1)
        ..scaleByDouble(scale, scale, 1, 1),
    );
  }

  Widget _photo() {
    final fit = widget.avatar ? BoxFit.cover : BoxFit.contain;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.avatar) Image(image: supImageProvider(widget.photo, cacheWidth: supThumbPixels), fit: fit),
        Image(
          image: supImageProvider(widget.photo),
          fit: fit,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
          frameBuilder: (_, child, frame, sync) =>
              sync ? child : AnimatedOpacity(opacity: frame == null ? 0 : 1, duration: const Duration(milliseconds: 150), child: child),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final side = size.width;
    final opacity = (1 - _drag.abs() / 360).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: opacity),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Listener(
              onPointerDown: _onDown,
              onPointerMove: _onMove,
              onPointerUp: _onUp,
              onPointerCancel: _onUp,
              child: GestureDetector(
                onDoubleTapDown: (d) => _doubleTapAt = d.localPosition,
                onDoubleTap: _toggleZoom,
                child: Transform.translate(
                  offset: Offset(0, _drag),
                  child: InteractiveViewer(
                    transformationController: _zoom,
                    minScale: 1,
                    maxScale: 4,
                    // التحريك بس لما تكون مكبّرة — غير هيك السحب بيسكّر العارض
                    panEnabled: _zoomed,
                    onInteractionEnd: (_) => setState(() {}),
                    child: Center(
                      child: Hero(
                        tag: widget.heroTag,
                        flightShuttleBuilder: widget.avatar ? supPhotoFlight : null,
                        child: SizedBox(width: side, height: widget.avatar ? side : size.height * 0.75, child: _photo()),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // الاسم وزر الإغلاق فوق
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Opacity(
                opacity: opacity,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      ),
                      if (widget.title != null)
                        Expanded(
                          child: Text(
                            widget.title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'NotoSansArabic', fontVariations: [FontVariation('wght', FigmaWeight.semiBold)], fontSize: 17, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
