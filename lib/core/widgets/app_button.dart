import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final bool loading;
  final bool disabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double? width;
  final double height;
  final double borderRadius;
  final Color? customColor;
  final TextStyle? textStyle;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.disabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height = 52,
    this.borderRadius = 12,
    this.customColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = disabled || loading;

    Color bgColor;
    Color fgColor;
    Border? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = customColor ?? AppColors.primary;
        fgColor = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bgColor = customColor ?? AppColors.secondary;
        fgColor = Colors.white;
        break;
      case AppButtonVariant.outline:
        bgColor = Colors.transparent;
        fgColor = customColor ?? AppColors.primary;
        border = Border.all(color: customColor ?? AppColors.primary, width: 1.5);
        break;
      case AppButtonVariant.ghost:
        bgColor = (customColor ?? AppColors.primary).withOpacity(0.1);
        fgColor = customColor ?? AppColors.primary;
        break;
      case AppButtonVariant.danger:
        bgColor = AppColors.error;
        fgColor = Colors.white;
        break;
    }

    if (isDisabled) {
      bgColor = AppColors.border;
      fgColor = AppColors.textLight;
    }

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
          boxShadow: (variant == AppButtonVariant.primary && !isDisabled)
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fgColor,
                ),
              ),
            ] else ...[
              if (prefixIcon != null) ...[
                Icon(prefixIcon, color: fgColor, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: (textStyle ?? AppTextStyles.btnLg).copyWith(color: fgColor),
              ),
              if (suffixIcon != null) ...[
                const SizedBox(width: 8),
                Icon(suffixIcon, color: fgColor, size: 18),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class AppGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final List<Color> gradient;
  final double height;
  final double borderRadius;
  final IconData? prefixIcon;

  const AppGradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.gradient = AppColors.primaryGradient,
    this.height = 52,
    this.borderRadius = 12,
    this.prefixIcon,
  });

  // All gradients now use white text (no more yellow background)
  bool get _isDarkText => false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon,
                  color: _isDarkText ? AppColors.secondary : Colors.white,
                  size: 18),
              const SizedBox(width: 8),
            ],
            Text(label,
                style: AppTextStyles.btnLg.copyWith(
                  color: _isDarkText ? AppColors.secondary : Colors.white,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    );
  }
}
