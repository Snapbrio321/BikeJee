import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_map_placeholder.dart';

class ParcelTrackingScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ParcelTrackingScreen({super.key, this.onBack});

  @override
  State<ParcelTrackingScreen> createState() => _ParcelTrackingScreenState();
}

class _ParcelTrackingScreenState extends State<ParcelTrackingScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 1; // 0=Picked, 1=On way, 2=Delivered
  late AnimationController _pulseCtrl;
  Timer? _stepTimer;

  final _steps = [
    _TrackStep('Order Placed', 'Parcel picked up from sender', Icons.check_circle_rounded, true),
    _TrackStep('On the Way', 'Arriving in 10 min', Icons.electric_bike_rounded, false),
    _TrackStep('Delivered', 'Parcel will be delivered soon', Icons.home_rounded, false),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Simulate delivery progress
    _stepTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted && _currentStep < _steps.length - 1) {
        setState(() {
          _steps[_currentStep] = _TrackStep(
            _steps[_currentStep].label,
            _steps[_currentStep].sublabel,
            _steps[_currentStep].icon,
            true,
          );
          _currentStep++;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _stepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Full map
          Positioned.fill(
            child: AppMapPlaceholder(isFullScreen: true, showRoute: true),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: widget.onBack,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8)],
                ),
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 20),
              ),
            ),
          ),

          // ETA badge (center of map)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Transform.scale(
                scale: 0.97 + _pulseCtrl.value * 0.06,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12, offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 5),
                      Text('10 min', style: AppTextStyles.labelMd.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom sheet
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: AppColors.border, borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Parcel is on the way', style: AppTextStyles.h3),
                              const SizedBox(height: 4),
                              Text(
                                'Arriving in 10 min',
                                style: AppTextStyles.bodyMd.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Text('#BJ2024',
                              style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Parcel details card
                    AppCard(
                      color: AppColors.greyBg,
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.inventory_2_rounded,
                                color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Parcel Details', style: AppTextStyles.h5),
                                Text('Document / Paper · Upto 1kg',
                                    style: AppTextStyles.bodySm),
                              ],
                            ),
                          ),
                          Text('₹60', style: AppTextStyles.priceSmall.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Route
                    AppCard(
                      child: Column(
                        children: [
                          _RouteItem(
                            dot: AppColors.mapPickup,
                            label: 'Koramangala, Bangalore',
                            sublabel: 'Pickup',
                            isDot: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Row(
                              children: [
                                Container(
                                  width: 2, height: 20,
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                          _RouteItem(
                            dot: AppColors.mapDrop,
                            label: 'HSR Layout, Bangalore',
                            sublabel: 'Delivery',
                            isDot: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tracking steps
                    Text('Tracking', style: AppTextStyles.h4),
                    const SizedBox(height: 12),
                    ..._steps.asMap().entries.map((e) {
                      final i = e.key;
                      final step = e.value;
                      final isActive = i == _currentStep;
                      final isDone = step.done;
                      return _TrackingStepRow(
                        step: step,
                        isActive: isActive,
                        isDone: isDone,
                        isLast: i == _steps.length - 1,
                        pulseAnim: _pulseCtrl,
                      );
                    }),

                    const SizedBox(height: 16),

                    // Driver card
                    Text('Delivery Partner', style: AppTextStyles.h4),
                    const SizedBox(height: 10),
                    AppCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(Icons.person_rounded,
                                color: AppColors.primary, size: 26),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Dinesh Kumar', style: AppTextStyles.h5),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        color: AppColors.starColor, size: 13),
                                    const SizedBox(width: 3),
                                    Text('4.7', style: AppTextStyles.labelSm),
                                    const SizedBox(width: 6),
                                    Text('· KA 03 AB 4521',
                                        style: AppTextStyles.bodySm),
                                  ],
                                ),
                                Text('Your parcel is safe with us 😊',
                                    style: AppTextStyles.bodySm.copyWith(
                                        color: AppColors.success)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _CircleBtn(
                                icon: Icons.call_rounded,
                                color: AppColors.success,
                                onTap: () {},
                              ),
                              const SizedBox(width: 8),
                              _CircleBtn(
                                icon: Icons.message_rounded,
                                color: AppColors.info,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    AppGradientButton(
                      label: 'Share Tracking',
                      gradient: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                      prefixIcon: Icons.share_rounded,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteItem extends StatelessWidget {
  final Color dot;
  final String label, sublabel;
  final bool isDot;
  const _RouteItem({required this.dot, required this.label, required this.sublabel, required this.isDot});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        isDot
            ? Container(width: 12, height: 12, decoration: BoxDecoration(color: dot, shape: BoxShape.circle))
            : Container(width: 12, height: 12, decoration: BoxDecoration(color: dot, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sublabel, style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
              Text(label, style: AppTextStyles.bodyMd),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrackingStepRow extends StatelessWidget {
  final _TrackStep step;
  final bool isActive, isDone, isLast;
  final AnimationController pulseAnim;
  const _TrackingStepRow({
    required this.step, required this.isActive, required this.isDone,
    required this.isLast, required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    final Color dotColor = isDone
        ? AppColors.success
        : isActive
            ? AppColors.primary
            : AppColors.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline dot + line
          SizedBox(
            width: 32,
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: pulseAnim,
                  builder: (_, child) {
                    if (!isActive) return child!;
                    return Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dotColor.withOpacity(0.15 + pulseAnim.value * 0.15),
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.success : isActive ? AppColors.primary : AppColors.greyBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: dotColor, width: 2),
                    ),
                    child: isDone
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
                        : isActive
                            ? const SizedBox()
                            : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDone ? AppColors.success.withOpacity(0.4) : AppColors.border,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: AppTextStyles.h5.copyWith(
                      color: isDone
                          ? AppColors.success
                          : isActive
                              ? AppColors.primary
                              : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(step.sublabel, style: AppTextStyles.bodySm),
                ],
              ),
            ),
          ),
          if (isDone)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
            ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }
}

class _TrackStep {
  final String label, sublabel;
  final IconData icon;
  final bool done;
  const _TrackStep(this.label, this.sublabel, this.icon, this.done);
}
