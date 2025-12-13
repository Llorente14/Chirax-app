import 'package:flutter/material.dart';

/// Pet Mood Enum untuk visual state
enum PetMood { idle, sad, eating, happy }

/// Extension untuk mendapatkan label dan path berdasarkan mood
extension PetMoodExtension on PetMood {
  String get label {
    switch (this) {
      case PetMood.idle:
        return 'Santai';
      case PetMood.sad:
        return 'Needs Love';
      case PetMood.eating:
        return 'Makan';
      case PetMood.happy:
        return 'Senang';
    }
  }

  String get assetPath {
    switch (this) {
      case PetMood.idle:
        return 'assets/images/pet/pet_idle.png';
      case PetMood.sad:
        return 'assets/images/pet/pet_sad.png';
      case PetMood.eating:
        return 'assets/images/pet/pet_eating.png';
      case PetMood.happy:
        return 'assets/images/pet/pet_happy.png';
    }
  }

  /// Whether this mood should have breathing animation
  bool get shouldBreathe => this == PetMood.idle || this == PetMood.happy;
}

/// Pet Avatar Widget dengan PNG dan breathing animation
class PetAvatar extends StatefulWidget {
  final PetMood mood;
  final double size;

  const PetAvatar({super.key, required this.mood, this.size = 180});

  @override
  State<PetAvatar> createState() => _PetAvatarState();
}

class _PetAvatarState extends State<PetAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();

    // Breathing animation controller - loops forever
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Scale from 0.95 to 1.05
    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Start breathing if idle
    if (widget.mood.shouldBreathe) {
      _breathingController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PetAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation based on mood change
    if (widget.mood.shouldBreathe && !_breathingController.isAnimating) {
      _breathingController.repeat(reverse: true);
    } else if (!widget.mood.shouldBreathe && _breathingController.isAnimating) {
      _breathingController.stop();
      _breathingController.value = 0.5; // Reset to middle (scale 1.0)
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        key: ValueKey(widget.mood),
        width: widget.size,
        height: widget.size,
        child: widget.mood.shouldBreathe
            ? ScaleTransition(scale: _breathingAnimation, child: _buildImage())
            : _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    return Image.asset(
      widget.mood.assetPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to emoji if PNG not found
        return _buildFallbackEmoji();
      },
    );
  }

  Widget _buildFallbackEmoji() {
    String emoji;
    switch (widget.mood) {
      case PetMood.idle:
        emoji = '😺';
        break;
      case PetMood.sad:
        emoji = '😿';
        break;
      case PetMood.eating:
        emoji = '😻';
        break;
      case PetMood.happy:
        emoji = '😸';
        break;
    }
    return Center(
      child: Text(emoji, style: TextStyle(fontSize: widget.size * 0.6)),
    );
  }
}
