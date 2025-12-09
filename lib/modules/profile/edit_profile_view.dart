import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers
    final nameController = TextEditingController(text: controller.name.value);
    final usernameController = TextEditingController(
      text: controller.username.value,
    );
    final birthDateController = TextEditingController(
      text: controller.birthDate.value,
    );
    final selectedAvatar = controller.avatarAsset.value.obs;

    // Avatar options
    final avatarOptions = [
      'assets/images/avatar_me.png',
      'assets/images/avatar_partner.png',
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
        title: Text('Edit Profil', style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === AVATAR SELECTOR ===
            Text('Pilih Avatar', style: AppTextStyles.subtitle),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: avatarOptions.length + 1, // +1 for default
                itemBuilder: (context, index) {
                  if (index == avatarOptions.length) {
                    // Default emoji avatar
                    return _buildAvatarOption(
                      isSelected: selectedAvatar.value == 'default',
                      onTap: () => selectedAvatar.value = 'default',
                      child: Container(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        child: const Center(
                          child: Text('👤', style: TextStyle(fontSize: 40)),
                        ),
                      ),
                    );
                  }
                  final avatar = avatarOptions[index];
                  return Obx(
                    () => _buildAvatarOption(
                      isSelected: selectedAvatar.value == avatar,
                      onTap: () => selectedAvatar.value = avatar,
                      child: Image.asset(
                        avatar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

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
            _buildChunkyInput(
              controller: birthDateController,
              hintText: '07 Agustus 2003',
              prefixIcon: Icons.cake_rounded,
            ),

            const SizedBox(height: 40),

            // === SIMPAN BUTTON ===
            GestureDetector(
              onTap: () {
                controller.updateProfile(
                  newName: nameController.text,
                  newUsername: usernameController.text,
                  newAvatar: selectedAvatar.value,
                  newBirthDate: birthDateController.text,
                );
                Get.back();
                Get.snackbar(
                  '✅ Berhasil',
                  'Profil berhasil diperbarui!',
                  snackPosition: SnackPosition.TOP,
                );
              },
              child: Container(
                width: double.infinity,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.successShadow,
                      offset: const Offset(0, 5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.save_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text('SIMPAN PERUBAHAN', style: AppTextStyles.button),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption({
    required bool isSelected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Stack(
          children: [
            // Shadow
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            // Avatar Container
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  width: isSelected ? 4 : 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isSelected ? 19 : 21),
                child: child,
              ),
            ),
            // Check mark
            if (isSelected)
              Positioned(
                right: 0,
                bottom: 6,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
