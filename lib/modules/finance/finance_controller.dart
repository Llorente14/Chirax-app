import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/savings_goal.dart';

class FinanceController extends GetxController {
  // === MULTI-GOAL SUPPORT (max 4) ===
  final goals = <SavingsGoal>[].obs;
  final selectedIndex = 0.obs;

  // === FORM STATE ===
  final amountController = TextEditingController();

  // === GETTERS ===
  SavingsGoal get currentGoal => goals[selectedIndex.value];
  double get progressPercentage => currentGoal.progressPercentage;
  int get progressPercent => currentGoal.progressPercent;
  bool get isCompleted => currentGoal.isCompleted;

  // === TAB ACTIONS ===
  void selectGoal(int index) {
    if (index >= 0 && index < goals.length) {
      selectedIndex.value = index;
    }
  }

  // === SAVINGS ACTIONS ===

  /// Tambah tabungan ke current goal
  void addSavings(double amount) {
    if (amount <= 0) return;

    final current = currentGoal;
    final newAmount = current.currentAmount + amount;

    goals[selectedIndex.value] = current.copyWith(
      currentAmount: newAmount.clamp(0, current.targetAmount * 2),
    );
    goals.refresh();

    // Celebration if completed
    if (goals[selectedIndex.value].isCompleted && !current.isCompleted) {
      Get.snackbar(
        '🎉 Selamat!',
        'Target "${current.title}" tercapai!',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Tambah dari input manual
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

  /// Tambah preset ke input field
  void addPresetToInput(int amount) {
    final current = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final currentAmount = int.tryParse(current) ?? 0;
    final newAmount = currentAmount + amount;
    amountController.text = formatInputNumber(newAmount);
  }

  /// Set preset ke input field (ganti bukan tambah)
  void setPresetToInput(int amount) {
    amountController.text = formatInputNumber(amount);
  }

  /// Format input number dengan separator
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
      ),
      SavingsGoal(
        id: '2',
        title: 'Beli iPhone',
        targetAmount: 15000000,
        currentAmount: 3200000,
        iconEmoji: '📱',
        color: AppColors.moneyPurple,
      ),
      SavingsGoal(
        id: '3',
        title: 'Dana Darurat',
        targetAmount: 20000000,
        currentAmount: 12000000,
        iconEmoji: '🛡️',
        color: AppColors.success,
      ),
    ]);
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
