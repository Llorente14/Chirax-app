import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/badge_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/database_service.dart';
import '../home/home_controller.dart';
import '../auth/login_view.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final DatabaseService _dbService = Get.find<DatabaseService>();

  // === SECURITY ===
  final isBiometricActive = false.obs;
  final isNotificationActive = true.obs;

  // === REACTIVE PROFILE DATA ===
  final rxName = ''.obs;
  final rxUsername = ''.obs;
  final rxBirthDate = Rxn<DateTime>();
  final rxAvatar = 'DEFAULT'.obs; // 'DEFAULT', 'assets/...', or 'base64:...'
  final isLoading = false.obs;

  // === FORM CONTROLLERS ===
  late TextEditingController nameController;
  late TextEditingController usernameController;

  @override
  void onInit() {
    super.onInit();
    // Initialize from AuthService
    _syncFromAuthService();

    // Listen to userModel changes
    ever(_authService.userModel, (_) => _syncFromAuthService());

    // Initialize form controllers
    nameController = TextEditingController(text: rxName.value);
    usernameController = TextEditingController(text: rxUsername.value);

    // Load badges
    _loadBadges();

    // Set up reactive listener after a short delay to ensure HomeController is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      _setupReactiveBadges();
    });
  }

  void _syncFromAuthService() {
    final user = _authService.userModel.value;
    if (user != null) {
      rxName.value = user.name ?? 'User';
      rxUsername.value = user.username ?? '';
      rxBirthDate.value = user.birthday;
      rxAvatar.value = user.avatar ?? 'DEFAULT';
    }
  }

  // === GETTERS FOR REAL DATA ===

  /// User name from reactive
  String get name => rxName.value.isNotEmpty ? rxName.value : 'User';

  /// Username from reactive
  String get username {
    final un = rxUsername.value;
    if (un.isEmpty) return '@user';
    return un.startsWith('@') ? un : '@$un';
  }

  /// Birth date formatted
  String get birthDate {
    final birthday = rxBirthDate.value;
    if (birthday == null) return 'Belum diatur';
    return _formatDate(birthday);
  }

  /// Avatar value (for JuicyAvatar)
  String get avatarAsset => rxAvatar.value;

  /// Format date to Indonesian format
  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // === SECURITY TOGGLES ===

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

  // === UPDATE PROFILE (CRITICAL FIX) ===
  Future<void> updateProfile({
    required String name,
    required String username,
    required DateTime? birthDate,
  }) async {
    final uid = _authService.currentUser.value?.uid;
    if (uid == null) return;

    isLoading.value = true;

    try {
      // Update Firestore
      final success = await _dbService.updateUserProfile(
        uid: uid,
        name: name,
        username: username.replaceAll('@', ''),
        birthday: birthDate ?? DateTime.now(),
      );

      if (success) {
        // IMMEDIATE UPDATE: Update local reactive variables
        rxName.value = name;
        rxUsername.value = username.replaceAll('@', '');
        rxBirthDate.value = birthDate;

        // Update form controllers
        nameController.text = name;
        usernameController.text = username;

        Get.snackbar(
          '✅ Berhasil',
          'Profil berhasil diperbarui!',
          snackPosition: SnackPosition.TOP,
        );
        Get.back();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // === AVATAR FUNCTIONS (3 OPTIONS) ===

  /// Image Picker instance
  final ImagePicker _picker = ImagePicker();

  /// Option 1: Upload from Gallery
  Future<void> uploadFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 256, // Better resolution, still safe
        maxHeight: 256,
        imageQuality: 60, // Balanced quality
      );

      if (image == null) return;

      isLoading.value = true;

      // Read image bytes
      final bytes = await File(image.path).readAsBytes();

      // Check size (Firestore limit is ~1MB per field, aiming for <200KB)
      if (bytes.length > 200000) {
        // 200KB max
        Get.snackbar(
          '⚠️ Gambar Terlalu Besar',
          'Pilih gambar dengan ukuran lebih kecil',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // Convert to base64
      final base64String = 'base64:${base64Encode(bytes)}';

      // Save to Firestore
      await _saveAvatarToFirestore(base64String);

      // Update local state
      rxAvatar.value = base64String;

      Get.snackbar(
        '✅ Avatar Updated',
        'Foto profil berhasil diubah!',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      final errorMsg = e.toString();
      Get.snackbar(
        'Error',
        'Gagal upload foto: ${errorMsg.length > 80 ? errorMsg.substring(0, 80) : errorMsg}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Option 2: Select Kaito Avatar (Asset)
  Future<void> selectKaitoAvatar() async {
    const assetPath = 'assets/images/avatar_me.png';

    isLoading.value = true;
    try {
      await _saveAvatarToFirestore(assetPath);
      rxAvatar.value = assetPath;

      Get.snackbar(
        '✅ Avatar Updated',
        'Avatar Kaito dipilih!',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Option 3: Reset to Default
  Future<void> resetToDefault() async {
    isLoading.value = true;
    try {
      await _saveAvatarToFirestore('DEFAULT');
      rxAvatar.value = 'DEFAULT';

      Get.snackbar(
        '✅ Avatar Reset',
        'Avatar dikembalikan ke default!',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Helper: Save avatar string to Firestore
  Future<void> _saveAvatarToFirestore(String avatarValue) async {
    final uid = _authService.currentUser.value?.uid;
    if (uid == null) return;

    try {
      await _dbService.usersCollection.doc(uid).update({'avatar': avatarValue});
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan avatar: $e');
    }
  }

  // === GAMIFICATION GETTERS FROM HOMECONTROLLER ===

  /// Get HomeController if available
  HomeController? get _homeController {
    try {
      return Get.find<HomeController>();
    } catch (e) {
      return null;
    }
  }

  /// Total XP from couple data
  int get totalXP => _homeController?.totalXP ?? 0;

  /// Total assets from couple data
  double get totalAsset =>
      _homeController?.coupleData.value?.totalAssets ?? 0.0;

  /// Streak from couple data
  int get streak => _homeController?.streakCount ?? 0;

  /// Days together
  int get daysTogether => _homeController?.daysTogether ?? 0;

  /// Total missions completed (local count for now)
  int get totalMissions =>
      _homeController?.dailyQuests.where((q) => q.isClaimed).length ?? 0;

  /// Add XP (hook from quests)
  void addXP(int amount) {
    // XP is now handled by HomeController via DatabaseService
  }

  /// Current level based on XP
  int get currentLevel => (totalXP / 1000).floor() + 1;

  /// Level title based on level
  String get levelTitle {
    if (currentLevel <= 5) return 'New Couple 🌱';
    if (currentLevel <= 10) return 'Love Birds 🕊️';
    if (currentLevel <= 20) return 'Soulmate 💖';
    return 'Legendary Lovers 👑';
  }

  /// Formatted total assets
  String get formattedAsset {
    final value = totalAsset;
    if (value >= 1000000000) {
      return 'Rp ${(value / 1000000000).toStringAsFixed(1)}M';
    } else if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)}jt';
    } else if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(0)}rb';
    }
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  /// Stats list for grid display
  List<Map<String, dynamic>> get statsList => [
    {
      'icon': Icons.local_fire_department_rounded,
      'color': AppColors.secondary,
      'value': '$streak',
      'label': 'Hari Streak 🔥',
    },
    {
      'icon': Icons.bolt_rounded,
      'color': const Color(0xFFFFC107),
      'value': '$totalXP',
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
      'icon': Icons.favorite_rounded,
      'color': AppColors.primary,
      'value': '$daysTogether',
      'label': 'Hari Bersama 💕',
    },
  ];

  // === BADGE SYSTEM ===
  final badges = <BadgeModel>[].obs;
  Worker? _coupleDataWorker;

  @override
  void onClose() {
    _coupleDataWorker?.dispose();
    super.onClose();
  }

  /// Setup reactive listener for coupleData changes
  void _setupReactiveBadges() {
    final homeCtrl = _homeController;
    if (homeCtrl != null) {
      // Listen to coupleData changes to auto-refresh badges
      // This ensures badges update when XP, streak, or assets change
      _coupleDataWorker = ever(homeCtrl.coupleData, (_) {
        _loadBadges();
      });
    }
  }

  /// Refresh badges manually (can be called after data changes)
  void refreshBadges() {
    _loadBadges();
  }

  /// NEW: Check if today is the anniversary date
  bool _isAnniversaryToday() {
    final startDate = _homeController?.coupleData.value?.startDate;
    if (startDate == null) return false;
    final today = DateTime.now();
    return today.month == startDate.month && today.day == startDate.day;
  }

  void _loadBadges() {
    // Get dynamic badge progress from coupleData
    final badgeProgress =
        _homeController?.coupleData.value?.badgeProgress ?? {};

    // Check anniversary status dynamically
    final isAnniversary = _isAnniversaryToday();

    // Get dynamic progress values (with defaults)
    final daysWithoutWithdrawal = badgeProgress['daysWithoutWithdrawal'] ?? 0;
    final profileViewsToday = badgeProgress['profileViewsToday'] ?? 0;
    final goalsCompleted = badgeProgress['goalsCompleted'] ?? 0;
    final memoriesSaved = badgeProgress['memoriesSaved'] ?? 0;
    final appOpensThisHour = badgeProgress['appOpensThisHour'] ?? 0;

    badges.value = [
      // === DYNAMIC BADGES (with Firestore tracking) ===
      BadgeModel(
        id: 'hemat_kopi',
        name: 'Hemat Kopi ☕',
        description:
            'Tidak ambil uang tabungan selama 1 bulan. Kuat banget! 💪',
        iconEmoji: '☕',
        isUnlocked: daysWithoutWithdrawal >= 30,
        currentProgress: daysWithoutWithdrawal.clamp(0, 30),
        targetProgress: 30,
        color: Colors.brown,
      ),
      BadgeModel(
        id: 'anniversary_king',
        name: 'Anniversary King 📅',
        description: 'Login tepat di hari Anniversary. So romantic! 💕',
        iconEmoji: '👑',
        isUnlocked: isAnniversary,
        currentProgress: isAnniversary ? 1 : 0,
        targetProgress: 1,
        color: AppColors.primary,
      ),
      BadgeModel(
        id: 'stalker',
        name: 'Stalker 🕵️',
        description: 'Buka profil pasangan 5 kali sehari. Kangen terus ya? 😏',
        iconEmoji: '🕵️',
        isUnlocked: profileViewsToday >= 5,
        currentProgress: profileViewsToday.clamp(0, 5),
        targetProgress: 5,
        color: Colors.deepPurple,
      ),
      BadgeModel(
        id: 'bucin',
        name: 'Bucin 🥺',
        description: 'Buka aplikasi 10 kali dalam satu jam. Bucin sejati! 💗',
        iconEmoji: '🥺',
        isUnlocked: appOpensThisHour >= 10,
        currentProgress: appOpensThisHour.clamp(0, 10),
        targetProgress: 10,
        color: Colors.blue,
      ),
      BadgeModel(
        id: 'to_the_moon',
        name: 'To The Moon 🚀',
        description: 'Selesaikan 5 target tabungan. Sampai bulan bareng! 🌙',
        iconEmoji: '🚀',
        isUnlocked: goalsCompleted >= 5,
        currentProgress: goalsCompleted.clamp(0, 5),
        targetProgress: 5,
        color: Colors.indigo,
      ),
      BadgeModel(
        id: 'saver_novice',
        name: 'Saver Novice 💰',
        description: 'Menabung 1 Juta Pertamamu! Ini awal yang bagus! 🎉',
        iconEmoji: '💰',
        isUnlocked: totalAsset >= 1000000,
        currentProgress: totalAsset >= 1000000 ? 1 : 0,
        targetProgress: 1,
        color: AppColors.success,
      ),
      // === STREAK BADGES ===
      BadgeModel(
        id: 'on_fire',
        name: 'On Fire 🔥',
        description:
            'Streak selama 30 hari berturut-turut! Kamu konsisten banget!',
        iconEmoji: '🔥',
        isUnlocked: streak >= 30,
        currentProgress: streak.clamp(0, 30),
        targetProgress: 30,
        color: AppColors.secondary,
      ),
      // === ASSET BADGES ===
      BadgeModel(
        id: 'wealthy_couple',
        name: 'Wealthy Couple 💎',
        description: 'Total aset kalian mencapai 50 Juta Rupiah!',
        iconEmoji: '💎',
        isUnlocked: totalAsset >= 50000000,
        currentProgress: (totalAsset / 1000000).floor().clamp(0, 50),
        targetProgress: 50,
        color: AppColors.moneyPurple,
      ),
      // === MEMORY BADGES ===
      BadgeModel(
        id: 'memory_hoarder',
        name: 'Memory Hoarder 📸',
        description: 'Simpan 100 kenangan indah bersama pasangan!',
        iconEmoji: '📸',
        isUnlocked: memoriesSaved >= 100,
        currentProgress: memoriesSaved.clamp(0, 100),
        targetProgress: 100,
        color: AppColors.primary,
      ),
      // === MILESTONE BADGES ===
      BadgeModel(
        id: 'anniversary',
        name: '1 Year Together 🎂',
        description: 'Merayakan 1 tahun bersama! Semoga langgeng! 💕',
        iconEmoji: '🎂',
        isUnlocked: daysTogether >= 365,
        currentProgress: daysTogether.clamp(0, 365),
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
                      onTap: () async {
                        Get.back();
                        await _authService.signOut();
                        Get.offAll(() => const LoginView());
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
