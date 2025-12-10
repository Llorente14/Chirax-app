import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/chunky_button.dart';
import '../../core/widgets/chunky_card.dart';
import '../../core/widgets/pet_avatar.dart';
import '../../core/widgets/shimmer_badge.dart';
import '../../core/widgets/streak_fire.dart';
import '../../data/models/journey_event.dart';
import '../../data/models/quest_model.dart';
import '../journey/journey_controller.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // Get JourneyController for countdown
  JourneyController get journeyController => Get.find<JourneyController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // === STICKY HEADER ===
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(child: _buildHeader()),
            ),

            // === SCROLLABLE CONTENT ===
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // === GREETING ===
                  _buildGreeting(),

                  const SizedBox(height: 16),

                  // === COUNTDOWN WIDGET ===
                  _buildCountdownWidget(),

                  const SizedBox(height: 24),

                  // === STREAK HERO SECTION ===
                  _buildStreakHero(),

                  const SizedBox(height: 24),

                  // === PET AREA ===
                  _buildPetArea(),

                  const SizedBox(height: 24),

                  // === DAILY QUESTS ===
                  _buildDailyQuestsSection(),

                  const SizedBox(height: 24),

                  // === ACTION BUTTONS ===
                  _buildActionButtons(),

                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header dengan sapaan, Days Together badge, dan avatar pasangan
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.neutralShadow, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Days Together Badge + Partner Avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Days Together Badge with Shimmer Effect
              Obx(() => ShimmerBadge(days: controller.daysTogether)),

              // Partner Avatar (JuicyAvatar style - Squircle 3D)
              GestureDetector(
                onTap: () => _showPartnerSheet(),
                child: SizedBox(
                  width: 52,
                  height: 50, // Extra space for shadow + badge
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Shadow layer
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      // Avatar container
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.secondary,
                            width: 3,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Obx(
                            () => Image.asset(
                              controller.partnerAvatar.value,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.2,
                                  ),
                                  child: Center(
                                    child: Obx(
                                      () => Text(
                                        controller.partnerName.value.isNotEmpty
                                            ? controller.partnerName.value[0]
                                                  .toUpperCase()
                                            : '💕',
                                        style: AppTextStyles.title.copyWith(
                                          color: AppColors.secondary,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      // Status Emoji Badge
                      Positioned(
                        right: -4,
                        bottom: -2,
                        child: Obx(
                          () => Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.secondary,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                controller.partnerStatusEmoji.value,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Partner Bottom Sheet
  void _showPartnerSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Partner Avatar (Large)
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Shadow
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                // Avatar
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.secondary, width: 4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: Obx(
                      () => Image.asset(
                        controller.partnerAvatar.value,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.secondary.withValues(alpha: 0.2),
                            child: Center(
                              child: Text(
                                controller.partnerName.value[0].toUpperCase(),
                                style: AppTextStyles.headline.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Online indicator
                Positioned(
                  right: -4,
                  bottom: 0,
                  child: Obx(
                    () => Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: controller.isPartnerOnline.value
                            ? AppColors.success
                            : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          controller.partnerStatusEmoji.value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Partner Name
            Obx(
              () => Text(
                controller.partnerName.value,
                style: AppTextStyles.headline.copyWith(fontSize: 24),
              ),
            ),

            const SizedBox(height: 4),

            // Status Text
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.partnerStatusEmoji.value,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    controller.partnerStatusText.value,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stats Row
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Level
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.moneyOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          'Level ${controller.partnerLevel.value}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.moneyOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Streak
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          '${controller.partnerStreak.value} Streak',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // Colek Button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      controller.pokePartner();
                    },
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryShadow,
                            offset: const Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '👋 Colek',
                          style: AppTextStyles.button.copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Rindu Button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      controller.sendLove();
                    },
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.secondaryShadow,
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '❤️ Rindu',
                          style: AppTextStyles.button.copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Notif Button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      controller.notifyPartner();
                    },
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.successShadow,
                            offset: const Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '📢 Cek App',
                          style: AppTextStyles.button.copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Greeting widget (dalam scrollable content)
  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Text(
            '${controller.greeting}, ${controller.userName.value}! 👋',
            style: AppTextStyles.title,
          ),
        ),
        const SizedBox(height: 4),
        Obx(
          () => Text(
            'with ${controller.partnerName.value} 💕',
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    );
  }

  /// Daily Quests Section - Clean Light Style
  Widget _buildDailyQuestsSection() {
    return Obx(() {
      final quests = controller.dailyQuests;
      if (quests.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'MISI HARIAN',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${quests.where((q) => q.isCompleted).length}/${quests.length}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Quest List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quests.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final quest = quests[index];
              return _buildQuestItem(quest);
            },
          ),
        ],
      );
    });
  }

  /// Individual Quest Item - Light Card Style
  Widget _buildQuestItem(QuestModel quest) {
    final canClaim = quest.isCompleted && !quest.isClaimed;

    return GestureDetector(
      onTap: canClaim ? () => controller.claimQuest(quest) : null,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: canClaim ? AppColors.success : Colors.grey.shade200,
            width: canClaim ? 2.5 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: canClaim ? AppColors.successShadow : Colors.grey.shade200,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: Title & Description
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.title,
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quest.description,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Center: Progress Bar
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: quest.progressPercentage,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        quest.isCompleted
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                      minHeight: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    quest.progressText,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Right: Reward Icon
            _buildRewardIcon(quest),
          ],
        ),
      ),
    );
  }

  /// Reward Icon with state - XP Badge instead of chest
  Widget _buildRewardIcon(QuestModel quest) {
    if (quest.isClaimed) {
      // Claimed - Show checkmark
      return Container(
        width: 56,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('✅', style: TextStyle(fontSize: 20))),
      );
    } else if (quest.isCompleted) {
      // Completed but not claimed - Glowing XP badge
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.successShadow,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          '+${quest.rewardXP}',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      );
    } else {
      // Not completed - Faded XP badge
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '+${quest.rewardXP}',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      );
    }
  }

  /// Countdown Widget - Duolingo 3D Bouncy Style dengan Lottie
  Widget _buildCountdownWidget() {
    return Obx(() {
      final nextEvent = journeyController.nextBigEvent;
      if (nextEvent == null) return const SizedBox.shrink();

      final daysUntil = journeyController.getDaysUntil(nextEvent);
      final isSurpriseForMe =
          nextEvent.isSurprise && nextEvent.createdBy != 'me';

      final shadowColor = isSurpriseForMe
          ? const Color(0xFF8B5CF6)
          : AppColors.secondaryShadow;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSurpriseForMe
                ? [JourneyEvent.surpriseColor, const Color(0xFFB57EDC)]
                : [AppColors.secondary, const Color(0xFF14B8A6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: shadowColor.withValues(alpha: 0.3),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon - 3D Style
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withValues(alpha: 0.5),
                    offset: const Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  isSurpriseForMe ? '🎁' : nextEvent.icon,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Event info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Days countdown badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'H-$daysUntil hari lagi',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Event title
                  Text(
                    isSurpriseForMe ? 'Surprise! 🎁' : nextEvent.title,
                    style: AppTextStyles.title.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Lottie Animation (reward_star)
            SizedBox(
              width: 70,
              height: 70,
              child: Lottie.asset(
                'assets/lottie/reward_star.json',
                repeat: true,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('⭐', style: TextStyle(fontSize: 40));
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Streak Counter - Hero Section dengan background berwarna
  Widget _buildStreakHero() {
    return Obx(() {
      final isActive = controller.streakCount.value > 0;

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)]
                : [Colors.grey.shade300, Colors.grey.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isActive ? AppColors.primaryShadow : Colors.grey.shade500,
              offset: const Offset(0, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Fire Animation (Lottie) - EXTRA LARGE
            StreakFire(isActive: isActive, width: 200, height: 200),

            const SizedBox(height: 12),

            // Streak Number - VERY BIG
            Text(
              '${controller.streakCount.value}',
              style: AppTextStyles.streak.copyWith(
                color: Colors.white,
                fontSize: 90,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),

            const SizedBox(height: 8),

            // Streak Message
            Text(
              isActive ? controller.streakMessage : 'Mulai streak-mu! 💪',
              style: AppTextStyles.subtitle.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 18,
              ),
            ),

            // Start streak hint (only when inactive)
            if (!isActive)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Check in setiap hari untuk memulai!',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  /// Pet Area - Pet visual dengan PNG Animation
  Widget _buildPetArea() {
    return ChunkyCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Pet Title - LARGER
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(
                () => Text(
                  controller.petName.value,
                  style: AppTextStyles.title.copyWith(fontSize: 28),
                ),
              ),
              const SizedBox(width: 12),
              // Status Badge - LARGER
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getMoodColor(
                      controller.petMood.value,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _getMoodColor(controller.petMood.value),
                      width: 3,
                    ),
                  ),
                  child: Text(
                    controller.petMood.value.label,
                    style: AppTextStyles.body.copyWith(
                      color: _getMoodColor(controller.petMood.value),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Pet PNG - LARGER without bold circle
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              color: AppColors.lightPink.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Obx(
                () => PetAvatar(mood: controller.petMood.value, size: 250),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Pet Message - LARGER
          Obx(
            () => Text(
              _getPetMessage(controller.petMood.value),
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textSecondary,
                fontSize: 17,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Action Buttons
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary Action: Check In / Send Love
        Obx(
          () => ChunkyButton(
            text: controller.isDailyQuestCompleted.value
                ? '✓ Checked In Today!'
                : 'Send Love 💕',
            icon: controller.isDailyQuestCompleted.value
                ? Icons.check_circle_rounded
                : Icons.favorite_rounded,
            onPressed: controller.completeDailyQuest,
            color: controller.isDailyQuestCompleted.value
                ? AppColors.success
                : AppColors.primary,
            shadowColor: controller.isDailyQuestCompleted.value
                ? AppColors.successShadow
                : AppColors.primaryShadow,
          ),
        ),

        const SizedBox(height: 16),

        // Secondary Action: Feed Pet (only if sad)
        Obx(() {
          if (controller.petMood.value == PetMood.sad &&
              !controller.isDailyQuestCompleted.value) {
            return ChunkyButton(
              text: 'Feed ${controller.petName.value}',
              icon: Icons.restaurant_rounded,
              onPressed: controller.feedPet,
              color: AppColors.secondary,
              shadowColor: AppColors.secondaryShadow,
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  /// Helper: Get color based on pet mood
  Color _getMoodColor(PetMood mood) {
    switch (mood) {
      case PetMood.idle:
        return AppColors.success;
      case PetMood.sad:
        return AppColors.secondary;
      case PetMood.eating:
        return AppColors.moneyOrange;
    }
  }

  /// Helper: Get message based on pet mood
  String _getPetMessage(PetMood mood) {
    switch (mood) {
      case PetMood.idle:
        return 'Pet kamu lagi santai! 😊';
      case PetMood.sad:
        return 'Pet kamu butuh perhatian... 💔';
      case PetMood.eating:
        return 'Nyam nyam! Sedang makan... 🍖';
    }
  }
}

/// Delegate untuk SliverPersistentHeader - membuat header sticky
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.offWhite,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: child,
    );
  }

  @override
  double get maxExtent => 100;

  @override
  double get minExtent => 100;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
