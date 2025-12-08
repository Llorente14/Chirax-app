import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// ChunkyButton - Tombol 3D style Duolingo
/// Menggunakan Stack untuk efek shadow yang lebih jelas
class ChunkyButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final IconData? icon;
  final double width;
  final double height;
  final double shadowHeight;

  const ChunkyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.primary,
    this.shadowColor = AppColors.primaryShadow,
    this.textColor = Colors.white,
    this.icon,
    this.width = double.infinity,
    this.height = 55.0,
    this.shadowHeight = 6.0, // Tinggi efek 3D shadow
  });

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Saat ditekan, tombol "turun" dan shadow berkurang
    final double pressOffset = _isPressed ? widget.shadowHeight : 0.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        width: widget.width,
        height: widget.height + widget.shadowHeight,
        child: Stack(
          children: [
            // === LAYER 1: SHADOW (di bawah) ===
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.shadowColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            // === LAYER 2: BUTTON (di atas) ===
            AnimatedPositioned(
              duration: const Duration(milliseconds: 80),
              left: 0,
              right: 0,
              top: pressOffset,
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: widget.textColor, size: 24),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text.toUpperCase(),
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
