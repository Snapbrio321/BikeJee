import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_map_placeholder.dart';
import '../../../providers/ride_provider.dart';
import '../../../data/models/ride_model.dart';

class FindingDriverScreen extends StatefulWidget {
  final VoidCallback? onDriverFound;
  final VoidCallback? onCancelled;

  const FindingDriverScreen({
    super.key,
    this.onDriverFound,
    this.onCancelled,
  });

  @override
  State<FindingDriverScreen> createState() => _FindingDriverScreenState();
}

class _FindingDriverScreenState extends State<FindingDriverScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _rotateCtrl;
  late Animation<double> _pulse1;
  late Animation<double> _pulse2;
  late Animation<double> _pulse3;
  late Animation<double> _rotate;

  Timer? _foundTimer;
  bool _found = false;
  int _dots = 1;
  Timer? _dotsTimer;

  final _driver = _FoundDriver(
    name: 'Arjun Kumar',
    vehicle: 'Honda Activa',
    plate: 'KA 03 JE 1234',
    rating: 4.8,
    distance: '2 min away',
    phone: '+91 98765-43210',
  );

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _pulse1 = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _pulse2 = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: const Interval(0.2, 0.8, curve: Curves.easeOut)),
    );
    _pulse3 = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );
    _rotate = _rotateCtrl;

    _dotsTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _dots = (_dots % 3) + 1);
    });

    // Watch the RideProvider — driver matched when status leaves 'searching'
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ride = context.read<RideProvider>();
      // If already matched (e.g. fast mock), reflect immediately
      if (ride.matchedDriver != null && !_found) {
        setState(() => _found = true);
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    _foundTimer?.cancel();
    _dotsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // React to live ride status from the provider
    final ride = context.watch<RideProvider>();
    final matched = ride.matchedDriver != null &&
        ride.rideStatus != RideStatus.searching;
    if (matched && !_found) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _found = true);
      });
    }
    // Auto-advance to tracking once driver is arriving/on-trip
    if (_found &&
        (ride.rideStatus == RideStatus.arriving ||
            ride.rideStatus == RideStatus.arrived ||
            ride.rideStatus == RideStatus.onTrip)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onDriverFound?.call();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Map background
          Positioned.fill(
            child: AppMapPlaceholder(isFullScreen: true, showRoute: true),
          ),

          // Dark overlay top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black45, Colors.transparent],
                ),
              ),
            ),
          ),

          // Top status bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('MG Road, Bangalore',
                          style: AppTextStyles.labelMd.copyWith(color: AppColors.textDark)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.mapDrop,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('HSR Layout',
                          style: AppTextStyles.labelMd.copyWith(color: AppColors.textDark)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Center radar animation (visible while searching)
          if (!_found)
            Center(
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rings
                      ...[_pulse3, _pulse2, _pulse1].map((anim) {
                        return Opacity(
                          opacity: (1 - anim.value).clamp(0, 1),
                          child: Container(
                            width: 200 * anim.value,
                            height: 200 * anim.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }),
                      // Rotating dashed ring
                      AnimatedBuilder(
                        animation: _rotate,
                        builder: (_, __) => Transform.rotate(
                          angle: _rotate.value * 2 * math.pi,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.4),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Center icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: AppColors.primaryGradient),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppColors.primary, blurRadius: 20, spreadRadius: -4),
                          ],
                        ),
                        child: const Icon(Icons.electric_bike_rounded,
                            color: Colors.white, size: 30),
                      ),
                    ],
                  );
                },
              ),
            ),

          // Bottom sheet
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1), end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
              child: _found
                  ? _DriverFoundSheet(
                      key: const ValueKey('found'),
                      driver: _driver,
                      onConfirm: widget.onDriverFound,
                      onCancel: widget.onCancelled,
                    )
                  : _SearchingSheet(
                      key: const ValueKey('searching'),
                      dots: _dots,
                      onCancel: widget.onCancelled,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchingSheet extends StatelessWidget {
  final int dots;
  final VoidCallback? onCancel;
  const _SearchingSheet({super.key, required this.dots, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.border, borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Finding you a driver${'.' * dots}',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we find the best driver for you',
            style: AppTextStyles.bodyMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              backgroundColor: AppColors.greyBg,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Cancel Ride',
            variant: AppButtonVariant.outline,
            onTap: onCancel,
            height: 48,
          ),
        ],
      ),
    );
  }
}

class _DriverFoundSheet extends StatelessWidget {
  final _FoundDriver driver;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  const _DriverFoundSheet({
    super.key,
    required this.driver,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
          ),

          // Driver found banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Text('Driver Found!', style: AppTextStyles.h5.copyWith(color: AppColors.success)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Driver info
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 34),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 18, height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.success, shape: BoxShape.circle,
                        border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.name, style: AppTextStyles.h4),
                    Text(driver.plate, style: AppTextStyles.bodyMd),
                    Text(driver.vehicle, style: AppTextStyles.bodySm),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.starColor, size: 14),
                        const SizedBox(width: 3),
                        Text(driver.rating.toString(),
                            style: AppTextStyles.labelMd.copyWith(color: AppColors.starColor)),
                        const SizedBox(width: 8),
                        Container(
                          width: 4, height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.textLight, shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Honda Active', style: AppTextStyles.bodySm),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(driver.distance,
                        style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  icon: Icons.call_rounded,
                  label: 'Call',
                  color: AppColors.success,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionBtn(
                  icon: Icons.message_rounded,
                  label: 'Message',
                  color: AppColors.info,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionBtn(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  color: AppColors.primary,
                  onTap: () {},
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Cancel Ride',
                  variant: AppButtonVariant.outline,
                  onTap: onCancel,
                  height: 48,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppGradientButton(
                  label: 'Track Ride',
                  onTap: onConfirm,
                  height: 48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.labelSm.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _FoundDriver {
  final String name, vehicle, plate, distance, phone;
  final double rating;
  const _FoundDriver({
    required this.name, required this.vehicle, required this.plate,
    required this.rating, required this.distance, required this.phone,
  });
}
