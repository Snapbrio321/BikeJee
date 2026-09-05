import 'package:flutter/material.dart';

/// BikeJee Premium Color System
/// Inspired by Uber/Rapido: Deep Navy + Electric Green + Clean Whites
/// Professional, modern, high-contrast, rider-app quality

class AppColors {
  // ── PRIMARY: Electric Emerald Green (Rapido-inspired) ────────────────────
  static const Color primary        = Color(0xFF00B14F); // WhatsApp/Rapido green
  static const Color primaryDark    = Color(0xFF008F3E);
  static const Color primaryLight   = Color(0xFF33C46F);
  static const Color primarySurface = Color(0xFFE8F9EF);

  // ── SECONDARY: Deep Navy (Uber-inspired) ─────────────────────────────────
  static const Color secondary      = Color(0xFF0A0F2E); // Ultra deep navy
  static const Color secondaryLight = Color(0xFF141A45);
  static const Color darkBg         = Color(0xFF0A0F2E);
  static const Color darkCard       = Color(0xFF141A45);
  static const Color darkMedium     = Color(0xFF1E2660);
  static const Color darkLight      = Color(0xFF2A3375);

  // ── STATUS ────────────────────────────────────────────────────────────────
  static const Color success        = Color(0xFF00B14F);
  static const Color successLight   = Color(0xFFE8F9EF);
  static const Color error          = Color(0xFFFF3B30);
  static const Color errorLight     = Color(0xFFFFEEED);
  static const Color warning        = Color(0xFFFF9500);
  static const Color warningLight   = Color(0xFFFFF4E5);
  static const Color info           = Color(0xFF007AFF);
  static const Color infoLight      = Color(0xFFE8F2FF);

  // ── ACCENTS ───────────────────────────────────────────────────────────────
  static const Color accentBlue     = Color(0xFF007AFF);
  static const Color accentOrange   = Color(0xFFFF6B35);
  static const Color accentPurple   = Color(0xFF8B5CF6);
  static const Color accentGreen    = Color(0xFF00B14F);

  // ── BACKGROUNDS ───────────────────────────────────────────────────────────
  static const Color background     = Color(0xFFF5F5F5);
  static const Color cardBg         = Color(0xFFFFFFFF);
  static const Color greyBg         = Color(0xFFF0F0F0);
  static const Color greyLight      = Color(0xFFF8F8F8);

  // ── TEXT ──────────────────────────────────────────────────────────────────
  static const Color textDark       = Color(0xFF0A0F2E);
  static const Color textMedium     = Color(0xFF4A4A6A);
  static const Color textLight      = Color(0xFF9A9AB5);
  static const Color textWhite      = Color(0xFFFFFFFF);

  // ── BORDERS ───────────────────────────────────────────────────────────────
  static const Color border         = Color(0xFFE8E8EE);
  static const Color divider        = Color(0xFFF2F2F7);

  // ── SERVICE CARD COLORS ───────────────────────────────────────────────────
  static const Color bikeCardBg     = Color(0xFFE8F9EF);
  static const Color autoCardBg     = Color(0xFFE8F2FF);
  static const Color parcelCardBg   = Color(0xFFF3F0FF);
  static const Color cabCardBg      = Color(0xFFFFF4E5);

  static const Color bikeIcon       = Color(0xFF00B14F);
  static const Color autoIcon       = Color(0xFF007AFF);
  static const Color parcelIcon     = Color(0xFF8B5CF6);
  static const Color cabIcon        = Color(0xFFFF9500);

  // ── MAP ───────────────────────────────────────────────────────────────────
  static const Color mapRoute       = Color(0xFF00B14F);
  static const Color mapPickup      = Color(0xFF00B14F);
  static const Color mapDrop        = Color(0xFFFF3B30);

  // ── MISC ──────────────────────────────────────────────────────────────────
  static const Color starColor      = Color(0xFFFF9500);
  static const Color navActive      = Color(0xFF00B14F);
  static const Color navInactive    = Color(0xFF9A9AB5);

  // ── GRADIENTS ─────────────────────────────────────────────────────────────
  // Primary CTA: deep navy → vibrant green (premium feel)
  static const List<Color> primaryGradient = [
    Color(0xFF0A0F2E),
    Color(0xFF00B14F),
  ];
  // Hero / dark screens: deep navy gradient
  static const List<Color> heroGradient = [
    Color(0xFF0A0F2E),
    Color(0xFF141A45),
  ];
  static const List<Color> darkGradient = [
    Color(0xFF0A0F2E),
    Color(0xFF141A45),
  ];
  // Success
  static const List<Color> successGradient = [
    Color(0xFF00B14F),
    Color(0xFF33C46F),
  ];
  // Accent gradient
  static const List<Color> accentGradient = [
    Color(0xFFFF6B35),
    Color(0xFFFF9500),
  ];
  // Wallet / earnings: dark navy to green
  static const List<Color> walletGradient = [
    Color(0xFF0A0F2E),
    Color(0xFF00B14F),
  ];
  // Driver gradient
  static const List<Color> driverGradient = [
    Color(0xFF0A0F2E),
    Color(0xFF141A45),
  ];
  // CTA button: same as primary
  static const List<Color> ctaGradient = [
    Color(0xFF0A0F2E),
    Color(0xFF00B14F),
  ];
}
