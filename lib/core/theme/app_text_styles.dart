import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App Text Styles menggunakan Google Fonts Nunito
/// Style Duolingo: Bold, Friendly, Rounded
class AppTextStyles {
  // Headline - Judul paling besar (untuk streak, welcome)
  static TextStyle headline = GoogleFonts.nunito(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Title - Judul section
  static TextStyle title = GoogleFonts.nunito(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Subtitle - Sub judul
  static TextStyle subtitle = GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body - Teks biasa
  static TextStyle body = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Body Small - Teks kecil
  static TextStyle bodySmall = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Button - Text di dalam tombol
  static TextStyle button = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.0,
    color: Colors.white,
  );

  // Caption - Teks sangat kecil
  static TextStyle caption = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Streak - Khusus untuk angka streak besar
  static TextStyle streak = GoogleFonts.nunito(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
    height: 1.0,
  );
}
