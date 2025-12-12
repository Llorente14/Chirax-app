import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/bouncy_widgets.dart';
import 'profile_controller.dart';
import 'settings_view.dart';
import 'edit_profile_view.dart';
import 'all_badges_view.dart';
import 'widgets/badge_detail_dialog.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === HEADER ===
              _buildHeader(),

              const SizedBox(height: 24),

              // === STATS GRID ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() => _buildStatsSection()),
              ),

              const SizedBox(height: 24),

              // === BADGES ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() => _buildBadgesSection()),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.offWhite,
          ],
        ),
      ),
      child: Column(
        children: [
          // AppBar Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Profil', style: AppTextStyles.headline),
                // Settings Button
                GestureDetector(
                  onTap: () => Get.to(() => const SettingsView()),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          offset: const Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.settings_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // === JUICY AVATAR (3D Squircle) ===
          _buildJuicyAvatar(),

          const SizedBox(height: 16),

          // User Info
          Obx(
            () => Text(
              controller.name,
              style: AppTextStyles.headline.copyWith(fontSize: 26),
            ),
          ),
          const SizedBox(height: 4),
          Obx(
            () => Text(
              controller.username,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Birth Date Badge
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cake_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    controller.birthDate,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 3D Squircle Avatar dengan Edit Button
  Widget _buildJuicyAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Layer 1: Shadow
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(35),
          ),
        ),
        // Layer 2: Border Container
        Positioned(
          top: 0,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: AppColors.textPrimary, width: 4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Obx(() {
                final avatar = controller.avatarAsset;
                if (avatar == 'default') {
                  return Container(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    child: const Center(
                      child: Text('👤', style: TextStyle(fontSize: 50)),
                    ),
                  );
                }
                return Image.asset(
                  avatar,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      child: const Center(
                        child: Text('👤', style: TextStyle(fontSize: 50)),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ),
        // Layer 3: Edit Button
        Positioned(
          right: -8,
          bottom: 0,
          child: GestureDetector(
            onTap: () => Get.to(() => const EditProfileView()),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.5),
                    offset: const Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STATISTIK HUBUNGAN',
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
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: controller.statsList.length,
          itemBuilder: (context, index) {
            final stat = controller.statsList[index];
            return _buildStatCard(stat);
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    final color = stat['color'] as Color;
    final hasSublabel = stat.containsKey('sublabel');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat['icon'] as IconData, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    stat['value'] as String,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 18,
                      color: color,
                    ),
                  ),
                ),
                Text(
                  stat['label'] as String,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasSublabel)
                  Text(
                    stat['sublabel'] as String,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'KOLEKSI LENCANA',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${controller.badges.where((b) => b.isUnlocked).length}/${controller.badges.length}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            Bouncy3DButton(
              onTap: () => Get.to(() => const AllBadgesView()),
              shadowColor: AppColors.primaryShadow,
              shadowHeight: 3,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      'Lihat Semua',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.badges.length,
            itemBuilder: (context, index) {
              final badge = controller.badges[index];
              return _buildBadgeItem(badge);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(badge) {
    return GestureDetector(
      onTap: () => BadgeDetailDialog.show(badge),
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            // Badge Circle dengan 3D effect
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: badge.isUnlocked
                    ? badge.color.withValues(alpha: 0.15)
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
                border: Border.all(
                  color: badge.isUnlocked ? badge.color : Colors.grey.shade400,
                  width: 3,
                ),
                boxShadow: badge.isUnlocked
                    ? [
                        BoxShadow(
                          color: badge.color.withValues(alpha: 0.4),
                          offset: const Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          offset: const Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
              ),
              child: Center(
                child: badge.isUnlocked
                    ? Text(
                        badge.iconEmoji,
                        style: const TextStyle(fontSize: 32),
                      )
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
            const SizedBox(height: 6),
            // Badge Name
            SizedBox(
              width: 70,
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
          ],
        ),
      ),
    );
  }
}
