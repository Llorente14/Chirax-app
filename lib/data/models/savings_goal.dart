import 'package:flutter/material.dart';

class SavingsGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String iconEmoji;
  final Color color;
  final bool isHighlighted;
  final bool isCompleted;
  final DateTime? completedDate;
  final DateTime createdDate;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.iconEmoji,
    required this.color,
    this.isHighlighted = false,
    this.isCompleted = false,
    this.completedDate,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  /// Progress percentage (0.0 - 1.0)
  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    final progress = currentAmount / targetAmount;
    return progress.clamp(0.0, 1.0);
  }

  /// Progress percentage as integer (0 - 100)
  int get progressPercent => (progressPercentage * 100).round();

  /// Is goal target reached?
  bool get isTargetReached => currentAmount >= targetAmount;

  /// Remaining amount
  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0, targetAmount);

  /// Copy with updated values
  SavingsGoal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    String? iconEmoji,
    Color? color,
    bool? isHighlighted,
    bool? isCompleted,
    DateTime? completedDate,
    DateTime? createdDate,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      color: color ?? this.color,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}
