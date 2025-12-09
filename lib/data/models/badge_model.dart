import 'package:flutter/material.dart';

class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String iconEmoji;
  final bool isUnlocked;
  final int currentProgress;
  final int targetProgress;
  final Color color;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    this.isUnlocked = false,
    this.currentProgress = 0,
    this.targetProgress = 1,
    this.color = Colors.grey,
  });

  /// Progress percentage (0.0 - 1.0)
  double get progressPercentage {
    if (targetProgress <= 0) return 0;
    return (currentProgress / targetProgress).clamp(0.0, 1.0);
  }

  /// Progress percent sebagai int (0 - 100)
  int get progressPercent => (progressPercentage * 100).round();

  /// Format progress text
  String get progressText => '$currentProgress / $targetProgress';

  /// Copy with method
  BadgeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconEmoji,
    bool? isUnlocked,
    int? currentProgress,
    int? targetProgress,
    Color? color,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress ?? this.targetProgress,
      color: color ?? this.color,
    );
  }
}
