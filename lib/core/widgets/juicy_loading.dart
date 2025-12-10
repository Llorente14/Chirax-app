import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// JuicyLoading - Widget loading pengganti CircularProgressIndicator
class JuicyLoading extends StatelessWidget {
  final double size;

  const JuicyLoading({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/lottie/loading_heart.json',
        repeat: true,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to regular loading indicator
          return Center(
            child: SizedBox(
              width: size * 0.5,
              height: size * 0.5,
              child: const CircularProgressIndicator(strokeWidth: 3),
            ),
          );
        },
      ),
    );
  }
}
