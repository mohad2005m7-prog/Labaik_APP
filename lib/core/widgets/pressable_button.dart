import 'package:flutter/widgets.dart';

/// تأثير تغميق الزر عند الضغط (onTapDown → pressedFill، onTapUp/Cancel → fill)
/// مشترك بين FigmaCanvas.button و authButton
class PressableButton extends StatefulWidget {
  final Color fill;
  final Color pressedFill;
  final double radius;
  final BoxBorder? border;
  final VoidCallback? onTap;
  final Widget child;

  const PressableButton({
    super.key,
    required this.fill,
    required this.pressedFill,
    required this.radius,
    this.border,
    this.onTap,
    required this.child,
  });

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: active ? (_) => setState(() => _pressed = true) : null,
      onTapUp: active ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: active ? () => setState(() => _pressed = false) : null,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _pressed && active ? widget.pressedFill : widget.fill,
          borderRadius: BorderRadius.circular(widget.radius),
          border: widget.border,
        ),
        child: widget.child,
      ),
    );
  }
}
