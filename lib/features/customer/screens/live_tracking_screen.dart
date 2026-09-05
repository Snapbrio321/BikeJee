import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_map_placeholder.dart';
import '../../../providers/ride_provider.dart';
import '../../../data/models/ride_model.dart';

class LiveTrackingScreen extends StatefulWidget {
  final VoidCallback? onRideCompleted;
  final VoidCallback? onCancelled;

  const LiveTrackingScreen({
    super.key,
    this.onRideCompleted,
    this.onCancelled,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _arrivingCtrl;
  late Animation<double> _arrivingAnim;

  // Driven by RideProvider each build
  String _status = 'on_way';
  int _etaMinutes = 3;
  bool _completedHandled = false;

  @override
  void initState() {
    super.initState();
    _arrivingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _arrivingAnim =
        CurvedAnimation(parent: _arrivingCtrl, curve: Curves.easeInOut);

    // Join the live tracking room (real backend) — mock auto-runs already.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // provider already tracking from bookRide(); nothing else needed
    });
  }

  @override
  void dispose() {
    _arrivingCtrl.dispose();
    super.dispose();
  }

  // Map the provider's RideStatus to this screen's visual state.
  String _statusFor(RideStatus s) {
    switch (s) {
      case RideStatus.arrived:
      case RideStatus.arriving:
        return 'arriving';
      case RideStatus.completed:
        return 'completed';
      default:
        return 'on_way';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sync visual state from the live RideProvider
    final ride = context.watch<RideProvider>();
    _status = _statusFor(ride.rideStatus);
    _etaMinutes = ride.etaMinutes ?? _etaMinutes;

    // Auto-navigate to Ride Completed when the trip finishes
    if (ride.rideStatus == RideStatus.completed && !_completedHandled) {
      _completedHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onRideCompleted?.call();
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen map
          Positioned.fill(
            child: AppMapPlaceholder(isFullScreen: true, showRoute: true),
          ),

          // Top overlay: route info
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _RouteChip(
                  icon: Icons.radio_button_checked_rounded,
                  label: 'Koramangala',
                  color: AppColors.mapPickup,
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.mapPickup, AppColors.mapDrop],
                      ),
                    ),
                  ),
                ),
                _RouteChip(
                  icon: Icons.location_on_rounded,
                  label: 'HSR Layout',
                  color: AppColors.mapDrop,
                ),
              ],
            ),
          ),

          // Status pill (center-top of map)
          Positioned(
            top: MediaQuery.of(context).padding.top + 68,
            left: 0, right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _arrivingAnim,
                builder: (_, __) => Transform.scale(
                  scale: _status == 'arriving'
                      ? 0.97 + _arrivingAnim.value * 0.06
                      : 1.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: _statusColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _statusColor.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(_statusText, style: AppTextStyles.labelMd.copyWith(color: Colors.white)),
                      ],
                    ),
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                  ),

                  // ETA row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_mainStatusText, style: AppTextStyles.h3),
                            const SizedBox(height: 3),
                            Text(
                              _status == 'completed'
                                  ? 'You have arrived at your destination!'
                                  : '$_etaMinutes min away',
                              style: _status == 'completed'
                                  ? AppTextStyles.bodyMd.copyWith(color: AppColors.success)
                                  : AppTextStyles.bodyMd,
                            ),
                          ],
                        ),
                      ),
                      if (_status != 'completed')
                        AnimatedBuilder(
                          animation: _arrivingAnim,
                          builder: (_, __) => Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08 + _arrivingAnim.value * 0.04),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$_etaMinutes',
                                  style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                                ),
                                Text('min', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Driver card
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Arjun Kumar', style: AppTextStyles.h5),
                            Text('KA 03 JE 1234 · Honda Active',
                                style: AppTextStyles.bodySm),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _CircleAction(icon: Icons.call_rounded, color: AppColors.success, onTap: () {}),
                          const SizedBox(width: 8),
                          _CircleAction(icon: Icons.message_rounded, color: AppColors.info, onTap: () {}),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Trip info row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.greyBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _TripStat(label: 'Distance', value: '4.2 km'),
                        _Divider(),
                        _TripStat(label: 'Fare', value: '₹45'),
                        _Divider(),
                        _TripStat(label: 'Payment', value: 'Cash'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_status == 'completed')
                    AppGradientButton(label: 'Ride Completed', onTap: widget.onRideCompleted)
                  else
                    AppButton(
                      label: 'Cancel Ride',
                      variant: AppButtonVariant.outline,
                      onTap: widget.onCancelled,
                      height: 48,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color get _statusColor {
    switch (_status) {
      case 'arriving': return AppColors.warning;
      case 'completed': return AppColors.success;
      default: return AppColors.primary;
    }
  }

  IconData get _statusIcon {
    switch (_status) {
      case 'arriving': return Icons.near_me_rounded;
      case 'completed': return Icons.check_circle_rounded;
      default: return Icons.electric_bike_rounded;
    }
  }

  String get _statusText {
    switch (_status) {
      case 'arriving': return 'Driver is arriving';
      case 'completed': return 'Reached';
      default: return 'Your ride is on the way';
    }
  }

  String get _mainStatusText {
    switch (_status) {
      case 'arriving': return 'Driver Arriving!';
      case 'completed': return 'You\'ve Arrived!';
      default: return 'On the Way';
    }
  }
}

class _RouteChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _RouteChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.labelSm),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CircleAction({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _TripStat extends StatelessWidget {
  final String label, value;
  const _TripStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h5),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: AppColors.border);
  }
}
