import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/sound_helper.dart';

/// Dialog perayaan All Clear - muncul saat semua misi harian selesai
class AllClearDialog extends StatefulWidget {
  const AllClearDialog({super.key});

  @override
  State<AllClearDialog> createState() => _AllClearDialogState();
}

class _AllClearDialogState extends State<AllClearDialog> {
  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    SoundHelper.playTada();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main Card
          Container(
            margin: const EdgeInsets.only(top: 60),
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.grey.shade300, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  offset: const Offset(0, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ALL CLEAR! Text
                Text(
                  'ALL CLEAR!',
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.success,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Semua misi harian selesai! 🎉',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 20),

                // Bonus XP Badge - 3D style
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary, width: 2.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Text(
                        'BONUS +50 XP',
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Claim Button - 3D Juicy Style
                GestureDetector(
                  onTapDown: (_) => setState(() => _isButtonPressed = true),
                  onTapUp: (_) {
                    setState(() => _isButtonPressed = false);
                    HapticFeedback.mediumImpact();
                    Get.back();
                  },
                  onTapCancel: () => setState(() => _isButtonPressed = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    transform: Matrix4.translationValues(
                      0,
                      _isButtonPressed ? 4 : 0,
                      0,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.successShadow,
                            offset: Offset(0, _isButtonPressed ? 2 : 5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'LANJUTKAN',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lottie Star Animation - Floating on top
          SizedBox(
            width: 120,
            height: 120,
            child: Lottie.asset(
              'assets/lottie/reward_star.json',
              repeat: true,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to emoji if Lottie not found
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE066), Color(0xFFFFD700)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE6B800),
                      width: 4,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFCC9900),
                        offset: Offset(0, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🏆', style: TextStyle(fontSize: 48)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
