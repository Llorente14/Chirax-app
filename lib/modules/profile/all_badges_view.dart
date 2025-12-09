import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'profile_controller.dart';
import 'widgets/badge_detail_dialog.dart';

class AllBadgesView extends GetView<ProfileController> {
  const AllBadgesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text('Semua Lencana', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: Obx(() {
        final unlockedBadges = controller.badges
            .where((b) => b.isUnlocked)
            .toList();
        final lockedBadges = controller.badges
            .where((b) => !b.isUnlocked)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Row - Solid Duolingo Button Style
              Row(
                children: [
                  // Tercapai Button
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.successShadow,
                            offset: const Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            '${unlockedBadges.length}',
                            style: AppTextStyles.title.copyWith(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Tercapai',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Terkunci Button
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.moneyOrange,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFE65100),
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text('🔒', style: TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            '${lockedBadges.length}',
                            style: AppTextStyles.title.copyWith(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Terkunci',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Total Button
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryShadow,
                            offset: const Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text('🎯', style: TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            '${controller.badges.length}',
                            style: AppTextStyles.title.copyWith(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Total',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // === UNLOCKED BADGES ===
              if (unlockedBadges.isNotEmpty) ...[
                Text(
                  '🏆 LENCANA TERCAPAI',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: unlockedBadges.length,
                  itemBuilder: (context, index) {
                    return _buildBadgeCard(unlockedBadges[index]);
                  },
                ),
                const SizedBox(height: 28),
              ],

              // === LOCKED BADGES ===
              if (lockedBadges.isNotEmpty) ...[
                Text(
                  '🔒 BELUM TERCAPAI',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: lockedBadges.length,
                  itemBuilder: (context, index) {
                    return _buildBadgeCard(lockedBadges[index]);
                  },
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatBox({
    required String icon,
    required String value,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.4),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.title.copyWith(fontSize: 20, color: textColor),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(badge) {
    return GestureDetector(
      onTap: () => BadgeDetailDialog.show(badge),
      child: Column(
        children: [
          // Badge Circle
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: badge.isUnlocked
                  ? badge.color.withValues(alpha: 0.15)
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
              border: Border.all(
                color: badge.isUnlocked ? badge.color : Colors.grey.shade400,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: badge.isUnlocked
                      ? badge.color.withValues(alpha: 0.4)
                      : Colors.grey.shade400,
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: badge.isUnlocked
                  ? Text(badge.iconEmoji, style: const TextStyle(fontSize: 32))
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: 0.3,
                          child: Text(
                            badge.iconEmoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                        const Icon(
                          Icons.lock_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 8),
          // Badge Name
          SizedBox(
            width: 80,
            child: Text(
              badge.name,
              style: AppTextStyles.bodySmall.copyWith(
                color: badge.isUnlocked ? AppColors.textPrimary : Colors.grey,
                fontWeight: badge.isUnlocked
                    ? FontWeight.w600
                    : FontWeight.normal,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Progress indicator for locked
          if (!badge.isUnlocked) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: badge.progressPercentage,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(badge.color),
                  minHeight: 4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
