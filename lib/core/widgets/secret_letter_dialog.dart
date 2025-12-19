import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_text_styles.dart';

/// SecretLetterDialog - Easter Egg widget yang muncul saat triple tap Pet
/// Visual style: Paper/Letter theme dengan efek "melayang"
class SecretLetterDialog extends StatelessWidget {
  /// Nama pengirim surat
  final String senderName;

  /// Isi surat (placeholder default jika tidak diisi)
  final String? letterContent;

  const SecretLetterDialog({
    super.key,
    this.senderName = 'Axel',
    this.letterContent,
  });

  /// Static method untuk menampilkan dialog dengan animasi zoom
  static void show({String senderName = 'Axel', String? letterContent}) {
    Get.dialog(
      SecretLetterDialog(senderName: senderName, letterContent: letterContent),
      barrierColor: Colors.black.withValues(alpha: 0.6),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 400),
      transitionCurve: Curves.elasticOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Default letter content jika tidak diisi
    final content =
        letterContent ??
        'Terima kasih sudah menemani hari-hariku. '
            'Aku senang kita bisa membangun kebiasaan baik ini bersama. '
            'Semangat terus ya jaga streak-nya!\n\n'
            'I love you 💕';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            // Paper White / Cream color
            color: const Color(0xFFFFFDD0),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            // Soft shadow - efek kertas melayang
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(4, 6),
                blurRadius: 12,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(8, 10),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: "Untuk Pasanganku,"
              Text(
                'Untuk Geaaa,',
                style: AppTextStyles.title.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.brown.shade800,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 24),

              // Body: Isi surat dengan style italic
              Text(
                content,
                style: AppTextStyles.body.copyWith(
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.brown.shade700,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 32),

              // Footer/Signature - Align Right
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '-- $senderName --',
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.brown.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Close hint
              Center(
                child: Text(
                  'Tap di luar untuk menutup',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.brown.shade400,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
