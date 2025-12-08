import 'package:get/get.dart';

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

  // === RELATIONSHIP DATA ===
  // Tanggal mulai hubungan (default: 1 tahun lalu)
  final startDate = DateTime.now().subtract(const Duration(days: 365)).obs;

  // Getter: Hitung jumlah hari bersama
  int get daysTogether {
    final now = DateTime.now();
    return now.difference(startDate.value).inDays;
  }

  // === GAMIFICATION DATA ===
  final streakCount = 12.obs;
  final petStatus = PetStatus.hungry.obs;
  final isDailyQuestCompleted = false.obs;

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

  // === ACTIONS ===

  /// Complete daily quest - ubah status pet dan tambah streak
  void completeDailyQuest() {
    if (!isDailyQuestCompleted.value) {
      // Mark quest as completed
      isDailyQuestCompleted.value = true;

      // Make pet happy
      petStatus.value = PetStatus.happy;

      // Increment streak
      streakCount.value++;

      // Show snackbar feedback
      Get.snackbar(
        '💕 Love Sent!',
        'Your pet is now happy! Streak: ${streakCount.value} days',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } else {
      // Already completed today
      Get.snackbar(
        '✨ Already Done!',
        'You\'ve already checked in today. See you tomorrow!',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Feed the pet - bisa digunakan untuk action lain
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

  /// Reset daily quest (untuk testing atau new day)
  void resetDailyQuest() {
    isDailyQuestCompleted.value = false;
    petStatus.value = PetStatus.hungry;
  }

  @override
  void onInit() {
    super.onInit();
    // Bisa tambahkan logic untuk cek hari baru dan reset quest
  }
}
