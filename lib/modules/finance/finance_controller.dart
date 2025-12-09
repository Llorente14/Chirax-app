import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/savings_goal.dart';
import '../home/home_controller.dart';

class FinanceController extends GetxController {
  // === GOALS LIST ===
  final goals = <SavingsGoal>[].obs;
  final selectedIndex = 0.obs;

  // === FORM STATE ===
  final amountController = TextEditingController();

  // === GETTERS ===

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

  /// Add new goal
  void addNewGoal({
    required String title,
    required double target,
    double initialBalance = 0,
    required String icon,
    required Color color,
  }) {
    // Count current highlighted
    final highlightedCount = highlightedGoals.length;

    final newGoal = SavingsGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      targetAmount: target,
      currentAmount: initialBalance,
      iconEmoji: icon,
      color: color,
      isHighlighted: highlightedCount < 3, // Auto highlight if slot available
    );

    goals.add(newGoal);
    goals.refresh();

    Get.snackbar(
      '✅ Target Dibuat',
      '"$title" berhasil ditambahkan!',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  /// Toggle highlight status
  bool toggleHighlight(String id) {
    final index = goals.indexWhere((g) => g.id == id);
    if (index == -1) return false;

    final goal = goals[index];

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

    goals[index] = goal.copyWith(isHighlighted: !goal.isHighlighted);
    goals.refresh();
    return true;
  }

  /// Mark goal as completed
  void markAsCompleted(String id) {
    final index = goals.indexWhere((g) => g.id == id);
    if (index == -1) return;

    final goal = goals[index];
    goals[index] = goal.copyWith(
      isCompleted: true,
      isHighlighted: false,
      completedDate: DateTime.now(),
    );
    goals.refresh();

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
  void deleteGoal(String id) {
    final goal = goals.firstWhereOrNull((g) => g.id == id);
    if (goal == null) return;

    goals.removeWhere((g) => g.id == id);
    goals.refresh();

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

  /// Add savings to current goal
  void addSavings(double amount) {
    if (amount <= 0 || currentGoal == null) return;

    final goalId = currentGoal!.id;
    final index = goals.indexWhere((g) => g.id == goalId);
    if (index == -1) return;

    final goal = goals[index];
    final newAmount = goal.currentAmount + amount;

    goals[index] = goal.copyWith(
      currentAmount: newAmount.clamp(0, goal.targetAmount * 2),
    );
    goals.refresh();

    // Hook to quest system - update savings quest progress
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().updateQuestProgress('savings');
    }

    // Celebration if target reached
    if (goals[index].isTargetReached && !goal.isTargetReached) {
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
    _loadDummyData();
  }

  void _loadDummyData() {
    goals.addAll([
      SavingsGoal(
        id: '1',
        title: 'Trip Bali',
        targetAmount: 10000000,
        currentAmount: 6500000,
        iconEmoji: '🏖️',
        color: AppColors.secondary,
        isHighlighted: true,
      ),
      SavingsGoal(
        id: '2',
        title: 'Beli iPhone',
        targetAmount: 15000000,
        currentAmount: 3200000,
        iconEmoji: '📱',
        color: AppColors.moneyPurple,
        isHighlighted: true,
      ),
      SavingsGoal(
        id: '3',
        title: 'Dana Darurat',
        targetAmount: 20000000,
        currentAmount: 12000000,
        iconEmoji: '🛡️',
        color: AppColors.success,
        isHighlighted: true,
      ),
      SavingsGoal(
        id: '4',
        title: 'Beli Motor',
        targetAmount: 25000000,
        currentAmount: 5000000,
        iconEmoji: '🏍️',
        color: AppColors.moneyOrange,
        isHighlighted: false, // Not highlighted
      ),
    ]);
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
