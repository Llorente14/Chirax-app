import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/chunky_button.dart';
import '../../core/widgets/chunky_input.dart';
import '../../core/widgets/juicy_loading.dart';
import '../../data/services/auth_service.dart';
import 'register_view.dart';

/// LoginView - Email/Password login screen
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Get.find<AuthService>();
    final user = await authService.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (user != null) {
      // Check auth status and navigate
      final route = await authService.checkAuthStatus();
      _navigateByRoute(route);
    }
  }

  void _navigateByRoute(String route) {
    switch (route) {
      case 'setup':
        Get.offAllNamed('/setup-profile');
        break;
      case 'pairing':
        Get.offAllNamed('/pairing');
        break;
      case 'dashboard':
        Get.offAllNamed('/dashboard');
        break;
      default:
        // Stay on login
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

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
                const SizedBox(height: 40),

                // Header
                Center(child: Text('👋', style: const TextStyle(fontSize: 64))),
                const SizedBox(height: 16),
                Text(
                  'Selamat Datang!',
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Masuk untuk melanjutkan',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Email Input
                ChunkyInput(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'contoh@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(
                    Icons.email_rounded,
                    color: AppColors.textSecondary,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password Input
                ChunkyInput(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  obscureText: _obscurePassword,
                  prefixIcon: Icon(
                    Icons.lock_rounded,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Login Button
                Obx(
                  () => authService.isLoading.value
                      ? const Center(child: JuicyLoading(size: 60))
                      : ChunkyButton(
                          text: 'MASUK',
                          icon: Icons.login_rounded,
                          onPressed: _handleLogin,
                          color: AppColors.primary,
                          shadowColor: AppColors.primaryShadow,
                        ),
                ),

                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.to(() => const RegisterView()),
                      child: Text(
                        'Daftar',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
