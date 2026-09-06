import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_map_placeholder.dart';
import '../../../data/models/ride_model.dart';
import '../../../providers/driver_provider.dart';

class DriverRideFlowScreen extends StatefulWidget {
  final VoidCallback? onRideCompleted;
  final VoidCallback? onDeclined;

  const DriverRideFlowScreen({
    super.key,
    this.onRideCompleted,
    this.onDeclined,
  });

  @override
  State<DriverRideFlowScreen> createState() => _DriverRideFlowScreenState();
}

class _DriverRideFlowScreenState extends State<DriverRideFlowScreen> {
  bool _cashReceived = false;

  /// Maps the active ride's status to a UI sheet state.
  String _stateFor(RideStatus status) {
    switch (status) {
      case RideStatus.arrived:   return 'arrived';
      case RideStatus.onTrip:    return 'onTrip';
      case RideStatus.completed: return 'completed';
      default:                   return 'pickup'; // accepted / arriving
    }
  }

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<DriverProvider>();
    final ride = driver.activeRide;

    // No active ride (e.g. just completed) — nothing to show.
    if (ride == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final state = _stateFor(ride.status);

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen map
          Positioned.fill(
            child: AppMapPlaceholder(isFullScreen: true, showRoute: true),
          ),

          // Navigation button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0, right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: AppColors.info.withOpacity(0.4),
                          blurRadius: 16, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text('Navigate', style: AppTextStyles.labelMd.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // State label top-left
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: state == 'onTrip' ? AppColors.success : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(_stateLabel(state),
                      style: AppTextStyles.labelSm.copyWith(color: AppColors.textDark)),
                ],
              ),
            ),
          ),

          // Bottom sheet
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _buildSheet(context, state, ride, driver),
            ),
          ),
        ],
      ),
    );
  }

  String _stateLabel(String state) {
    switch (state) {
      case 'onTrip': return 'On Trip';
      case 'arrived': return 'At Pickup';
      case 'completed': return 'Completed';
      default: return 'To Pickup';
    }
  }

  Widget _buildSheet(
      BuildContext context, String state, RideModel ride, DriverProvider driver) {
    switch (state) {
      case 'arrived':
        return _ArrivedSheet(
          key: const ValueKey('arrived'),
          ride: ride,
          onStartTrip: () => driver.startTrip(),
        );
      case 'onTrip':
        return _OnTripSheet(
          key: const ValueKey('onTrip'),
          ride: ride,
          onComplete: () => driver.completeRide(),
        );
      case 'completed':
        return _CompletedSheet(
          key: const ValueKey('completed'),
          ride: ride,
          cashReceived: _cashReceived,
          onCashReceived: () {
            setState(() => _cashReceived = true);
            Future.delayed(const Duration(milliseconds: 800), () {
              driver.finishRide();
              widget.onRideCompleted?.call();
            });
          },
        );
      default:
        return _ToPickupSheet(
          key: const ValueKey('pickup'),
          ride: ride,
          onArrived: () => driver.markArrived(),
        );
    }
  }
}

class _ToPickupSheet extends StatelessWidget {
  final RideModel ride;
  final VoidCallback onArrived;
  const _ToPickupSheet({super.key, required this.ride, required this.onArrived});

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('On the way to Pickup', style: AppTextStyles.h4),
                  const SizedBox(height: 4),
                  Text(ride.pickup.name,
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.primary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.electric_bike_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text('₹${ride.fare}',
                      style: AppTextStyles.h5.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _CustomerInfo(ride: ride),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _ActionChip(Icons.call_rounded, 'Call', AppColors.success, () {}),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionChip(Icons.message_rounded, 'Message', AppColors.info, () {}),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppGradientButton(
          label: 'Arrived at Pickup',
          onTap: onArrived,
          prefixIcon: Icons.location_on_rounded,
        ),
      ],
    );
  }
}

