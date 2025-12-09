import 'package:get/get.dart';
import '../../core/widgets/all_clear_dialog.dart';
import '../../data/models/quest_model.dart';
import '../profile/profile_controller.dart';

/// Pet Status Enum untuk visual state
enum PetStatus { happy, sad, sleeping, hungry }

/// Extension untuk mendapatkan emoji berdasarkan status
extension PetStatusExtension on PetStatus {
  String get emoji {
    switch (this) {
      case PetStatus.happy:
        return '😽';
      case PetStatus.sad:
        return '😿';
      case PetStatus.sleeping:
        return '😴';
      case PetStatus.hungry:
        return '🍖';
    }
  }

  String get label {
    switch (this) {
      case PetStatus.happy:
        return 'Happy';
      case PetStatus.sad:
        return 'Needs Love';
      case PetStatus.sleeping:
        return 'Sleeping';
      case PetStatus.hungry:
        return 'Hungry';
    }
  }
}

class HomeController extends GetxController {
  // === USER DATA ===
  final userName = 'Axel'.obs;
  final partnerName = 'Gea'.obs;

  // === PARTNER DATA ===
  final partnerAvatar = 'assets/images/avatar_partner.png'.obs;
  final partnerStatusEmoji = '💤'.obs;
  final partnerStatusText = 'Sedang Tidur'.obs;
  final isPartnerOnline = false.obs;
  final partnerLevel = 5.obs;
  final partnerStreak = 12.obs;

  // === RELATIONSHIP DATA ===
  final startDate = DateTime.now().subtract(const Duration(days: 365)).obs;

  int get daysTogether {
    final now = DateTime.now();
    return now.difference(startDate.value).inDays;
  }

  // === GAMIFICATION DATA ===
  final streakCount = 12.obs;
  final petStatus = PetStatus.hungry.obs;
  final isDailyQuestCompleted = false.obs;

  // === DAILY QUESTS ===
  final dailyQuests = <QuestModel>[].obs;

  // === PET DATA ===
  final petName = 'Mochi'.obs;

  // === COMPUTED: Greeting berdasarkan waktu ===
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

  // === COMPUTED: Streak Message ===
  String get streakMessage {
    if (streakCount.value >= 30) {
      return 'Incredible! 🔥';
    } else if (streakCount.value >= 14) {
      return 'On Fire! 🔥';
    } else if (streakCount.value >= 7) {
      return 'Keep Going! 💪';
    } else {
      return 'Days Together 💕';
    }
  }

  // === QUEST METHODS ===

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

  /// Update quest progress by type
  void updateQuestProgress(String type) {
    final index = dailyQuests.indexWhere((q) => q.type == type);
    if (index != -1) {
      final quest = dailyQuests[index];
      if (!quest.isCompleted && !quest.isClaimed) {
        quest.currentProgress++;
        dailyQuests.refresh();

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

  /// Claim completed quest
  void claimQuest(QuestModel quest) {
    if (quest.isCompleted && !quest.isClaimed) {
      final index = dailyQuests.indexWhere((q) => q.id == quest.id);
      if (index != -1) {
        dailyQuests[index].isClaimed = true;
        dailyQuests.refresh();

        // Add XP to profile
        try {
          final profileController = Get.find<ProfileController>();
          profileController.addXP(quest.rewardXP);
        } catch (e) {
          // ProfileController not found, just show snackbar
        }

        Get.snackbar(
          '✨ Quest Claimed!',
          '+${quest.rewardXP} XP didapatkan!',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        // Check if all quests are claimed (ALL CLEAR!)
        _checkAllClearCombo();
      }
    }
  }

  /// Check if all daily quests are claimed -> trigger All Clear celebration
  void _checkAllClearCombo() {
    if (dailyQuests.isEmpty) return;

    final allClaimed = dailyQuests.every((q) => q.isClaimed);

    if (allClaimed) {
      // Add bonus 50 XP
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

  // === PARTNER ACTIONS ===

  void pokePartner() {
    updateQuestProgress('interaction');
    Get.snackbar(
      '👋 Colek!',
      'Kamu mencolek ${partnerName.value}!',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  void sendLove() {
    updateQuestProgress('interaction');
    Get.snackbar(
      '❤️ Rindu Terkirim!',
      '${partnerName.value} menerima cintamu 💕',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  void notifyPartner() {
    updateQuestProgress('interaction');
    Get.snackbar(
      '📢 Notif Terkirim!',
      '${partnerName.value} akan segera buka app!',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  // === ACTIONS ===

  void completeDailyQuest() {
    if (!isDailyQuestCompleted.value) {
      isDailyQuestCompleted.value = true;
      petStatus.value = PetStatus.happy;
      streakCount.value++;
      updateQuestProgress('interaction');
      Get.snackbar(
        '💕 Love Sent!',
        'Your pet is now happy! Streak: ${streakCount.value} days',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        '✨ Already Done!',
        'You\'ve already checked in today. See you tomorrow!',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void feedPet() {
    if (petStatus.value == PetStatus.hungry) {
      petStatus.value = PetStatus.happy;
      Get.snackbar(
        '🍖 Yummy!',
        '${petName.value} is now full and happy!',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void resetDailyQuest() {
    isDailyQuestCompleted.value = false;
    petStatus.value = PetStatus.hungry;
  }

  @override
  void onInit() {
    super.onInit();
    _initDailyQuests();
  }
}
