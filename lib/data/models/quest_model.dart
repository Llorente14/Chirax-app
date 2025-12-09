/// Model untuk Quest/Misi Harian
class QuestModel {
  final String id;
  final String title;
  final String description;
  int currentProgress;
  final int targetProgress;
  final int rewardXP;
  final String rewardIcon;
  bool isClaimed;
  final String type; // 'savings', 'journey', 'interaction'

  QuestModel({
    required this.id,
    required this.title,
    required this.description,
    this.currentProgress = 0,
    required this.targetProgress,
    required this.rewardXP,
    required this.rewardIcon,
    this.isClaimed = false,
    required this.type,
  });

  /// Check if quest is completed
  bool get isCompleted => currentProgress >= targetProgress;

  /// Get progress percentage (0.0 - 1.0)
  double get progressPercentage =>
      (currentProgress / targetProgress).clamp(0.0, 1.0);

  /// Get progress text
  String get progressText => '$currentProgress/$targetProgress';

  /// copyWith for immutability
  QuestModel copyWith({
    String? id,
    String? title,
    String? description,
    int? currentProgress,
    int? targetProgress,
    int? rewardXP,
    String? rewardIcon,
    bool? isClaimed,
    String? type,
  }) {
    return QuestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress ?? this.targetProgress,
      rewardXP: rewardXP ?? this.rewardXP,
      rewardIcon: rewardIcon ?? this.rewardIcon,
      isClaimed: isClaimed ?? this.isClaimed,
      type: type ?? this.type,
    );
  }
}
