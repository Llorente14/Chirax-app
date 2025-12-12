import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'iconEmoji': iconEmoji,
      'color': color.value, // Store as int
      'isHighlighted': isHighlighted,
      'isCompleted': isCompleted,
      'completedDate': completedDate?.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
    };
  }

  /// Create from Firestore document
  factory SavingsGoal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SavingsGoal(
      id: doc.id,
      title: data['title'] ?? 'Untitled',
      targetAmount: (data['targetAmount'] ?? 0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0).toDouble(),
      iconEmoji: data['iconEmoji'] ?? '🎯',
      color: Color(data['color'] ?? 0xFF58CC02),
      isHighlighted: data['isHighlighted'] ?? false,
      isCompleted: data['isCompleted'] ?? false,
      completedDate: data['completedDate'] != null
          ? DateTime.tryParse(data['completedDate'])
          : null,
      createdDate: data['createdDate'] != null
          ? DateTime.tryParse(data['createdDate']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

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
