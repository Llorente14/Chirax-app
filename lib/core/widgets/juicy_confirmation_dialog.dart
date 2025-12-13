import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'chunky_button.dart';

/// JuicyConfirmationDialog - Reusable Duolingo-style confirmation dialog
class JuicyConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color themeColor;
  final VoidCallback onConfirm;
  final String confirmText;
  final String cancelText;

  const JuicyConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.icon = Icons.help_outline_rounded,
    this.themeColor = AppColors.primary,
    required this.onConfirm,
    this.confirmText = 'Ya, Lanjut',
    this.cancelText = 'Batal',
  });

  /// Static helper to show dialog
  static Future<bool?> show({
    required String title,
    required String content,
    IconData icon = Icons.help_outline_rounded,
    Color themeColor = AppColors.primary,
    required VoidCallback onConfirm,
    String confirmText = 'Ya, Lanjut',
    String cancelText = 'Batal',
  }) {
    return Get.dialog<bool>(
      JuicyConfirmationDialog(
        title: title,
        content: content,
        icon: icon,
        themeColor: themeColor,
        onConfirm: onConfirm,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
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
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade300, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: const Offset(0, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 28),

            // Icon Circle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: themeColor, width: 3),
              ),
              child: Center(child: Icon(icon, size: 40, color: themeColor)),
            ),
            const SizedBox(height: 20),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                title,
                style: AppTextStyles.headline.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                content,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),

            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(result: false),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: const Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            cancelText,
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Confirm Button
                  Expanded(
                    child: ChunkyButton(
                      text: confirmText,
                      onPressed: () {
                        Get.back(result: true);
                        onConfirm();
                      },
                      color: themeColor,
                      shadowColor: _darkenColor(themeColor),
                      height: 52,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to darken color for shadow
  Color _darkenColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
  }
}
