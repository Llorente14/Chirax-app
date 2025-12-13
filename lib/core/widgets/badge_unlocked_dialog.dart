import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../data/models/badge_model.dart';

/// Dialog Perayaan Badge Unlock - Soft Grey 3D Style
class BadgeUnlockedDialog extends StatefulWidget {
  final BadgeModel badge;

  const BadgeUnlockedDialog({super.key, required this.badge});

  /// Static helper untuk menampilkan dialog
  static void show(BadgeModel badge) {
    Get.dialog(
      BadgeUnlockedDialog(badge: badge),
      barrierColor: Colors.black.withValues(alpha: 0.7),
      barrierDismissible: false,
    );
  }

  @override
  State<BadgeUnlockedDialog> createState() => _BadgeUnlockedDialogState();
}

class _BadgeUnlockedDialogState extends State<BadgeUnlockedDialog>
    with TickerProviderStateMixin {
  // IMPORTANT: Use late final to avoid late initialization errors
  late final AnimationController _scaleController;
  late final AnimationController _rotationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation for badge bounce
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Rotation animation for sunburst
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController);

    // Start animations
    _scaleController.forward();
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.textPrimary, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFE0E0E0), // Soft grey
              offset: Offset(0, 12),
              blurRadius: 0,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // === SUNBURST + BADGE ICON ===
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Sunburst rays (rotating)
                      AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationAnimation.value * 2 * 3.14159,
                            child: _buildSunburst(),
                          );
                        },
                      ),

                      // Badge Icon (bouncing)
                      AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.badge.color,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.badge.color.withValues(
                                      alpha: 0.3,
                                    ),
                                    offset: const Offset(0, 6),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  widget.badge.iconEmoji,
                                  style: const TextStyle(fontSize: 48),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // === "LENCANA BARU!" Text ===
                Text(
                  'LENCANA BARU!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFAA00), // Gold/Orange
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 12),

                // === Badge Name ===
                Text(
                  widget.badge.name,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                // === Description ===
                Text(
                  widget.badge.description,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                // === Progress Bar (if has progress) ===
                if (widget.badge.targetProgress > 0) ...[
                  const SizedBox(height: 20),
                  _buildProgressSection(),
                ],

                const SizedBox(height: 24),

                // === "KEREN!" Button ===
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.textPrimary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.successShadow,
                          offset: const Offset(0, 5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'KEREN!',
                        style: AppTextStyles.button.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Sunburst rays widget
  Widget _buildSunburst() {
    return CustomPaint(
      size: const Size(140, 140),
      painter: _SunburstPainter(
        color: const Color(0xFFFFF9E6), // Very light yellow
      ),
    );
  }

  /// Progress section
  Widget _buildProgressSection() {
    final progress = widget.badge.currentProgress / widget.badge.targetProgress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.badge.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.badge.color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(widget.badge.color),
              minHeight: 12,
            ),
          ),

          const SizedBox(height: 8),

          // Progress text
          Text(
            '${widget.badge.currentProgress}/${widget.badge.targetProgress}',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: widget.badge.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for sunburst rays
class _SunburstPainter extends CustomPainter {
  final Color color;

  _SunburstPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    const rayCount = 12;
    const innerRadius = 35.0;
    const outerRadius = 70.0;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * 3.14159) / rayCount;
      final nextAngle = ((i + 0.5) * 2 * 3.14159) / rayCount;

      final path = Path();
      path.moveTo(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      );
      path.lineTo(
        center.dx + outerRadius * cos(nextAngle),
        center.dy + outerRadius * sin(nextAngle),
      );
      path.lineTo(
        center.dx + innerRadius * cos((i + 1) * 2 * 3.14159 / rayCount),
        center.dy + innerRadius * sin((i + 1) * 2 * 3.14159 / rayCount),
      );
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  double cos(double radians) => _cos(radians);
  double sin(double radians) => _sin(radians);

  static double _cos(double radians) {
    return (radians == 0)
        ? 1
        : (radians == 3.14159 / 2)
        ? 0
        : (radians == 3.14159)
        ? -1
        : (radians == 3 * 3.14159 / 2)
        ? 0
        : _cosApprox(radians);
  }

  static double _sin(double radians) {
    return (radians == 0)
        ? 0
        : (radians == 3.14159 / 2)
        ? 1
        : (radians == 3.14159)
        ? 0
        : (radians == 3 * 3.14159 / 2)
        ? -1
        : _sinApprox(radians);
  }

  static double _cosApprox(double x) {
    // Taylor series approximation
    double result = 1.0;
    double term = 1.0;
    for (int n = 1; n <= 10; n++) {
      term *= -x * x / ((2 * n - 1) * (2 * n));
      result += term;
    }
    return result;
  }

  static double _sinApprox(double x) {
    // Taylor series approximation
    double result = x;
    double term = x;
    for (int n = 1; n <= 10; n++) {
      term *= -x * x / ((2 * n) * (2 * n + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
