import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool showLabel;
  final Color? color;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 18,
    this.showLabel = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          double fill = (rating - i).clamp(0.0, 1.0);
          return Icon(
            fill >= 1 ? Icons.star_rounded
                : fill >= 0.5 ? Icons.star_half_rounded
                : Icons.star_border_rounded,
            color: color ?? AppColors.starColor,
            size: size,
          );
        }),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.labelMd,
          ),
        ],
      ],
    );
  }
}

class TappableRatingStars extends StatefulWidget {
  final double initial;
  final Function(double) onRated;

  const TappableRatingStars({
    super.key,
    this.initial = 0,
    required this.onRated,
  });

  @override
  State<TappableRatingStars> createState() => _TappableRatingStarsState();
}

class _TappableRatingStarsState extends State<TappableRatingStars> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return GestureDetector(
          onTap: () {
            setState(() => _rating = (i + 1).toDouble());
            widget.onRated(_rating);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              _rating > i ? Icons.star_rounded : Icons.star_border_rounded,
              color: AppColors.starColor,
              size: 36,
            ),
          ),
        );
      }),
    );
  }
}
