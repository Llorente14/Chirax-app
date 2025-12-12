import 'package:cloud_firestore/cloud_firestore.dart';

/// CoupleModel - Data model for couple document in Firestore
class CoupleModel {
  final String id;
  final List<String> userIds;
  final int streak;
  final DateTime? lastCheckIn;
  final int totalXP;
  final String petMood; // 'idle', 'sad', 'eating'
  final double totalAssets;
  final DateTime startDate;
  final String? petName;

  // === NEW: Streak Protect ===
  final int streakProtects; // Default 2 per month
  final int lastProtectResetMonth; // Track which month was last reset

  // === NEW: Daily Quest Persistence ===
  final Map<String, int>
  dailyQuestProgress; // {savings: 0, journey: 0, interaction: 0}
  final DateTime? lastQuestResetDate;

  // === NEW: Weekly Challenge ===
  final Map<String, dynamic>? weeklyChallenge;

  // === NEW: Badge Progress (Dynamic tracking) ===
  final Map<String, int> badgeProgress;
  // Tracks: {
  //   'daysWithoutWithdrawal': 0,   // For "Hemat Kopi" badge
  //   'profileViewsToday': 0,       // For "Stalker" badge
  //   'goalsCompleted': 0,          // For "To The Moon" badge
  //   'memoriesSaved': 0,           // For "Memory Hoarder" badge
  //   'appOpensThisHour': 0,        // For "Bucin" badge
  //   'totalInteractions': 0,       // For interaction-based badges
  // }

  CoupleModel({
    required this.id,
    required this.userIds,
    this.streak = 0,
    this.lastCheckIn,
    this.totalXP = 0,
    this.petMood = 'idle',
    this.totalAssets = 0.0,
    required this.startDate,
    this.petName,
    this.streakProtects = 2,
    this.lastProtectResetMonth = 0,
    this.dailyQuestProgress = const {},
    this.lastQuestResetDate,
    this.weeklyChallenge,
    this.badgeProgress = const {},
  });

  /// Calculate days together
  int get daysTogether {
    return DateTime.now().difference(startDate).inDays;
  }

  /// Check if already checked in today
  bool get hasCheckedInToday {
    if (lastCheckIn == null) return false;
    final now = DateTime.now();
    return lastCheckIn!.year == now.year &&
        lastCheckIn!.month == now.month &&
        lastCheckIn!.day == now.day;
  }

  /// Get streak message based on streak count
  String get streakMessage {
    if (streak >= 30) {
      return 'Incredible! 🔥';
    } else if (streak >= 14) {
      return 'On Fire! 🔥';
    } else if (streak >= 7) {
      return 'Keep Going! 💪';
    } else if (streak > 0) {
      return 'Days Together 💕';
    } else {
      return 'Start your streak! 💫';
    }
  }

  /// Create from Firestore document
  factory CoupleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CoupleModel(
      id: doc.id,
      userIds: List<String>.from(
        data['userIds'] ?? [data['user1'], data['user2']],
      ),
      streak: data['streak'] ?? 0,
      lastCheckIn: data['lastCheckIn'] != null
          ? (data['lastCheckIn'] is Timestamp
                ? (data['lastCheckIn'] as Timestamp).toDate()
                : DateTime.tryParse(data['lastCheckIn']))
          : null,
      totalXP: data['totalXP'] ?? 0,
      petMood: data['petMood'] ?? 'idle',
      totalAssets: (data['totalAssets'] ?? 0.0).toDouble(),
      startDate: data['startDate'] != null
          ? (data['startDate'] is Timestamp
                ? (data['startDate'] as Timestamp).toDate()
                : DateTime.tryParse(data['startDate']) ?? DateTime.now())
          : (data['createdAt'] != null
                ? (data['createdAt'] is Timestamp
                      ? (data['createdAt'] as Timestamp).toDate()
                      : DateTime.tryParse(data['createdAt']) ?? DateTime.now())
                : DateTime.now()),
      petName: data['petName'] ?? 'Mochi',
      // NEW: Streak Protect
      streakProtects: data['streakProtects'] ?? 2,
      lastProtectResetMonth: data['lastProtectResetMonth'] ?? 0,
      // NEW: Daily Quest Persistence
      dailyQuestProgress: Map<String, int>.from(
        data['dailyQuestProgress'] ?? {},
      ),
      lastQuestResetDate: data['lastQuestResetDate'] != null
          ? (data['lastQuestResetDate'] is Timestamp
                ? (data['lastQuestResetDate'] as Timestamp).toDate()
                : DateTime.tryParse(data['lastQuestResetDate']))
          : null,
      // NEW: Weekly Challenge
      weeklyChallenge: data['weeklyChallenge'] as Map<String, dynamic>?,
      // NEW: Badge Progress
      badgeProgress: Map<String, int>.from(data['badgeProgress'] ?? {}),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userIds': userIds,
      'streak': streak,
      'lastCheckIn': lastCheckIn?.toIso8601String(),
      'totalXP': totalXP,
      'petMood': petMood,
      'totalAssets': totalAssets,
      'startDate': startDate.toIso8601String(),
      'petName': petName,
      // NEW: Streak Protect
      'streakProtects': streakProtects,
      'lastProtectResetMonth': lastProtectResetMonth,
      // NEW: Daily Quest Persistence
      'dailyQuestProgress': dailyQuestProgress,
      'lastQuestResetDate': lastQuestResetDate?.toIso8601String(),
      // NEW: Weekly Challenge
      'weeklyChallenge': weeklyChallenge,
      // NEW: Badge Progress
      'badgeProgress': badgeProgress,
    };
  }

  /// Create empty placeholder
  factory CoupleModel.empty() {
    return CoupleModel(id: '', userIds: [], startDate: DateTime.now());
  }

  /// Check if this is empty placeholder
  bool get isEmpty => id.isEmpty;
}
