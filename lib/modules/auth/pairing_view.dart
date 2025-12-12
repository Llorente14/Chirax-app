import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/chunky_button.dart';
import '../../core/widgets/juicy_loading.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/database_service.dart';
import '../dashboard/dashboard_view.dart';

/// PairingView - Generate or enter pairing code
class PairingView extends StatefulWidget {
  const PairingView({super.key});

  @override
  State<PairingView> createState() => _PairingViewState();
}

class _PairingViewState extends State<PairingView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _codeController = TextEditingController();

  String? _generatedCode;
  bool _isGenerating = false;
  bool _isConnecting = false;
  StreamSubscription? _userSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    _userSubscription?.cancel();
    super.dispose();
  }

  /// Generate pairing code and listen for partner
  Future<void> _generateCode() async {
    setState(() => _isGenerating = true);

    try {
      final authService = Get.find<AuthService>();
      final dbService = Get.find<DatabaseService>();
      final uid = authService.userId;

      if (uid == null) return;

      // Generate code
      final code = await dbService.createPairingCode(uid);
      if (code != null) {
        setState(() => _generatedCode = code);

        // Listen for partner connection
        _userSubscription?.cancel();
        _userSubscription = dbService.streamUser(uid).listen((user) {
          if (user != null && user.isPaired) {
            // Partner connected! Navigate to dashboard
            Get.offAll(() => const DashboardView());
          }
        });
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  /// Connect with partner using code (RACE CONDITION FIX)
  /// Now uses transaction-based connection to prevent simultaneous pairing
  Future<void> _connectWithCode() async {
    final code = _codeController.text.toUpperCase();
    if (code.length != 6) {
      Get.snackbar('Error', 'Masukkan kode 6 karakter');
      return;
    }

    setState(() => _isConnecting = true);

    try {
      final authService = Get.find<AuthService>();
      final dbService = Get.find<DatabaseService>();
      final myUid = authService.userId;

      if (myUid == null) return;

      // Use new transactional method that handles everything atomically
      final success = await dbService.connectPartnersWithCode(myUid, code);

      if (success) {
        // Navigate to dashboard
        Get.offAll(() => const DashboardView());
      }
      // Error messages are handled inside connectPartnersWithCode
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildProgressDot(true, 'Akun'),
                  Expanded(child: _buildProgressLine(true)),
                  _buildProgressDot(true, 'Profil'),
                  Expanded(child: _buildProgressLine(true)),
                  _buildProgressDot(true, 'Pairing'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Header
            Text('💕', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              'Hubungkan dengan Pasangan',
              style: AppTextStyles.headline.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Tab Bar - Chunky Style
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      offset: const Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
                dividerHeight: 0,
                tabs: const [
                  Tab(text: 'Buat Kode'),
                  Tab(text: 'Masukkan Kode'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildGenerateTab(), _buildInputTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tab 1: Generate Code
  Widget _buildGenerateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (_generatedCode == null) ...[
            // Generate button
            Text(
              'Buat kode unik dan bagikan\nke pasanganmu',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _isGenerating
                ? const JuicyLoading(size: 60)
                : ChunkyButton(
                    text: 'BUAT KODE CINTA',
                    icon: Icons.favorite_rounded,
                    onPressed: _generateCode,
                    color: AppColors.primary,
                    shadowColor: AppColors.primaryShadow,
                  ),
          ] else ...[
            // Display generated code
            Text(
              'Kode Cinta Kamu:',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Code display with copy button
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: _generatedCode!));
                Get.snackbar(
                  '✅ Tersalin!',
                  'Kode sudah dicopy ke clipboard',
                  snackPosition: SnackPosition.TOP,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryShadow,
                      offset: const Offset(0, 6),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _generatedCode!,
                      style: AppTextStyles.headline.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.copy_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Bagikan kode ini ke pasanganmu\nMenunggu koneksi...',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Loading indicator
            const JuicyLoading(size: 50),
          ],
        ],
      ),
    );
  }

  /// Tab 2: Input Code
  Widget _buildInputTab() {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 60,
      textStyle: AppTextStyles.headline.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutralShadow, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralShadow,
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryShadow,
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Masukkan kode dari pasanganmu',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Pinput
          Pinput(
            controller: _codeController,
            length: 6,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            onCompleted: (_) => _connectWithCode(),
            textCapitalization: TextCapitalization.characters,
          ),

          const SizedBox(height: 32),

          // Connect button
          _isConnecting
              ? const JuicyLoading(size: 60)
              : ChunkyButton(
                  text: 'SAMBUNGKAN CINTA',
                  icon: Icons.link_rounded,
                  onPressed: _connectWithCode,
                  color: AppColors.success,
                  shadowColor: AppColors.successShadow,
                ),
        ],
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
