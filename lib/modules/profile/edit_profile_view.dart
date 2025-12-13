import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/sound_helper.dart';
import 'profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers with current values
    final nameController = TextEditingController(text: controller.name);
    final usernameController = TextEditingController(text: controller.username);
    final selectedBirthDate = Rxn<DateTime>(controller.rxBirthDate.value);

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
          onPressed: () {
            SoundHelper.playPop();
            Get.back();
          },
        ),
        title: Text('Edit Profil', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === AVATAR SELECTOR (3 OPTIONS) ===
            Text('Pilih Avatar', style: AppTextStyles.subtitle),
            const SizedBox(height: 16),
            Obx(() => _buildAvatarSelector()),

            const SizedBox(height: 28),

            // === NAMA ===
            Text('Nama', style: AppTextStyles.subtitle),
            const SizedBox(height: 8),
            _buildChunkyInput(
              controller: nameController,
              hintText: 'Nama kamu',
              prefixIcon: Icons.person_rounded,
            ),

            const SizedBox(height: 20),

            // === USERNAME ===
            Text('Username', style: AppTextStyles.subtitle),
            const SizedBox(height: 8),
            _buildChunkyInput(
              controller: usernameController,
              hintText: '@username',
              prefixIcon: Icons.alternate_email_rounded,
            ),

            const SizedBox(height: 20),

            // === TANGGAL LAHIR ===
            Text('Tanggal Lahir', style: AppTextStyles.subtitle),
            const SizedBox(height: 8),
            Obx(
              () => _buildDatePicker(
                context: context,
                selectedDate: selectedBirthDate,
              ),
            ),

            const SizedBox(height: 40),

            // === SIMPAN BUTTON ===
            Obx(
              () => GestureDetector(
                onTap: controller.isLoading.value
                    ? null
                    : () async {
                        SoundHelper.playClick();
                        // Parse birthDate
                        final birthDate = selectedBirthDate.value;

                        await controller.updateProfile(
                          name: nameController.text.trim(),
                          username: usernameController.text.trim(),
                          birthDate: birthDate,
                        );
                      },
                child: Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    color: controller.isLoading.value
                        ? Colors.grey.shade300
                        : AppColors.success,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: controller.isLoading.value
                            ? Colors.grey.shade400
                            : AppColors.successShadow,
                        offset: const Offset(0, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: controller.isLoading.value
                        ? [
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
                            Text('MENYIMPAN...', style: AppTextStyles.button),
                          ]
                        : [
                            const Icon(
                              Icons.save_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'SIMPAN PERUBAHAN',
                              style: AppTextStyles.button,
                            ),
                          ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Avatar Selector - Grid Layout: Upload, Default, + Presets
  Widget _buildAvatarSelector() {
    final currentAvatar = controller.rxAvatar.value;
    final isBase64 = currentAvatar.startsWith('base64:');

    return Column(
      children: [
        // Row 1: Upload + Default
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Upload from Gallery
            _buildAvatarOption(
              customChild: isBase64
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Image.memory(
                        base64Decode(currentAvatar.replaceFirst('base64:', '')),
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 70,
                          height: 70,
                          color: AppColors.primary,
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    )
                  : null,
              icon: isBase64 ? null : Icons.camera_alt_rounded,
              label: 'Upload',
              backgroundColor: AppColors.primary,
              iconColor: Colors.white,
              isSelected: isBase64,
              onTap: () => controller.uploadFromGallery(),
            ),
            const SizedBox(width: 20),
            // Default
            _buildAvatarOption(
              icon: Icons.person_rounded,
              label: 'Default',
              backgroundColor: Colors.grey.shade300,
              iconColor: Colors.grey.shade600,
              isSelected: currentAvatar == 'DEFAULT',
              onTap: () => controller.resetToDefault(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Row 2: Preset Avatars (Centered with Wrap)
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: controller.avatarPresets.map((fileName) {
            final assetPath = 'assets/images/avatars/$fileName';
            final name = fileName.replaceAll('.png', '');
            final displayName = name[0].toUpperCase() + name.substring(1);

            return _buildAvatarOption(
              customChild: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: Image.asset(
                  assetPath,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.person, size: 32),
                  ),
                ),
              ),
              label: displayName,
              isSelected: currentAvatar == assetPath,
              onTap: () => controller.selectPresetAvatar(fileName),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvatarOption({
    IconData? icon,
    Widget? customChild,
    required String label,
    Color? backgroundColor,
    Color? iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        SoundHelper.playClick();
        onTap();
      },
      child: Column(
        children: [
          Stack(
            children: [
              // Shadow
              Container(
                margin: const EdgeInsets.only(top: 5),
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.success : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              // Avatar Container
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.success
                        : Colors.grey.shade300,
                    width: isSelected ? 4 : 2,
                  ),
                ),
                child:
                    customChild ??
                    Center(child: Icon(icon, size: 32, color: iconColor)),
              ),
              // Check mark
              if (isSelected)
                Positioned(
                  right: 0,
                  bottom: 5,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required BuildContext context,
    required Rxn<DateTime> selectedDate,
  }) {
    return GestureDetector(
      onTap: () async {
        SoundHelper.playClick();
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate.value ?? DateTime(2000, 1, 1),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
          helpText: 'Pilih Tanggal Lahir',
          cancelText: 'Batal',
          confirmText: 'Pilih',
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppColors.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          selectedDate.value = picked;
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.cake_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              selectedDate.value != null
                  ? _formatDate(selectedDate.value!)
                  : 'Pilih tanggal lahir',
              style: AppTextStyles.body.copyWith(
                color: selectedDate.value != null
                    ? AppColors.textPrimary
                    : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildChunkyInput({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.body.copyWith(color: Colors.grey.shade400),
          prefixIcon: Icon(prefixIcon, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
