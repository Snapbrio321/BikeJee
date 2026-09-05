import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class BikeJeeLogo extends StatelessWidget {
  final double size;
  final bool darkBg;
  final bool showTagline;

  const BikeJeeLogo({super.key, this.size = 1.0, this.darkBg = false, this.showTagline = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Green rounded square with white bike
        Container(
          width: 32 * size,
          height: 32 * size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.successGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(9 * size),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(Icons.electric_bike_rounded, color: Colors.white, size: 18 * size),
        ),
        SizedBox(width: 8 * size),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Bike',
                style: GoogleFonts.poppins(
                  fontSize: 20 * size,
                  fontWeight: FontWeight.w800,
                  color: darkBg ? Colors.white : AppColors.secondary,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Jee',
                style: GoogleFonts.poppins(
                  fontSize: 20 * size,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BikeJeeLogoCenter extends StatelessWidget {
  final double size;
  final bool darkBg;

  const BikeJeeLogoCenter({super.key, this.size = 1.0, this.darkBg = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72 * size,
          height: 72 * size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.successGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20 * size),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: Offset(0, 8 * size),
              ),
            ],
          ),
          child: Icon(Icons.electric_bike_rounded, color: Colors.white, size: 36 * size),
        ),
        SizedBox(height: 14 * size),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Bike',
                style: GoogleFonts.poppins(
                  fontSize: 30 * size,
                  fontWeight: FontWeight.w800,
                  color: darkBg ? Colors.white : AppColors.secondary,
                  letterSpacing: -1,
                ),
              ),
              TextSpan(
                text: 'Jee',
                style: GoogleFonts.poppins(
                  fontSize: 30 * size,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5 * size),
        Text(
          'Ride Fast. Deliver Smart.',
          style: GoogleFonts.poppins(
            fontSize: 12 * size,
            color: darkBg ? Colors.white54 : AppColors.textLight,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
