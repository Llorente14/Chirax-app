import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/badge_model.dart';

class ProfileController extends GetxController {
  // === USER DATA ===
  final name = 'Llorente'.obs;
  final username = '@partner_01'.obs;
  final birthDate = '07 Agustus 2003'.obs;
  final avatarAsset = 'assets/images/avatar_me.png'.obs;

  // === SECURITY ===
  final isBiometricActive = false.obs;
  final isNotificationActive = true.obs;

  void toggleBiometric(bool val) {
    isBiometricActive.value = val;
    if (val) {
      Get.snackbar(
        '🔐 Keamanan Aktif',
        'Kunci biometrik berhasil diaktifkan',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void toggleNotification(bool val) {
    isNotificationActive.value = val;
  }

  // === UPDATE PROFILE ===
  void updateProfile({
    String? newName,
    String? newUsername,
    String? newAvatar,
    String? newBirthDate,
  }) {
    if (newName != null && newName.isNotEmpty) {
      name.value = newName;
    }
    if (newUsername != null && newUsername.isNotEmpty) {
      username.value = newUsername;
    }
    if (newAvatar != null && newAvatar.isNotEmpty) {
      avatarAsset.value = newAvatar;
    }
    if (newBirthDate != null && newBirthDate.isNotEmpty) {
      birthDate.value = newBirthDate;
    }
  }

  // === ADVANCED GAMIFICATION ===
  final totalXP = 8750.obs;
  final totalAsset = 15500000.0.obs;
  final totalMissions = 84.obs;
  final streak = 121.obs;

  /// Add XP from quests or achievements
  void addXP(int amount) {
    totalXP.value += amount;
  }

  int get currentLevel => (totalXP.value / 1000).floor() + 1;

  String get levelTitle {
    if (currentLevel <= 5) return 'New Couple 🌱';
    if (currentLevel <= 10) return 'Love Birds 🕊️';
    if (currentLevel <= 20) return 'Soulmate 💖';
    return 'Legendary Lovers 👑';
  }

  String get formattedAsset {
    final value = totalAsset.value;
    if (value >= 1000000000) {
      return 'Rp ${(value / 1000000000).toStringAsFixed(1)}M';
    } else if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)}jt';
    } else if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(0)}rb';
    }
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  List<Map<String, dynamic>> get statsList => [
    {
      'icon': Icons.local_fire_department_rounded,
      'color': AppColors.secondary,
      'value': '${streak.value}',
      'label': 'Hari Streak 🔥',
    },
    {
      'icon': Icons.bolt_rounded,
      'color': const Color(0xFFFFC107),
      'value': '${totalXP.value}',
      'label': 'Lvl $currentLevel',
      'sublabel': levelTitle,
    },
    {
      'icon': Icons.savings_rounded,
      'color': AppColors.success,
      'value': formattedAsset,
      'label': 'Total Aset 💰',
    },
    {
      'icon': Icons.track_changes_rounded,
      'color': AppColors.moneyPurple,
      'value': '${totalMissions.value}',
      'label': 'Misi Selesai ✅',
    },
  ];

  // === BADGE SYSTEM ===
  final badges = <BadgeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadBadges();
  }

  void _loadBadges() {
    badges.value = [
      // === NEW BADGES ===
      BadgeModel(
        id: 'hemat_kopi',
        name: 'Hemat Kopi ☕',
        description:
            'Tidak ambil uang tabungan selama 1 bulan. Kuat banget! 💪',
        iconEmoji: '☕',
        isUnlocked: false,
        currentProgress: 12,
        targetProgress: 30,
        color: Colors.brown,
      ),
      BadgeModel(
        id: 'anniversary_king',
        name: 'Anniversary King 📅',
        description: 'Login tepat di hari Anniversary. So romantic! 💕',
        iconEmoji: '👑',
        isUnlocked: false,
        currentProgress: 0,
        targetProgress: 1,
        color: AppColors.primary,
      ),
      BadgeModel(
        id: 'stalker',
        name: 'Stalker 🕵️',
        description: 'Buka profil pasangan 5 kali sehari. Kangen terus ya? 😏',
        iconEmoji: '🕵️',
        isUnlocked: false,
        currentProgress: 3,
        targetProgress: 5,
        color: Colors.deepPurple,
      ),
      BadgeModel(
        id: 'bucin',
        name: 'Bucin 🥺',
        description: 'Buka aplikasi 10 kali dalam satu jam. Bucin sejati! 💗',
        iconEmoji: '🥺',
        isUnlocked: true,
        currentProgress: 10,
        targetProgress: 10,
        color: Colors.blue,
      ),
      BadgeModel(
        id: 'to_the_moon',
        name: 'To The Moon 🚀',
        description: 'Capai target tabungan 100%. Sampai bulan bareng! 🌙',
        iconEmoji: '🚀',
        isUnlocked: false,
        currentProgress: 65,
        targetProgress: 100,
        color: Colors.indigo,
      ),
      BadgeModel(
        id: 'saver_novice',
        name: 'Saver Novice 💰',
        description: 'Menabung 1 Juta Pertamamu! Ini awal yang bagus! 🎉',
        iconEmoji: '💰',
        isUnlocked: true,
        currentProgress: 1,
        targetProgress: 1,
        color: AppColors.success,
      ),
      // === OLD BADGES ===
      BadgeModel(
        id: 'on_fire',
        name: 'On Fire 🔥',
        description:
            'Streak selama 30 hari berturut-turut! Kamu konsisten banget!',
        iconEmoji: '🔥',
        isUnlocked: true,
        currentProgress: 30,
        targetProgress: 30,
        color: AppColors.secondary,
      ),
      BadgeModel(
        id: 'wealthy_couple',
        name: 'Wealthy Couple 💎',
        description: 'Total aset kalian mencapai 50 Juta Rupiah!',
        iconEmoji: '💎',
        isUnlocked: false,
        currentProgress: 15,
        targetProgress: 50,
        color: AppColors.moneyPurple,
      ),
      BadgeModel(
        id: 'memory_hoarder',
        name: 'Memory Hoarder 📸',
        description: 'Simpan 100 kenangan indah bersama pasangan!',
        iconEmoji: '📸',
        isUnlocked: false,
        currentProgress: 24,
        targetProgress: 100,
        color: AppColors.primary,
      ),
      BadgeModel(
        id: 'night_owl',
        name: 'Night Owl 🦉',
        description: 'Chatting romantis di atas jam 12 malam sebanyak 10 kali!',
        iconEmoji: '🦉',
        isUnlocked: false,
        currentProgress: 2,
        targetProgress: 10,
        color: const Color(0xFF5C6BC0),
      ),
      BadgeModel(
        id: 'anniversary',
        name: '1 Year Together 🎂',
        description: 'Merayakan 1 tahun bersama! Semoga langgeng! 💕',
        iconEmoji: '🎂',
        isUnlocked: false,
        currentProgress: 121,
        targetProgress: 365,
        color: AppColors.moneyPink,
      ),
    ];
  }

  // === ACTIONS ===
  void logout() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.dangerRed.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👋', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Keluar dari Akun?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Kamu yakin ingin keluar dari aplikasi?',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.snackbar(
                          '👋 Sampai Jumpa!',
                          'Kamu berhasil keluar',
                          snackPosition: SnackPosition.TOP,
                        );
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.dangerRed,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFB71C1C),
                              offset: Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Keluar',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
