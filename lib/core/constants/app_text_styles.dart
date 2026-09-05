import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings
  static TextStyle h1 = GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textDark);
  static TextStyle h2 = GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark);
  static TextStyle h3 = GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark);
  static TextStyle h4 = GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark);
  static TextStyle h5 = GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark);

  // Body
  static TextStyle bodyLg = GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textDark);
  static TextStyle bodyMd = GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textMedium);
  static TextStyle bodySm = GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textLight);

  // Labels
  static TextStyle labelLg = GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark);
  static TextStyle labelMd = GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMedium);
  static TextStyle labelSm = GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textLight);

  // Price
  static TextStyle price = GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark);
  static TextStyle priceSmall = GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark);

  // Buttons
  static TextStyle btnLg = GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);
  static TextStyle btnMd = GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white);

  // White variants
  static TextStyle h1White = h1.copyWith(color: Colors.white);
  static TextStyle h2White = h2.copyWith(color: Colors.white);
  static TextStyle h3White = h3.copyWith(color: Colors.white);
  static TextStyle h4White = h4.copyWith(color: Colors.white);
  static TextStyle h5White = h5.copyWith(color: Colors.white);
  static TextStyle bodyLgWhite = bodyLg.copyWith(color: Colors.white);
  static TextStyle bodyMdWhite = bodyMd.copyWith(color: Colors.white);
  static TextStyle bodySmWhite = bodySm.copyWith(color: Colors.white.withOpacity(0.7));

  // Primary (green) variants
  static TextStyle h4Orange = h4.copyWith(color: AppColors.primary);
  static TextStyle bodyMdOrange = bodyMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600);

  // Success
  static TextStyle bodyMdGreen = bodyMd.copyWith(color: AppColors.success);
  static TextStyle labelMdGreen = labelMd.copyWith(color: AppColors.success);

  // Caption
  static TextStyle caption = GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textLight, letterSpacing: 0.2);
}
