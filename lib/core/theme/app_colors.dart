import 'package:flutter/material.dart';

class AppColors {
  // --- PALET DARI GAMBAR ANDA ---
  static const Color lightPink = Color(
    0xFFFFAADE,
  ); // Pink muda (untuk background/hiasan)
  static const Color hotPink = Color(0xFFF399D1); // Pink utama (Primary)
  static const Color darkSlate = Color(0xFF37464F); // Warna Teks Utama
  static const Color deepNavy = Color(0xFF131F24); // Warna Outline/Shadow gelap
  static const Color offWhite = Color(
    0xFFF1F7FB,
  ); // Background App (Soft Blue-White)
  static const Color brightBlue = Color(
    0xFF1899D6,
  ); // Warna Sekunder (Secondary)

  // --- WARNA TAMBAHAN (Wajib untuk UI) ---
  // Hijau Duolingo (Success/Correct)
  static const Color successGreen = Color(0xFF58CC02);

  // Merah (Error/Danger)
  static const Color dangerRed = Color(0xFFFF4B4B);

  // --- LOGIKA WARNA 3D (Main Color + Shadow Color) ---
  // Rumus style Duolingo: Warna Tombol & Warna "Bawah" (Shadow) yang lebih tua

  // 1. Primary (PINK)
  static const Color primary = hotPink;
  static const Color primaryShadow = Color(
    0xFFC870A6,
  ); // Versi gelap dari hotPink

  // 2. Secondary (BLUE)
  static const Color secondary = brightBlue;
  static const Color secondaryShadow = Color(
    0xFF11709E,
  ); // Versi gelap dari brightBlue

  // 3. Success (GREEN)
  static const Color success = successGreen;
  static const Color successShadow = Color(0xFF46A302);

  // 4. Neutral (WHITE/GREY BUTTONS)
  static const Color neutral = Colors.white;
  static const Color neutralShadow = Color(0xFFE5E5E5);

  // Text Colors
  static const Color textPrimary = darkSlate;
  static const Color textSecondary = Color(0xFF778ca3); // Abu-abu medium

  // --- MONEY PALETTE (untuk preset buttons) ---
  static const Color moneyOrange = Color(0xFFFF9F1C); // 5k
  static const Color moneyPurple = Color(0xFF9B5DE5); // 10k
  static const Color moneyCyan = Color(0xFF00F5D4); // 20k
  static const Color moneyBlue = Color(0xFF00BBF9); // 50k
  static const Color moneyPink = Color(0xFFF15BB5); // 100k
}
