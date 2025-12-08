import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/chunky_button.dart';
import '../../core/widgets/chunky_card.dart';
import 'finance_controller.dart';

class FinanceView extends GetView<FinanceController> {
  const FinanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // === HEADER + TABS ===
              _buildHeader(),

              const SizedBox(height: 24),

              // === CIRCULAR PROGRESS ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Obx(() => _buildCircularProgress()),
              ),

              const SizedBox(height: 32),

              // === INFO CARD ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Obx(() => _buildInfoCard()),
              ),

              const SizedBox(height: 24),

              // === ACTION BUTTON ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ChunkyButton(
                  text: 'TAMBAH TABUNGAN',
                  icon: Icons.add_rounded,
                  color: AppColors.primary,
                  onPressed: () => _showAddSavingsSheet(),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              const Text('💰', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Text('Tabungan Kita', style: AppTextStyles.headline),
            ],
          ),
          const SizedBox(height: 20),

          // Goal Tabs - wrap with Obx
          Obx(() => _buildGoalTabs()),
        ],
      ),
    );
  }

  /// Goal Tabs - using Row for proper reactivity
  Widget _buildGoalTabs() {
    // Access value directly to force observe
    final selectedIdx = controller.selectedIndex.value;

    return SizedBox(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(controller.goals.length, (index) {
            final goal = controller.goals[index];
            final isSelected = selectedIdx == index;

            return GestureDetector(
              onTap: () => controller.selectGoal(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? goal.color : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? goal.color : Colors.grey.shade300,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: goal.color.withValues(alpha: 0.4),
                            offset: const Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(goal.iconEmoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      goal.title,
                      style: AppTextStyles.body.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCircularProgress() {
    final goal = controller.currentGoal;
    final progress = controller.progressPercentage;

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(260, 260),
            painter: _CircularProgressPainter(
              progress: progress,
              progressColor: goal.color,
              backgroundColor: Colors.grey.shade200,
              strokeWidth: 18,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(goal.iconEmoji, style: const TextStyle(fontSize: 50)),
              const SizedBox(height: 8),
              Text(
                '${controller.progressPercent}%',
                style: AppTextStyles.headline.copyWith(
                  fontSize: 36,
                  color: goal.color,
                ),
              ),
              Text(
                goal.title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final goal = controller.currentGoal;

    return ChunkyCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Terkumpul
          _buildInfoRow(
            emoji: '💵',
            label: 'Terkumpul',
            value: controller.formatCurrency(goal.currentAmount),
            valueColor: AppColors.success,
            bgColor: AppColors.success,
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200, thickness: 2),
          const SizedBox(height: 12),

          // Target
          _buildInfoRow(
            emoji: '🎯',
            label: 'Target',
            value: controller.formatCurrency(goal.targetAmount),
            valueColor: AppColors.textPrimary,
            bgColor: goal.color,
          ),
          const SizedBox(height: 16),

          // Status
          if (!controller.isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: goal.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Kurang ${controller.formatCurrency(goal.remainingAmount)} lagi! 💪',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: goal.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (controller.isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    'Target Tercapai!',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String emoji,
    required String label,
    required String value,
    required Color valueColor,
    required Color bgColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTextStyles.subtitle.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  /// Bottom Sheet untuk tambah tabungan
  void _showAddSavingsSheet() {
    controller.amountController.clear();

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('💵 Tambah Tabungan', style: AppTextStyles.title),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Input Field
              TextField(
                controller: controller.amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTextStyles.headline.copyWith(fontSize: 32),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: AppTextStyles.headline.copyWith(
                    fontSize: 32,
                    color: Colors.grey.shade300,
                  ),
                  prefixText: 'Rp ',
                  prefixStyle: AppTextStyles.title.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.offWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
              const SizedBox(height: 24),

              // Preset Buttons Label
              Text('Pilih Nominal:', style: AppTextStyles.subtitle),
              const SizedBox(height: 12),

              // Preset Grid
              _buildPresetGrid(),

              const SizedBox(height: 24),

              // Submit Button dengan shadow hijau tua
              ChunkyButton(
                text: 'SIMPAN TABUNGAN',
                icon: Icons.savings_rounded,
                color: AppColors.success,
                shadowColor: AppColors.successShadow,
                onPressed: () => controller.addFromInput(),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildPresetGrid() {
    final presets = [
      {'amount': 5000, 'label': '5K', 'color': AppColors.moneyOrange},
      {'amount': 10000, 'label': '10K', 'color': AppColors.moneyPurple},
      {'amount': 20000, 'label': '20K', 'color': AppColors.moneyCyan},
      {'amount': 50000, 'label': '50K', 'color': AppColors.moneyBlue},
      {'amount': 100000, 'label': '100K', 'color': AppColors.moneyPink},
      {'amount': 500000, 'label': '500K', 'color': AppColors.success},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: presets.map((preset) {
        final color = preset['color'] as Color;
        return GestureDetector(
          onTap: () => controller.setPresetToInput(preset['amount'] as int),
          child: Container(
            width: 100,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _getDarkerColor(color),
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                preset['label'] as String,
                style: AppTextStyles.button.copyWith(
                  fontSize: 16,
                  color: color == AppColors.moneyCyan
                      ? AppColors.textPrimary
                      : Colors.white,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getDarkerColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
  }
}

/// Custom Painter untuk Circular Progress
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
