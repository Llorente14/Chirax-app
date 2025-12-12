import 'package:flutter/material.dart';

/// A 3D-style button with a bouncy press animation and shadow effect.
class Bouncy3DButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color shadowColor;
  final double shadowHeight;
  final BorderRadius borderRadius;

  const Bouncy3DButton({
    super.key,
    required this.child,
    required this.onTap,
    this.shadowColor = Colors.grey,
    this.shadowHeight = 4,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<Bouncy3DButton> createState() => _Bouncy3DButtonState();
}

class _Bouncy3DButtonState extends State<Bouncy3DButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final offset = widget.shadowHeight * _animation.value;
          return Transform.translate(
            offset: Offset(0, offset),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: widget.shadowColor,
                    offset: Offset(0, widget.shadowHeight - offset),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// A list tile with a subtle bouncy animation on tap.
class BouncyListTile extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const BouncyListTile({super.key, required this.child, this.onTap});

  @override
  State<BouncyListTile> createState() => _BouncyListTileState();
}

class _BouncyListTileState extends State<BouncyListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
