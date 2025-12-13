import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/sound_helper.dart';
import '../../data/models/savings_goal.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/database_service.dart';
import '../home/home_controller.dart';

class FinanceController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final DatabaseService _dbService = Get.find<DatabaseService>();

  // === GOALS LIST (Real-time from Firestore) ===
  final goals = <SavingsGoal>[].obs;
  final selectedIndex = 0.obs;
  final isLoading = true.obs;

  // === FORM STATE ===
  final amountController = TextEditingController();

  // === STREAM SUBSCRIPTION ===
  StreamSubscription? _goalsSubscription;

  // === GETTERS ===

  /// Get coupleId from AuthService
  String? get coupleId => _authService.userModel.value?.coupleId;

  /// Active goals (not completed)
  List<SavingsGoal> get activeGoals =>
      goals.where((g) => !g.isCompleted).toList();

  /// Completed goals (history)
  List<SavingsGoal> get historyGoals =>
      goals.where((g) => g.isCompleted).toList();

  /// Highlighted goals (active + highlighted, max 3)
  List<SavingsGoal> get highlightedGoals =>
      activeGoals.where((g) => g.isHighlighted).take(3).toList();

  /// Current goal (selected from highlighted)
  SavingsGoal? get currentGoal {
    if (highlightedGoals.isEmpty) return null;
    final idx = selectedIndex.value.clamp(0, highlightedGoals.length - 1);
    return highlightedGoals[idx];
  }

  double get progressPercentage => currentGoal?.progressPercentage ?? 0;
  int get progressPercent => currentGoal?.progressPercent ?? 0;
  bool get isCompleted => currentGoal?.isTargetReached ?? false;

  // === TAB ACTIONS ===
  void selectGoal(int index) {
    if (index >= 0 && index < highlightedGoals.length) {
      selectedIndex.value = index;
    }
  }

  // === GOAL MANAGEMENT ===

  /// Add new goal to Firestore
  Future<void> addNewGoal({
    required String title,
    required double target,
    double initialBalance = 0,
    required String icon,
    required Color color,
  }) async {
    if (coupleId == null) return;

    // Count current highlighted
    final highlightedCount = highlightedGoals.length;

    final newGoal = SavingsGoal(
      id: '', // Will be assigned by Firestore
      title: title,
      targetAmount: target,
      currentAmount: initialBalance,
      iconEmoji: icon,
      color: color,
      isHighlighted: highlightedCount < 3, // Auto highlight if slot available
    );

    final result = await _dbService.addGoal(coupleId!, newGoal);
    if (result != null) {
      Get.snackbar(
        '✅ Target Dibuat',
        '"$title" berhasil ditambahkan!',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Toggle highlight status
  Future<bool> toggleHighlight(String id) async {
    if (coupleId == null) return false;

    final goal = goals.firstWhereOrNull((g) => g.id == id);
    if (goal == null) return false;

    // If trying to highlight
    if (!goal.isHighlighted) {
      // Check if already 3 highlighted
      if (highlightedGoals.length >= 3) {
        Get.snackbar(
          '⚠️ Batas Tercapai',
          'Maksimal 3 target dapat di-highlight. Nonaktifkan salah satu dulu.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    }

    await _dbService.toggleGoalHighlight(coupleId!, id, !goal.isHighlighted);
    return true;
  }

  /// Mark goal as completed
  Future<void> markAsCompleted(String id) async {
    if (coupleId == null) return;

    final goal = goals.firstWhereOrNull((g) => g.id == id);
    if (goal == null) return;

    await _dbService.completeGoal(coupleId!, id);

    // Track badge progress: Goals Completed for "To The Moon" badge
    await _dbService.incrementGoalsCompleted(coupleId!);

    // Reset selected index
    if (highlightedGoals.isNotEmpty) {
      selectedIndex.value = 0;
    }

    Get.snackbar(
      '🎉 Selamat!',
      'Target "${goal.title}" telah diselesaikan!',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  /// Delete goal permanently
  Future<void> deleteGoal(String id) async {
    if (coupleId == null) return;

    final goal = goals.firstWhereOrNull((g) => g.id == id);
    if (goal == null) return;

    SoundHelper.playError();
    await _dbService.deleteGoal(coupleId!, id);

    // Reset selected index
    if (highlightedGoals.isNotEmpty &&
        selectedIndex.value >= highlightedGoals.length) {
      selectedIndex.value = 0;
    }

    Get.snackbar(
      '🗑️ Dihapus',
      '"${goal.title}" telah dihapus.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  // === SAVINGS ACTIONS ===

  /// Add savings to current goal via Firestore
  Future<void> addSavings(double amount) async {
    if (amount <= 0 || currentGoal == null || coupleId == null) return;

    final goal = currentGoal!;
    final newAmount = (goal.currentAmount + amount).clamp(
      0.0,
      goal.targetAmount * 2,
    );

    await _dbService.updateGoalAmount(
      coupleId!,
      goal.id,
      newAmount,
      addedAmount: amount, // Hook to update totalAssets
    );

    SoundHelper.playCoins();

    // Hook to quest system - update savings quest progress
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().updateQuestProgress('savings');
    }

    // Celebration if target reached
    if (newAmount >= goal.targetAmount && !goal.isTargetReached) {
      Get.snackbar(
        '🎉 Target Tercapai!',
        '"${goal.title}" sudah mencapai target!',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Add from input field
  void addFromInput() {
    final text = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isEmpty) return;

    final amount = double.tryParse(text) ?? 0;
    if (amount > 0) {
      addSavings(amount);
      amountController.clear();
      Get.back();
    }
  }

  /// Add preset to input field (additive/multiply)
  void setPresetToInput(int amount) {
    // Get current value from input
    final currentText = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final currentAmount = int.tryParse(currentText) ?? 0;

    // Add the preset amount to current value
    final newAmount = currentAmount + amount;
    amountController.text = formatInputNumber(newAmount);
  }

  /// Format input number with separator
  String formatInputNumber(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  /// Format currency Indonesia
  String formatCurrency(double amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  @override
  void onInit() {
    super.onInit();
    _initStream();
  }

  /// Initialize real-time stream from Firestore
  void _initStream() {
    // Wait for auth to be ready
    ever(_authService.userModel, (user) {
      if (user?.coupleId != null) {
        _startListeningGoals(user!.coupleId!);
      }
    });

    // Also try immediately if already authenticated
    if (coupleId != null) {
      _startListeningGoals(coupleId!);
    }
  }

  void _startListeningGoals(String coupleId) {
    _goalsSubscription?.cancel();
    isLoading.value = true;

    _goalsSubscription = _dbService
        .streamGoals(coupleId)
        .listen(
          (goalsList) {
            goals.value = goalsList;
            isLoading.value = false;
          },
          onError: (e) {
            isLoading.value = false;
            Get.snackbar('Error', 'Gagal memuat goals: $e');
          },
        );
  }

  @override
  void onClose() {
    amountController.dispose();
    _goalsSubscription?.cancel();
    super.onClose();
  }
}
