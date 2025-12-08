import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/chunky_button.dart';
import '../../core/widgets/chunky_card.dart';
import '../../data/models/journey_event.dart';
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

                  const SizedBox(height: 32),

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
              // Days Together Badge (Pill shape)
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryShadow,
                        offset: const Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${controller.daysTogether} Days',
                        style: AppTextStyles.button.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              // Partner Avatar (small circle)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
                child: Center(
                  child: Obx(
                    () => Text(
                      controller.partnerName.value.isNotEmpty
                          ? controller.partnerName.value[0].toUpperCase()
                          : '💕',
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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

  /// Countdown Widget untuk event besar berikutnya
  Widget _buildCountdownWidget() {
    return Obx(() {
      final nextEvent = journeyController.nextBigEvent;
      if (nextEvent == null) return const SizedBox.shrink();

      final daysUntil = journeyController.getDaysUntil(nextEvent);
      final isSurpriseForMe =
          nextEvent.isSurprise && nextEvent.createdBy != 'me';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSurpriseForMe
                ? [JourneyEvent.surpriseColor, const Color(0xFFB57EDC)]
                : [AppColors.secondary, const Color(0xFF14B8A6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  (isSurpriseForMe
                          ? JourneyEvent.surpriseColor
                          : AppColors.secondaryShadow)
                      .withValues(alpha: 0.5),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  isSurpriseForMe ? '🎁' : nextEvent.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Event name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isSurpriseForMe ? 'Surprise! 🎁' : nextEvent.title,
                    style: AppTextStyles.subtitle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Countdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'H-$daysUntil',
                style: AppTextStyles.title.copyWith(
                  color: isSurpriseForMe
                      ? JourneyEvent.surpriseColor
                      : AppColors.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Streak Counter - Hero Section dengan background berwarna
  Widget _buildStreakHero() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryShadow,
            offset: const Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Fire/Heart Icon
          const Text('🔥', style: TextStyle(fontSize: 56)),

          const SizedBox(height: 8),

          // Streak Number - VERY BIG
          Obx(
            () => Text(
              '${controller.streakCount.value}',
              style: AppTextStyles.streak.copyWith(
                color: Colors.white,
                fontSize: 72,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          // Streak Message
          Obx(
            () => Text(
              controller.streakMessage,
              style: AppTextStyles.subtitle.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pet Area - Pet visual dengan emoji besar
  Widget _buildPetArea() {
    return ChunkyCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Pet Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(
                () =>
                    Text(controller.petName.value, style: AppTextStyles.title),
              ),
              const SizedBox(width: 8),
              // Status Badge
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      controller.petStatus.value,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(controller.petStatus.value),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    controller.petStatus.value.label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _getStatusColor(controller.petStatus.value),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Pet Emoji - VERY BIG
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.lightPink.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 4,
              ),
            ),
            child: Center(
              child: Obx(
                () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    controller.petStatus.value.emoji,
                    key: ValueKey(controller.petStatus.value),
                    style: const TextStyle(fontSize: 100),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Pet Message
          Obx(
            () => Text(
              _getPetMessage(controller.petStatus.value),
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
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

        // Secondary Action: Feed Pet (only if hungry)
        Obx(() {
          if (controller.petStatus.value == PetStatus.hungry &&
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

  /// Helper: Get color based on pet status
  Color _getStatusColor(PetStatus status) {
    switch (status) {
      case PetStatus.happy:
        return AppColors.success;
      case PetStatus.sad:
        return AppColors.secondary;
      case PetStatus.sleeping:
        return AppColors.textSecondary;
      case PetStatus.hungry:
        return AppColors.dangerRed;
    }
  }

  /// Helper: Get message based on pet status
  String _getPetMessage(PetStatus status) {
    switch (status) {
      case PetStatus.happy:
        return 'Your pet is so happy! 🎉';
      case PetStatus.sad:
        return 'Your pet misses you... 💔';
      case PetStatus.sleeping:
        return 'Shhh... your pet is sleeping 😴';
      case PetStatus.hungry:
        return 'Your pet needs some love! 💕';
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
