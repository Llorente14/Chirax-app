import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/bouncy_widgets.dart';
import 'profile_controller.dart';

class SettingsView extends GetView<ProfileController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: Text('Pengaturan', style: AppTextStyles.title),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Selesai',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === PREFERENSI ===
            _buildSectionTitle('Preferensi'),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildSettingToggle(
                icon: Icons.notifications_rounded,
                iconColor: AppColors.secondary,
                title: 'Notifikasi',
                subtitle: 'Ingatkan check-in harian',
                value: controller.isNotificationActive,
                onChanged: controller.toggleNotification,
              ),
            ]),

            const SizedBox(height: 28),

            // === KEAMANAN ===
            _buildSectionTitle('Keamanan'),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildSettingToggle(
                icon: Icons.fingerprint_rounded,
                iconColor: AppColors.success,
                title: 'Kunci Aplikasi',
                subtitle: 'Gunakan Face ID / Fingerprint',
                value: controller.isBiometricActive,
                onChanged: controller.toggleBiometric,
              ),
            ]),

            const SizedBox(height: 28),

            // === ZONA BAHAYA ===
            _buildSectionTitle('Zona Bahaya'),
            const SizedBox(height: 12),
            _buildLogoutButton(),

            const SizedBox(height: 40),

            // Version
            Center(
              child: Text(
                'Chirax v1.0.0 ❤️',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.bodySmall.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return BouncyListTile(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSettingToggle({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          // Switch
          Obx(
            () => Switch(
              value: value.value,
              activeColor: AppColors.success,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Bouncy3DButton(
      onTap: () => controller.logout(),
      shadowColor: Colors.grey.shade300,
      shadowHeight: 4,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dangerRed, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.dangerRed, size: 22),
            const SizedBox(width: 8),
            Text(
              'KELUAR',
              style: AppTextStyles.button.copyWith(color: AppColors.dangerRed),
            ),
          ],
        ),
      ),
    );
  }
}
