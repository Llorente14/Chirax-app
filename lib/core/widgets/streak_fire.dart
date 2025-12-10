import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Streak Fire Widget dengan Lottie Animations
class StreakFire extends StatelessWidget {
  final bool isActive;
  final double width;
  final double height;

  const StreakFire({
    super.key,
    required this.isActive,
    this.width = 100,
    this.height = 100,
  });

  String get _assetPath {
    return isActive
        ? 'assets/lottie/fire_active.json'
        : 'assets/lottie/fire_inactive.png';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        key: ValueKey(isActive),
        width: width,
        height: height,
        child: Lottie.asset(
          _assetPath,
          repeat: true,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to emoji if Lottie file not found
            return _buildFallbackEmoji();
          },
        ),
      ),
    );
  }

  Widget _buildFallbackEmoji() {
    return Center(
      child: Text(
        isActive ? '🔥' : '❄️',
        style: TextStyle(fontSize: width * 0.6),
      ),
    );
  }
}
