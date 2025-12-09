import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/badge_model.dart';

/// Dialog Detail Badge - Trading Card Style
class BadgeDetailDialog extends StatelessWidget {
  final BadgeModel badge;

  const BadgeDetailDialog({super.key, required this.badge});

  /// Static helper untuk menampilkan dialog
  static void show(BadgeModel badge) {
    Get.dialog(
      BadgeDetailDialog(badge: badge),
      barrierColor: Colors.black.withValues(alpha: 0.7),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.textPrimary, width: 3),
          boxShadow: [
            BoxShadow(
              color: badge.color.withValues(alpha: 0.4),
              offset: const Offset(0, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // === HEADER dengan warna konsisten ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(21),
                  topRight: Radius.circular(21),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    offset: const Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Badge Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: badge.color, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          offset: const Offset(0, 5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: badge.isUnlocked
                          ? Text(
                              badge.iconEmoji,
                              style: const TextStyle(fontSize: 48),
                            )
                          : Opacity(
                              opacity: 0.3,
                              child: Text(
                                badge.iconEmoji,
                                style: const TextStyle(fontSize: 48),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // === BODY ===
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Badge Name
                  Text(
                    badge.name,
                    style: AppTextStyles.headline.copyWith(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badge.isUnlocked
                          ? AppColors.success.withValues(alpha: 0.15)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: badge.isUnlocked
                            ? AppColors.success
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          badge.isUnlocked
                              ? Icons.check_circle_rounded
                              : Icons.lock_rounded,
                          size: 16,
                          color: badge.isUnlocked
                              ? AppColors.success
                              : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          badge.isUnlocked ? 'Tercapai!' : 'Belum Tercapai',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: badge.isUnlocked
                                ? AppColors.success
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    badge.description,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Progress Bar
                  Column(
                    children: [
                      // Progress Label
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            badge.progressText,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: badge.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress Bar
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            // Fill
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: badge.progressPercentage,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: badge.color,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: badge.color.withValues(alpha: 0.5),
                                      offset: const Offset(0, 2),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Percent
                      Text(
                        '${badge.progressPercent}%',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: badge.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Close Button
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: badge.isUnlocked
                            ? badge.color
                            : AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (badge.isUnlocked ? badge.color : Colors.grey)
                                    .withValues(alpha: 0.5),
                            offset: const Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          badge.isUnlocked ? '🎉 KEREN!' : 'TUTUP',
                          style: AppTextStyles.button.copyWith(fontSize: 16),
                        ),
                      ),
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
}
