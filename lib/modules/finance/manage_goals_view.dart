import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/sound_helper.dart';
import '../../core/widgets/chunky_card.dart';
import '../../data/models/savings_goal.dart';
import 'create_goal_view.dart';
import 'finance_controller.dart';

class ManageGoalsView extends GetView<FinanceController> {
  const ManageGoalsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              SoundHelper.playPop();
              Get.back();
            },
          ),
          title: Text('Kelola Target', style: AppTextStyles.title),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: AppTextStyles.subtitle,
            onTap: (_) => SoundHelper.playSwipe(),
            tabs: const [
              Tab(text: 'Aktif'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab Aktif
            Obx(() => _buildActiveTab()),
            // Tab Riwayat
            Obx(() => _buildHistoryTab()),
          ],
        ),
        floatingActionButton: _buildChunkyFAB(),
      ),
    );
  }

  /// Chunky FAB - Rounded 3D Pink style like calendar
  Widget _buildChunkyFAB() {
    return GestureDetector(
      onTap: () {
        SoundHelper.playClick();
        Get.to(() => const CreateGoalView());
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryShadow,
              offset: const Offset(0, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildActiveTab() {
    final activeGoals = controller.activeGoals;

    if (activeGoals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Belum ada target aktif',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + untuk membuat target baru',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeGoals.length,
      itemBuilder: (context, index) {
        final goal = activeGoals[index];
        return _buildActiveGoalCard(goal);
      },
    );
  }

  Widget _buildActiveGoalCard(SavingsGoal goal) {
    return ChunkyCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: goal.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    goal.iconEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title, style: AppTextStyles.subtitle),
                    const SizedBox(height: 4),
                    Text(
                      '${controller.formatCurrency(goal.currentAmount)} / ${controller.formatCurrency(goal.targetAmount)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Highlight Toggle
              Obx(() {
                final isHighlighted = controller.goals
                    .firstWhere((g) => g.id == goal.id)
                    .isHighlighted;
                return Switch(
                  value: isHighlighted,
                  activeColor: AppColors.primary,
                  onChanged: (_) => controller.toggleHighlight(goal.id),
                );
              }),

              // Menu Button dengan 3D style
              _buildMenuButton(goal),
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: goal.progressPercentage,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(goal.color),
            ),
          ),
          const SizedBox(height: 8),

          // Progress Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${goal.progressPercent}% tercapai',
                style: AppTextStyles.bodySmall.copyWith(color: goal.color),
              ),
              if (goal.isHighlighted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '⭐ Highlighted',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Custom 3D Menu Button
  Widget _buildMenuButton(SavingsGoal goal) {
    return PopupMenuButton<String>(
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: const Icon(
          Icons.more_horiz_rounded,
          color: AppColors.textSecondary,
          size: 20,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 8,
      offset: const Offset(0, 40),
      onSelected: (value) {
        if (value == 'complete') {
          _showCompleteDialog(goal);
        } else if (value == 'delete') {
          _showDeleteDialog(goal);
        }
      },
      itemBuilder: (context) => [
        // Show complete option only if 100%
        if (goal.isTargetReached)
          PopupMenuItem(
            value: 'complete',
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Tandai Selesai',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        PopupMenuItem(
          value: 'delete',
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: AppColors.dangerRed,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Hapus',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    final historyGoals = controller.historyGoals;

    if (historyGoals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Target yang diselesaikan akan muncul di sini',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historyGoals.length,
      itemBuilder: (context, index) {
        final goal = historyGoals[index];
        return _buildHistoryGoalCard(goal);
      },
    );
  }

  Widget _buildHistoryGoalCard(SavingsGoal goal) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id');
    final completedText = goal.completedDate != null
        ? 'Tercapai pada ${dateFormat.format(goal.completedDate!)}'
        : 'Tercapai';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(goal.iconEmoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.formatCurrency(goal.targetAmount),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      completedText,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete Button
          GestureDetector(
            onTap: () => _showDeleteDialog(goal),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.grey,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom 3D Dialog - Complete
  void _showCompleteDialog(SavingsGoal goal) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Selesaikan Target?',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Content
              Text(
                'Tandai "${goal.title}" sebagai selesai dan pindahkan ke riwayat?',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        SoundHelper.playPop();
                        Get.back();
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Batal',
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
                    child: GestureDetector(
                      onTap: () {
                        SoundHelper.playTada();
                        Get.back();
                        controller.markAsCompleted(goal.id);
                      },
                      child: Container(
                        height: 50,
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
                          child: Text('Selesai', style: AppTextStyles.button),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Custom 3D Dialog - Delete
  void _showDeleteDialog(SavingsGoal goal) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.dangerRed.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🗑️', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Hapus Target?',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Content
              Text(
                'Hapus "${goal.title}" secara permanen?\nAksi ini tidak dapat dibatalkan.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  // Cancel
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        SoundHelper.playPop();
                        Get.back();
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Batal',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Delete
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        controller.deleteGoal(goal.id);
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.dangerRed,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFB71C1C),
                              offset: Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text('Hapus', style: AppTextStyles.button),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
