import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../dashboard/dashboard_view.dart';

/// SplashView - Intro screen dengan Lottie animation
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation for "Love is Blind"
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Pulse animation for "Love is Blind"
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 500), () {
      _fadeController.forward();
      _pulseController.repeat(reverse: true);
    });

    // Navigate to Dashboard after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAll(() => const DashboardView());
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Lottie Animation
              Lottie.asset(
                'assets/lottie/splash_walk.json',
                width: 280,
                repeat: true,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to emoji if Lottie not found
                  return const Text('💑', style: TextStyle(fontSize: 120));
                },
              ),

              const SizedBox(height: 40),

              // App Title: Axel ❤️ Gea
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                  children: const [
                    TextSpan(text: 'Axel '),
                    TextSpan(text: '❤️', style: TextStyle(fontSize: 28)),
                    TextSpan(text: ' Gea'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle with fade + pulse animation: Love is Blind
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Text(
                    'Love is Blind',
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepNavy,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'Made with ❤️',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
