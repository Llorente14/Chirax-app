/// Model untuk Daily Task dari Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyTaskModel {
  final String id;
  final String title;
  final String description;
  final int targetProgress;
  final int rewardXP;
  final String rewardIcon;
  final String type; // 'savings', 'journey', 'interaction', 'memory', 'other'
  final bool isActive;
  final int order;
  final DateTime? createdAt;

  DailyTaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.targetProgress,
    required this.rewardXP,
    required this.rewardIcon,
    required this.type,
    this.isActive = false,
    this.order = 0,
    this.createdAt,
  });

  /// Create from Firestore document
  factory DailyTaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyTaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      targetProgress: data['targetProgress'] ?? 1,
      rewardXP: data['rewardXP'] ?? 10,
      rewardIcon: data['rewardIcon'] ?? '🎯',
      type: data['type'] ?? 'other',
      isActive: data['isActive'] ?? false,
      order: data['order'] ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'targetProgress': targetProgress,
      'rewardXP': rewardXP,
      'rewardIcon': rewardIcon,
      'type': type,
      'isActive': isActive,
      'order': order,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  /// Create copy with different values
  DailyTaskModel copyWith({
    String? id,
    String? title,
    String? description,
    int? targetProgress,
    int? rewardXP,
    String? rewardIcon,
    String? type,
    bool? isActive,
    int? order,
    DateTime? createdAt,
  }) {
    return DailyTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetProgress: targetProgress ?? this.targetProgress,
      rewardXP: rewardXP ?? this.rewardXP,
      rewardIcon: rewardIcon ?? this.rewardIcon,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
