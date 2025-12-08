import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/chunky_card.dart';

class FinanceView extends StatelessWidget {
  const FinanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon placeholder
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.secondary, width: 4),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.savings_rounded,
                      size: 60,
                      color: AppColors.secondary,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text('💰 Finance', style: AppTextStyles.headline),

                const SizedBox(height: 16),

                // Coming Soon Card
                ChunkyCardOutlined(
                  outlineColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  child: Text(
                    'Coming Soon!',
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Description
                Text(
                  'Track your savings together\nand reach your goals! 🎯',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
