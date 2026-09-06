import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typography. Uses Plus Jakarta Sans — a modern, highly legible
/// geometric sans that reads clean and premium on both mobile and web.
/// Weights are deliberately heavier and colors higher-contrast than a typical
/// default so text stays crisp and readable (thin fonts render poorly on web).
class AppTextStyles {
  // Headings — bold, tight, confident
  static TextStyle h1 = GoogleFonts.plusJakartaSans(
      fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.5, height: 1.2);
  static TextStyle h2 = GoogleFonts.plusJakartaSans(
      fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.3, height: 1.2);
  static TextStyle h3 = GoogleFonts.plusJakartaSans(
      fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark, letterSpacing: -0.2, height: 1.25);
  static TextStyle h4 = GoogleFonts.plusJakartaSans(
      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.3);
  static TextStyle h5 = GoogleFonts.plusJakartaSans(
      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.3);

  // Body — medium weight + darker colors for strong readability
  static TextStyle bodyLg = GoogleFonts.plusJakartaSans(
      fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textDark, height: 1.45);
  static TextStyle bodyMd = GoogleFonts.plusJakartaSans(
      fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textMedium, height: 1.4);
  static TextStyle bodySm = GoogleFonts.plusJakartaSans(
      fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.textMedium, height: 1.35);

  // Labels
  static TextStyle labelLg = GoogleFonts.plusJakartaSans(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark);
  static TextStyle labelMd = GoogleFonts.plusJakartaSans(
      fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textMedium);
  static TextStyle labelSm = GoogleFonts.plusJakartaSans(
      fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLight);

  // Price
  static TextStyle price = GoogleFonts.plusJakartaSans(
      fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.3);
  static TextStyle priceSmall = GoogleFonts.plusJakartaSans(
      fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark);

  // Buttons
  static TextStyle btnLg = GoogleFonts.plusJakartaSans(
      fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.2);
  static TextStyle btnMd = GoogleFonts.plusJakartaSans(
      fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.2);

  // White variants
  static TextStyle h1White = h1.copyWith(color: Colors.white);
  static TextStyle h2White = h2.copyWith(color: Colors.white);
  static TextStyle h3White = h3.copyWith(color: Colors.white);
  static TextStyle h4White = h4.copyWith(color: Colors.white);
  static TextStyle h5White = h5.copyWith(color: Colors.white);
  static TextStyle bodyLgWhite = bodyLg.copyWith(color: Colors.white);
  static TextStyle bodyMdWhite = bodyMd.copyWith(color: Colors.white);
  static TextStyle bodySmWhite = bodySm.copyWith(color: Colors.white.withOpacity(0.8));

  // Primary (green) variants
  static TextStyle h4Orange = h4.copyWith(color: AppColors.primary);
  static TextStyle bodyMdOrange = bodyMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700);

  // Success
  static TextStyle bodyMdGreen = bodyMd.copyWith(color: AppColors.success);
  static TextStyle labelMdGreen = labelMd.copyWith(color: AppColors.success);

  // Caption
  static TextStyle caption = GoogleFonts.plusJakartaSans(
      fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textLight, letterSpacing: 0.1);
}
