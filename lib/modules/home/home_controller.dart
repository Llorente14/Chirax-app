import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../core/utils/sound_helper.dart';
import '../../core/widgets/all_clear_dialog.dart';
import '../../core/widgets/pet_avatar.dart';
import '../../data/models/couple_model.dart';
import '../../data/models/quest_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/database_service.dart';
import '../profile/profile_controller.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final DatabaseService _dbService = Get.find<DatabaseService>();

  // === REACTIVE DATA FROM FIRESTORE ===
  final Rx<CoupleModel?> coupleData = Rx<CoupleModel?>(null);
  final Rx<UserModel?> partnerData = Rx<UserModel?>(null);

  // === LOCAL STATE ===
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // === DAILY QUESTS (Now synced with Firestore) ===
  final dailyQuests = <QuestModel>[].obs;

  // === NEW: Interaction Cooldown (FIX XP FARMING) ===
  final Rx<DateTime?> lastInteractionTime = Rx<DateTime?>(null);
  static const interactionCooldownSeconds = 30;

  // === NEW: Weekly Challenge ===
  final Rx<Map<String, dynamic>?> weeklyChallenge = Rx<Map<String, dynamic>?>(
    null,
  );

  // Stream subscription
  StreamSubscription? _coupleSubscription;
  StreamSubscription? _partnerSubscription;

  // === COMPUTED GETTERS ===

  /// Get current user name
  String get userName => _authService.userModel.value?.name ?? 'User';

  /// Get partner name
  String get partnerName => partnerData.value?.name ?? 'Partner';

  /// Get partner avatar (placeholder for now)
  String get partnerAvatar => 'assets/images/avatar_me.png';

  /// Get couple ID
  String? get coupleId => _authService.userModel.value?.coupleId;

  /// Get partner ID
  String? get partnerId => _authService.userModel.value?.partnerId;

  /// Get days together (returns -1 if date not properly set)
  int get daysTogether => coupleData.value?.daysTogether ?? 0;

  /// Check if anniversary date is properly set (not today/default)
  bool get hasAnniversaryDateSet {
    final startDate = coupleData.value?.startDate;
    if (startDate == null) return false;
    final now = DateTime.now();
    // If startDate is same as today (within tolerance), consider it as "not set"
    final diff = now.difference(startDate).inDays.abs();
    // If startDate is in the future or very recent (same day), might be unset
    return diff > 0 ||
        startDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  /// Get formatted anniversary date
  DateTime? get anniversaryDate => coupleData.value?.startDate;

  /// Update anniversary date
  Future<bool> updateAnniversaryDate(DateTime newDate) async {
    if (coupleId == null) return false;

    final success = await _dbService.updateAnniversaryDate(coupleId!, newDate);
    if (success) {
      Get.snackbar(
        '💕 Berhasil!',
        'Tanggal jadian berhasil diubah',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
    return success;
  }

  /// Get streak count
  int get streakCount => coupleData.value?.streak ?? 0;

  /// Get streak message
  String get streakMessage =>
      coupleData.value?.streakMessage ?? 'Start your streak!';

  /// NEW: Get streak protects available
  int get streakProtects => coupleData.value?.streakProtects ?? 0;

  /// Get pet mood as PetMood enum
  PetMood get petMood {
    final moodString = coupleData.value?.petMood ?? 'idle';
    switch (moodString) {
      case 'sad':
        return PetMood.sad;
      case 'eating':
        return PetMood.eating;
      default:
        return PetMood.idle;
    }
  }

  /// Get pet name
  String get petName => coupleData.value?.petName ?? 'Mochi';

  /// Get total XP
  int get totalXP => coupleData.value?.totalXP ?? 0;

  /// Check if already checked in today
  bool get hasCheckedInToday => coupleData.value?.hasCheckedInToday ?? false;

  /// NEW: Check if can interact (cooldown check)
  bool get canInteract {
    final lastTime = lastInteractionTime.value;
    if (lastTime == null) return true;
    return DateTime.now().difference(lastTime).inSeconds >=
        interactionCooldownSeconds;
  }

  /// NEW: Remaining cooldown seconds
  int get interactionCooldownRemaining {
    final lastTime = lastInteractionTime.value;
    if (lastTime == null) return 0;
    final elapsed = DateTime.now().difference(lastTime).inSeconds;
    return (interactionCooldownSeconds - elapsed).clamp(
      0,
      interactionCooldownSeconds,
    );
  }

  /// Greeting based on time
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  @override
  void onClose() {
    _coupleSubscription?.cancel();
    _partnerSubscription?.cancel();
    super.onClose();
  }

  /// Initialize real-time data streams
  Future<void> _initializeData() async {
    try {
      isLoading.value = true;

      // Load user model first
      await _authService.loadUserModel();

      final userModel = _authService.userModel.value;
      if (userModel == null) {
        errorMessage.value = 'User tidak ditemukan';
        return;
      }

      // Stream couple data
      if (userModel.coupleId != null) {
        // Check and reset quests if new day
        await _checkAndResetQuestsIfNeeded(userModel.coupleId!);

        // Check and auto-protect streak
        await _dbService.checkAndAutoProtectStreak(userModel.coupleId!);

        // Reset monthly protects if needed
        await _dbService.resetMonthlyProtects(userModel.coupleId!);

        // Initialize weekly challenge
        weeklyChallenge.value = await _dbService.initWeeklyChallenge(
          userModel.coupleId!,
        );

        // Reset daily badge counters (profileViewsToday, appOpensThisHour)
        await _dbService.resetDailyBadgeProgress(userModel.coupleId!);

        // Track app open for "Bucin" badge
        await _dbService.incrementAppOpens(userModel.coupleId!);

        // Increment days without withdrawal (if no withdrawal was made)
        // This gets reset in FinanceController when withdrawal happens
        await _dbService.incrementDaysWithoutWithdrawal(userModel.coupleId!);

        _coupleSubscription = _dbService
            .streamCoupleData(userModel.coupleId!)
            .listen((couple) {
              coupleData.value = couple;

              // Sync quest progress from Firestore
              if (couple != null) {
                _syncQuestsFromFirestore(couple);

                // Update weekly challenge
                weeklyChallenge.value = couple.weeklyChallenge;
              }

              // Check pet mood - if not checked in today, pet is sad
              if (couple != null && !couple.hasCheckedInToday) {
                if (couple.petMood == 'idle') {
                  // Don't update if eating
                  _dbService.updatePetMood(userModel.coupleId!, 'sad');
                }
              }
            });
      }

      // Stream partner data
      if (userModel.partnerId != null) {
        _partnerSubscription = _dbService
            .streamUser(userModel.partnerId!)
            .listen((partner) {
              partnerData.value = partner;
            });
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// NEW: Check and reset quests if new day
  Future<void> _checkAndResetQuestsIfNeeded(String coupleId) async {
    final couple = await _dbService.getCoupleData(coupleId);
    if (couple != null) {
      final wasReset = await _dbService.checkAndResetQuestsIfNewDay(
        coupleId,
        couple.lastQuestResetDate,
      );
      if (wasReset) {
        // Quests were reset, initialize fresh
        _initDailyQuests();
      } else {
        // Load progress from Firestore
        _syncQuestsFromFirestore(couple);
      }
    } else {
      _initDailyQuests();
    }
  }

  /// NEW: Sync quests from Firestore
  void _syncQuestsFromFirestore(CoupleModel couple) {
    final progress = couple.dailyQuestProgress;

    // Initialize quests first if empty
    if (dailyQuests.isEmpty) {
      _initDailyQuests();
    }

    // Update progress from Firestore
    for (var quest in dailyQuests) {
      final firestoreProgress = progress[quest.type] ?? 0;
      quest.currentProgress = firestoreProgress;
    }
    dailyQuests.refresh();
  }

  /// Initialize daily quests
  void _initDailyQuests() {
    dailyQuests.value = [
      QuestModel(
        id: 'quest_savings',
        title: 'Investasi Cinta',
        description: 'Nabung 1x hari ini',
        currentProgress: 0,
        targetProgress: 1,
        rewardXP: 20,
        rewardIcon: '🥉',
        type: 'savings',
      ),
      QuestModel(
        id: 'quest_journey',
        title: 'Planner Sejati',
        description: 'Buat 1 event baru',
        currentProgress: 0,
        targetProgress: 1,
        rewardXP: 30,
        rewardIcon: '🥈',
        type: 'journey',
      ),
      QuestModel(
        id: 'quest_interaction',
        title: 'Kangen Berat',
        description: 'Interaksi 3x',
        currentProgress: 0,
        targetProgress: 3,
        rewardXP: 50,
        rewardIcon: '🥇',
        type: 'interaction',
      ),
    ];
  }

  // === ACTIONS ===

  // === PET INTERACTION STATE ===
  final RxBool isInteracting = false.obs;
  int _feedCount = 0;
  bool _isFeedCoolingDown = false;
  Timer? _feedResetTimer;

  /// Perform daily check-in
  Future<void> checkIn() async {
    if (coupleId == null) return;
    await _dbService.performCheckIn(coupleId!);
    SoundHelper.playIgnite();
  }

  /// Feed the pet (enhanced with cooldown)
  Future<void> feedPet() async {
    if (coupleId == null) return;

    // Check if already interacting
    if (isInteracting.value) return;

    // Check cooldown
    if (_isFeedCoolingDown) {
      Get.snackbar(
        '⏰ Sabar ya...',
        '$petName masih kunyah-kunyah',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Check feed count (max 2 per minute)
    if (_feedCount >= 2) {
      Get.snackbar(
        '🤭 Kenyang!',
        '$petName sudah kenyang! Tunggu sebentar ya.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Start interaction
    isInteracting.value = true;
    _isFeedCoolingDown = true;
    _feedCount++;

    // Play sound and update mood
    SoundHelper.playCoins();
    await _dbService.updatePetMood(coupleId!, 'eating');

    Get.snackbar(
      '🍔 Nyam nyam!',
      '$petName sedang makan...',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );

    // Start reset timer if first feed
    if (_feedCount == 1) {
      _feedResetTimer?.cancel();
      _feedResetTimer = Timer(const Duration(minutes: 1), () {
        _feedCount = 0;
      });
    }

    // Revert mood after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (coupleId != null) {
        _dbService.updatePetMood(coupleId!, 'idle');
      }
      isInteracting.value = false;
    });

    // Cooldown for 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      _isFeedCoolingDown = false;
    });
  }

  /// Pat-pat the pet (elus)
  Future<void> patPet() async {
    if (coupleId == null) return;

    // Check if already interacting
    if (isInteracting.value) return;

    isInteracting.value = true;

    // Play magic sound
    SoundHelper.playMagic();

    // Update mood to happy
    await _dbService.updatePetMood(coupleId!, 'happy');

    // Show heart effect dialog
    _showHeartEffect();

    Get.snackbar(
      '💕 Aaww!',
      '$petName suka dielus!',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );

    // Revert mood after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (coupleId != null) {
        _dbService.updatePetMood(coupleId!, 'idle');
      }
      isInteracting.value = false;
    });
  }

  /// Show floating hearts effect
  void _showHeartEffect() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Lottie.asset(
            'assets/lottie/love_hearts.json',
            width: 200,
            height: 200,
            repeat: false,
            onLoaded: (composition) {
              Future.delayed(composition.duration, () {
                if (Get.isDialogOpen ?? false) Get.back();
              });
            },
          ),
        ),
      ),
      barrierColor: Colors.transparent,
      barrierDismissible: false,
    );
  }

  /// Show interaction dialog with Lottie
  void _showInteractionDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Lottie.asset(
            'assets/lottie/interaction_kiss.json',
            width: 200,
            height: 200,
            repeat: false,
            errorBuilder: (context, error, stackTrace) {
              return const Text('💋', style: TextStyle(fontSize: 100));
            },
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.3),
    );

    // Auto close after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });
  }

  /// NEW: Check cooldown before interaction
  bool _checkInteractionCooldown() {
    if (!canInteract) {
      Get.snackbar(
        '⏳ Tunggu Sebentar',
        'Bisa interaksi lagi dalam $interactionCooldownRemaining detik',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return false;
    }
    lastInteractionTime.value = DateTime.now();
    return true;
  }

  /// Poke partner (with cooldown)
  void pokePartner() {
    if (!_checkInteractionCooldown()) return;

    SoundHelper.playMagic();
    updateQuestProgress('interaction');
    _showInteractionDialog();

    if (partnerId != null) {
      _dbService.pokePartner(partnerId!);
    }

    Future.delayed(const Duration(seconds: 2), () {
      Get.snackbar(
        '👋 Colek!',
        'Kamu mencolek $partnerName!',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    });
  }

  /// Send love (with cooldown)
  void sendLove() {
    if (!_checkInteractionCooldown()) return;

    SoundHelper.playMagic();
    updateQuestProgress('interaction');
    _showInteractionDialog();

    Future.delayed(const Duration(seconds: 2), () {
      Get.snackbar(
        '❤️ Rindu Terkirim!',
        '$partnerName menerima cintamu 💕',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    });
  }

  /// Notify partner (with cooldown)
  void notifyPartner() {
    if (!_checkInteractionCooldown()) return;

    SoundHelper.playMagic();
    updateQuestProgress('interaction');
    Get.snackbar(
      '📢 Notif Terkirim!',
      '$partnerName akan segera buka app!',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  // === QUEST METHODS ===

  /// Update quest progress by type (now persisted to Firestore)
  void updateQuestProgress(String type) {
    final index = dailyQuests.indexWhere((q) => q.type == type);
    if (index != -1) {
      final quest = dailyQuests[index];
      if (!quest.isCompleted && !quest.isClaimed) {
        quest.currentProgress++;
        dailyQuests.refresh();

        // NEW: Persist to Firestore
        if (coupleId != null) {
          _dbService.updateQuestProgress(
            coupleId!,
            type,
            quest.currentProgress,
          );
        }

        // NEW: Update weekly challenge if applicable
        _updateWeeklyChallengeProgress(type);

        // Show notification if completed
        if (quest.isCompleted) {
          Get.snackbar(
            '🎉 Misi Selesai!',
            '${quest.title} - Tap untuk klaim ${quest.rewardXP} XP!',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );
        }
      }
    }
  }

  /// NEW: Update weekly challenge progress based on action type
  void _updateWeeklyChallengeProgress(String actionType) {
    final challenge = weeklyChallenge.value;
    if (challenge == null || coupleId == null) return;

    final challengeId = challenge['id'] as String?;
    final currentProgress = challenge['currentProgress'] as int? ?? 0;
    final targetProgress = challenge['targetProgress'] as int? ?? 1;
    final isClaimed = challenge['isClaimed'] as bool? ?? false;

    if (isClaimed || currentProgress >= targetProgress) return;

    bool shouldIncrement = false;

    // Check if this action type matches the challenge
    if (challengeId == 'savings_streak' && actionType == 'savings') {
      shouldIncrement = true;
    } else if (challengeId == 'interaction_pro' &&
        actionType == 'interaction') {
      shouldIncrement = true;
    }
    // check_in_master is handled in checkIn method

    if (shouldIncrement) {
      _dbService.updateWeeklyChallengeProgress(coupleId!, currentProgress + 1);
    }
  }

  /// NEW: Claim weekly challenge reward
  Future<void> claimWeeklyChallenge() async {
    if (coupleId == null) return;
    await _dbService.claimWeeklyChallengeReward(coupleId!);
  }

  /// Claim completed quest
  void claimQuest(QuestModel quest) {
    if (quest.isCompleted && !quest.isClaimed) {
      final index = dailyQuests.indexWhere((q) => q.id == quest.id);
      if (index != -1) {
        SoundHelper.playCoins();
        dailyQuests[index].isClaimed = true;
        dailyQuests.refresh();

        // Add XP to couple
        if (coupleId != null) {
          _dbService.addXP(coupleId!, quest.rewardXP);
        }

        // Also add to profile
        try {
          final profileController = Get.find<ProfileController>();
          profileController.addXP(quest.rewardXP);
        } catch (e) {
          // ProfileController not found
        }

        Get.snackbar(
          '✨ Quest Claimed!',
          '+${quest.rewardXP} XP didapatkan!',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        // Check if all quests are claimed
        _checkAllClearCombo();
      }
    }
  }

  /// Check if all daily quests are claimed
  void _checkAllClearCombo() {
    if (dailyQuests.isEmpty) return;

    final allClaimed = dailyQuests.every((q) => q.isClaimed);

    if (allClaimed) {
      // Add bonus 50 XP
      if (coupleId != null) {
        _dbService.addXP(coupleId!, 50);
      }

      try {
        final profileController = Get.find<ProfileController>();
        profileController.addXP(50);
      } catch (e) {
        // ProfileController not found
      }

      // Show All Clear Dialog
      Get.dialog(const AllClearDialog(), barrierDismissible: false);
    }
  }

  /// Reset daily quests (for testing)
  void resetDailyQuest() {
    for (var quest in dailyQuests) {
      quest.currentProgress = 0;
      quest.isClaimed = false;
    }
    dailyQuests.refresh();

    if (coupleId != null) {
      _dbService.resetDailyQuests(coupleId!);
      _dbService.updatePetMood(coupleId!, 'sad');
    }

    Get.snackbar(
      '🔄 Quest Reset',
      'Semua misi direset!',
      snackPosition: SnackPosition.TOP,
    );
  }
}