class _ArrivedSheet extends StatelessWidget {
  final RideModel ride;
  final VoidCallback onStartTrip;
  const _ArrivedSheet({super.key, required this.ride, required this.onStartTrip});

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      children: [
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
              const Icon(Icons.location_on_rounded, color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Text("You've reached the pickup point!",
                  style: AppTextStyles.h5.copyWith(color: AppColors.success)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _CustomerInfo(ride: ride),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.greyBg, borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.mapPickup, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(ride.pickup.name, style: AppTextStyles.bodyMd,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textLight),
              const SizedBox(width: 6),
              Expanded(
                child: Text(ride.drop.name, style: AppTextStyles.bodyMd,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppGradientButton(label: 'Start Trip', onTap: onStartTrip,
            prefixIcon: Icons.play_arrow_rounded),
      ],
    );
  }
}

class _OnTripSheet extends StatelessWidget {
  final RideModel ride;
  final VoidCallback onComplete;
  const _OnTripSheet({super.key, required this.ride, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Drop Location',
                        style: AppTextStyles.labelSm.copyWith(color: AppColors.success)),
                  ),
                  const SizedBox(height: 6),
                  Text(ride.drop.name, style: AppTextStyles.h4,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.navigation_rounded,
                        color: AppColors.info, size: 14),
                    const SizedBox(width: 4),
                    Text('Navigate', style: AppTextStyles.bodyMdOrange),
                  ]),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${ride.fare}', style: AppTextStyles.h2.copyWith(color: AppColors.success)),
                Text('Estimated Fare', style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        _CustomerInfo(ride: ride),
        const SizedBox(height: 14),
        AppGradientButton(
          label: 'End Trip',
          onTap: onComplete,
          gradient: AppColors.successGradient,
          prefixIcon: Icons.flag_rounded,
        ),
      ],
    );
  }
}

class _CompletedSheet extends StatelessWidget {
  final RideModel ride;
  final bool cashReceived;
  final VoidCallback onCashReceived;
  const _CompletedSheet({
    super.key, required this.ride, required this.cashReceived, required this.onCashReceived,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      children: [
        // Trip complete header
        Center(
          child: Column(
            children: [
              Container(
                width: 72, height: 72,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.successGradient),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 38),
              ),
              const SizedBox(height: 10),
              Text('Trip Completed!', style: AppTextStyles.h3),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Fare breakdown
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.greyBg, borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _FareRow('Total Fare', '₹${ride.fare}'),
              _FareRow('Your Earnings', '₹${ride.fare}', green: true),
              _FareRow('Cash Collected', '₹${ride.fare}'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Customer info + rating
        _CustomerInfo(ride: ride),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: AppColors.starColor, size: 16),
            const SizedBox(width: 4),
            Text('Rate Customer', style: AppTextStyles.bodyMd),
            const Spacer(),
            Row(
              children: List.generate(5, (i) => GestureDetector(
                child: Icon(
                  cashReceived && i < 5 ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.starColor, size: 20,
                ),
              )),
            ),
          ],
        ),
        const SizedBox(height: 14),

        AppGradientButton(
          label: cashReceived ? 'Cash Received ✓' : 'Cash Received',
          onTap: cashReceived ? null : onCashReceived,
          gradient: cashReceived ? AppColors.successGradient : AppColors.primaryGradient,
        ),
      ],
    );
  }
}

class _BaseSheet extends StatelessWidget {
  final List<Widget> children;
  const _BaseSheet({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _CustomerInfo extends StatelessWidget {
  final RideModel ride;
  const _CustomerInfo({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer', style: AppTextStyles.h5),
              Text('${ride.serviceType.label} · ${ride.paymentMethod}',
                  style: AppTextStyles.bodySm),
            ],
          ),
        ),
        Row(
          children: [
            _SmallAction(Icons.call_rounded, AppColors.success),
            const SizedBox(width: 8),
            _SmallAction(Icons.message_rounded, AppColors.info),
          ],
        ),
      ],
    );
  }
}

class _SmallAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _SmallAction(this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionChip(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.labelMd.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label, value;
  final bool green;
  const _FareRow(this.label, this.value, {this.green = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMd),
          Text(value, style: AppTextStyles.labelLg.copyWith(
            color: green ? AppColors.success : AppColors.textDark,
          )),
        ],
      ),
    );
  }
}
