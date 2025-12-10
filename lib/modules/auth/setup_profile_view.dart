import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/chunky_button.dart';
import '../../core/widgets/chunky_input.dart';
import '../../core/widgets/juicy_loading.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/database_service.dart';
import 'pairing_view.dart';

/// SetupProfileView - Profile setup after registration
class SetupProfileView extends StatefulWidget {
  const SetupProfileView({super.key});

  @override
  State<SetupProfileView> createState() => _SetupProfileViewState();
}

class _SetupProfileViewState extends State<SetupProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  DateTime? _birthday;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
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
      setState(() => _birthday = picked);
    }
  }

  String _formatBirthday() {
    if (_birthday == null) return 'Pilih tanggal';
    return '${_birthday!.day}/${_birthday!.month}/${_birthday!.year}';
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthday == null) {
      Get.snackbar('Error', 'Pilih tanggal lahir');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Get.find<AuthService>();
      final dbService = Get.find<DatabaseService>();

      final uid = authService.userId;
      if (uid == null) {
        Get.snackbar('Error', 'User tidak ditemukan');
        return;
      }

      // Format username with @
      String username = _usernameController.text.trim();
      if (!username.startsWith('@')) {
        username = '@$username';
      }

      final success = await dbService.updateUserProfile(
        uid: uid,
        name: _nameController.text.trim(),
        username: username,
        birthday: _birthday!,
      );

      if (success) {
        // Reload user model
        await authService.loadUserModel();
        // Navigate to pairing
        Get.offAll(() => const PairingView());
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Progress indicator
                Row(
                  children: [
                    _buildProgressDot(true, 'Akun'),
                    Expanded(child: _buildProgressLine(true)),
                    _buildProgressDot(true, 'Profil'),
                    Expanded(child: _buildProgressLine(false)),
                    _buildProgressDot(false, 'Pairing'),
                  ],
                ),

                const SizedBox(height: 40),

                // Header
                Center(child: Text('✨', style: const TextStyle(fontSize: 64))),
                const SizedBox(height: 16),
                Text(
                  'Siapa Kamu?',
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Lengkapi profilmu untuk melanjutkan',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Name Input
                ChunkyInput(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan namamu',
                  prefixIcon: Icon(
                    Icons.person_rounded,
                    color: AppColors.textSecondary,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Username Input
                ChunkyInput(
                  controller: _usernameController,
                  label: 'Username',
                  hint: '@namaunik',
                  prefixIcon: Icon(
                    Icons.alternate_email_rounded,
                    color: AppColors.textSecondary,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    if (value.contains(' ')) {
                      return 'Username tidak boleh mengandung spasi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Birthday Picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal Lahir',
                      style: AppTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickBirthday,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.neutralShadow,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neutralShadow,
                              offset: const Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cake_rounded,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _formatBirthday(),
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _birthday == null
                                      ? AppColors.textSecondary.withValues(
                                          alpha: 0.5,
                                        )
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Submit Button
                _isLoading
                    ? const Center(child: JuicyLoading(size: 60))
                    : ChunkyButton(
                        text: 'LANJUT KE PAIRING',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _handleSaveProfile,
                        color: AppColors.secondary,
                        shadowColor: AppColors.secondaryShadow,
                      ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDot(bool active, String label) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.grey.shade300,
            shape: BoxShape.circle,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.primaryShadow,
                      offset: const Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: active
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 11,
            color: active ? AppColors.primary : AppColors.textSecondary,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool active) {
    return Container(
      height: 4,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
