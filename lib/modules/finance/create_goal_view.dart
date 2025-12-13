import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'finance_controller.dart';

class CreateGoalView extends GetView<FinanceController> {
  const CreateGoalView({super.key});

  @override
  Widget build(BuildContext context) {
    // Form Controllers
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final initialController = TextEditingController();
    final selectedEmoji = '🏠'.obs;
    final selectedColor = AppColors.primary.obs;
    final isLoading = false.obs;

    // Emoji Options
    const emojis = [
      '🏠',
      '🚗',
      '✈️',
      '💍',
      '💻',
      '📱',
      '🍔',
      '🏥',
      '🎓',
      '🏖️',
      '🛡️',
      '🎮',
    ];

    // Color Options - 8 warna untuk grid 2x4
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.moneyPurple,
      AppColors.moneyOrange,
      AppColors.moneyPink,
      const Color(0xFFE74C3C), // Red
      const Color(0xFF6B7280), // Grey
    ];

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text('Buat Target Baru', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === NAMA TARGET ===
            Text('Nama Target', style: AppTextStyles.subtitle),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'Contoh: Trip ke Jepang',
                hintStyle: AppTextStyles.body.copyWith(
                  color: Colors.grey.shade400,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),

            // === NOMINAL TARGET ===
            Text('Nominal Target', style: AppTextStyles.subtitle),
            const SizedBox(height: 8),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              inputFormatters: [_RupiahInputFormatter()],
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: '10.000.000',
                hintStyle: AppTextStyles.body.copyWith(
                  color: Colors.grey.shade400,
                ),
                prefixText: 'Rp ',
                prefixStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),

            // === SALDO AWAL ===
            Text('Saldo Awal (Opsional)', style: AppTextStyles.subtitle),
            const SizedBox(height: 4),
            Text(
              'Masukkan jika sudah ada tabungan sebelumnya',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: initialController,
              keyboardType: TextInputType.number,
              inputFormatters: [_RupiahInputFormatter()],
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: AppTextStyles.body.copyWith(
                  color: Colors.grey.shade400,
                ),
                prefixText: 'Rp ',
                prefixStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),

            // === PILIH IKON ===
            Text('Pilih Ikon', style: AppTextStyles.subtitle),
            const SizedBox(height: 12),
            Obx(
              () => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: emojis.map((emoji) {
                  final isSelected = selectedEmoji.value == emoji;
                  return GestureDetector(
                    onTap: () => selectedEmoji.value = emoji,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? selectedColor.value.withValues(alpha: 0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? selectedColor.value
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: selectedColor.value.withValues(
                                    alpha: 0.3,
                                  ),
                                  offset: const Offset(0, 3),
                                  blurRadius: 0,
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // === PILIH WARNA === (Grid 2x4)
            Text('Pilih Warna', style: AppTextStyles.subtitle),
            const SizedBox(height: 12),
            Obx(
              () => GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                childAspectRatio: 1,
                physics: const NeverScrollableScrollPhysics(),
                children: colors.map((color) {
                  final isSelected = selectedColor.value == color;
                  return GestureDetector(
                    onTap: () => selectedColor.value = color,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.textPrimary
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            offset: const Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 40),

            // === SIMPAN BUTTON dengan Loading State ===
            Obx(
              () => _buildSaveButton(
                isLoading: isLoading.value,
                onPressed: () async {
                  // Validate
                  final title = titleController.text.trim();
                  final targetText = targetController.text.replaceAll(
                    RegExp(r'[^0-9]'),
                    '',
                  );
                  final initialText = initialController.text.replaceAll(
                    RegExp(r'[^0-9]'),
                    '',
                  );

                  if (title.isEmpty) {
                    Get.snackbar(
                      '⚠️ Nama Kosong',
                      'Masukkan nama target tabungan',
                      snackPosition: SnackPosition.TOP,
                    );
                    return;
                  }

                  if (targetText.isEmpty) {
                    Get.snackbar(
                      '⚠️ Target Kosong',
                      'Masukkan nominal target tabungan',
                      snackPosition: SnackPosition.TOP,
                    );
                    return;
                  }

                  final target = double.tryParse(targetText) ?? 0;
                  final initial = double.tryParse(initialText) ?? 0;

                  if (target <= 0) {
                    Get.snackbar(
                      '⚠️ Target Invalid',
                      'Nominal target harus lebih dari 0',
                      snackPosition: SnackPosition.TOP,
                    );
                    return;
                  }

                  // Set loading
                  isLoading.value = true;

                  // Simulate saving delay
                  await Future.delayed(const Duration(milliseconds: 500));

                  // Create goal
                  controller.addNewGoal(
                    title: title,
                    target: target,
                    initialBalance: initial,
                    icon: selectedEmoji.value,
                    color: selectedColor.value,
                  );

                  isLoading.value = false;

                  // Show success dialog
                  _showSuccessDialog(title, selectedEmoji.value);
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton({
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 61,
        child: Stack(
          children: [
            // Shadow
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: isLoading
                      ? Colors.grey.shade400
                      : AppColors.successShadow,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            // Button
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: isLoading ? Colors.grey.shade300 : AppColors.success,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading) ...[
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'MENYIMPAN...',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.save_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SIMPAN TARGET',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(String title, String emoji) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Target Berhasil Dibuat! 🎉',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Content
              Text(
                '"$title" sudah ditambahkan ke daftar targetmu.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Button - Lihat Target
              GestureDetector(
                onTap: () {
                  Get.back(); // Close dialog
                  Get.back(); // Back to ManageGoalsView
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.successShadow,
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'LIHAT DAFTAR TARGET',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

/// Custom TextInputFormatter untuk format Rupiah
class _RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final formatted = _formatWithThousandSeparator(digitsOnly);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatWithThousandSeparator(String digits) {
    final buffer = StringBuffer();
    final length = digits.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }
}
