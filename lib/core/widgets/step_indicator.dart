import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> labels;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector
          final stepIndex = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: stepIndex < currentStep ? AppColors.primary : AppColors.border,
            ),
          );
        }
        // Step circle
        final stepIndex = i ~/ 2;
        final isDone = stepIndex < currentStep;
        final isActive = stepIndex == currentStep;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.primary
                    : isActive
                        ? AppColors.primary
                        : AppColors.border,
                shape: BoxShape.circle,
                border: isActive
                    ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 3)
                    : null,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                    : Text(
                        '${stepIndex + 1}',
                        style: AppTextStyles.labelSm.copyWith(
                          color: isActive ? Colors.white : AppColors.textLight,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              labels[stepIndex],
              style: AppTextStyles.caption.copyWith(
                color: isDone || isActive ? AppColors.primary : AppColors.textLight,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class RouteTimeline extends StatelessWidget {
  final String pickup;
  final String drop;
  final List<String> stops;

  const RouteTimeline({
    super.key,
    required this.pickup,
    required this.drop,
    this.stops = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TimelineItem(
          label: pickup,
          dotColor: AppColors.mapPickup,
          isFirst: true,
        ),
        ...stops.map((stop) => _TimelineItem(
              label: stop,
              dotColor: AppColors.primary,
            )),
        _TimelineItem(
          label: drop,
          dotColor: AppColors.mapDrop,
          isLast: true,
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String label;
  final Color dotColor;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.label,
    required this.dotColor,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                if (!isFirst) Expanded(child: Container(width: 2, color: AppColors.border)),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: AppColors.border)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(label, style: AppTextStyles.bodyMd),
            ),
          ),
        ],
      ),
    );
  }
}
