import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pinput/pinput.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'chunky_button.dart';

/// KaitoProtectionDialog - Security dialog for unpair/relationship reset
/// Uses Kaito Kid trivia question (1412) as security verification
class KaitoProtectionDialog extends StatefulWidget {
  const KaitoProtectionDialog({super.key});

  @override
  State<KaitoProtectionDialog> createState() => _KaitoProtectionDialogState();
}

class _KaitoProtectionDialogState extends State<KaitoProtectionDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  bool _isCorrect = false;
  bool _hasError = false;
  bool _isKeyboardVisible = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // The magic number - Kaito Kid's signature
  static const String _correctAnswer = '1412';

  @override
  void initState() {
    super.initState();
    // Shake animation for wrong answer
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Listen for focus changes to detect keyboard visibility
    _pinFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isKeyboardVisible = _pinFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _pinFocusNode.removeListener(_onFocusChange);
    _pinController.dispose();
    _pinFocusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onPinChanged(String value) {
    setState(() {
      _hasError = false;
    });

    if (value.length == 4) {
      if (value == _correctAnswer) {
        setState(() {
          _isCorrect = true;
          _hasError = false;
        });
        HapticFeedback.lightImpact();
        // Unfocus to hide keyboard after correct answer
        _pinFocusNode.unfocus();
      } else {
        setState(() {
          _isCorrect = false;
          _hasError = true;
        });
        HapticFeedback.heavyImpact();
        _shakeController.forward(from: 0);
      }
    } else {
      setState(() {
        _isCorrect = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: _isKeyboardVisible ? 20 : 40,
      ),
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          final shakeOffset = _hasError
              ? 10 * (1 - _shakeAnimation.value) * _shakeDirection()
              : 0.0;
          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: child,
          );
        },
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 360),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.dangerRed, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dangerRed.withValues(alpha: 0.3),
                  offset: const Offset(0, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: _isKeyboardVisible ? 16 : 28),

                // === HEADER ICON (hidden when keyboard visible) ===
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _isKeyboardVisible
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.dangerRed.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.dangerRed,
                            width: 3,
                          ),
                        ),
                        child: const Center(
                          child: PhosphorIcon(
                            PhosphorIconsFill.shieldWarning,
                            size: 40,
                            color: AppColors.dangerRed,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Security Protocol',
                        style: AppTextStyles.headline.copyWith(
                          fontSize: 22,
                          color: AppColors.dangerRed,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Untuk mereset hubungan, jawab pertanyaan keamanan ini:',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                  secondChild: const SizedBox.shrink(),
                ),

                // === TRIVIA QUESTION ===
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: EdgeInsets.all(_isKeyboardVisible ? 12 : 16),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.dangerRed.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (!_isKeyboardVisible) ...[
                        const PhosphorIcon(
                          PhosphorIconsFill.question,
                          size: 28,
                          color: AppColors.dangerRed,
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        'Apa angka yang berhubungan dengan Kaito Kid?',
                        style: AppTextStyles.subtitle.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: _isKeyboardVisible ? 14 : 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: _isKeyboardVisible ? 16 : 24),

                // === PIN INPUT ===
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Pinput(
                    controller: _pinController,
                    focusNode: _pinFocusNode,
                    length: 4,
                    keyboardType: TextInputType.number,
                    onChanged: _onPinChanged,
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    defaultPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: AppTextStyles.headline.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: AppTextStyles.headline.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.dangerRed,
                          width: 3,
                        ),
                      ),
                    ),
                    errorPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: AppTextStyles.headline.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dangerRed,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.dangerRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.dangerRed,
                          width: 3,
                        ),
                      ),
                    ),
                    submittedPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: AppTextStyles.headline.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _isCorrect
                            ? AppColors.success
                            : (_hasError
                                  ? AppColors.dangerRed
                                  : AppColors.textPrimary),
                      ),
                      decoration: BoxDecoration(
                        color: _isCorrect
                            ? AppColors.success.withValues(alpha: 0.1)
                            : (_hasError
                                  ? AppColors.dangerRed.withValues(alpha: 0.1)
                                  : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isCorrect
                              ? AppColors.success
                              : (_hasError
                                    ? AppColors.dangerRed
                                    : Colors.grey.shade300),
                          width: _isCorrect || _hasError ? 3 : 2,
                        ),
                      ),
                    ),
                  ),
                ),

                // === ERROR/SUCCESS MESSAGE ===
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _hasError
                      ? Text(
                          'Jawaban salah! Coba lagi.',
                          key: const ValueKey('error'),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.dangerRed,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : _isCorrect
                      ? Text(
                          'Benar! Kamu bisa melanjutkan.',
                          key: const ValueKey('success'),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : const SizedBox(height: 14, key: ValueKey('empty')),
                ),
                SizedBox(height: _isKeyboardVisible ? 12 : 20),

                // === ACTION BUTTONS ===
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    _isKeyboardVisible ? 16 : 24,
                  ),
                  child: Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.back(result: false),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  offset: const Offset(0, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Batal',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Confirm Button
                      Expanded(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isCorrect ? 1.0 : 0.5,
                          child: IgnorePointer(
                            ignoring: !_isCorrect,
                            child: ChunkyButton(
                              text: 'Putuskan',
                              onPressed: () => Get.back(result: true),
                              color: AppColors.dangerRed,
                              shadowColor: const Color(0xFFCC3D3D),
                              height: 52,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Calculate shake direction based on animation progress
  double _shakeDirection() {
    final progress = _shakeAnimation.value;
    // Creates a damped oscillation effect
    return (progress * 10).floor() % 2 == 0 ? 1.0 : -1.0;
  }
}
