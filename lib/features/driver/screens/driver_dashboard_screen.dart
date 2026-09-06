import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/ride_model.dart';
import '../../../data/repositories/driver_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/driver_provider.dart';

class DriverDashboardScreen extends StatefulWidget {
  final VoidCallback? onGoOnline;
  final VoidCallback? onNewRide;
  final VoidCallback? onSubscribe;

  const DriverDashboardScreen({
    super.key,
    this.onGoOnline,
    this.onNewRide,
    this.onSubscribe,
  });

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    // Load dashboard stats + connect socket once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().init();
    });
  }

  Future<void> _toggleOnline() async {
    final driver = context.read<DriverProvider>();
    if (driver.isOnline) {
      await driver.goOffline();
    } else {
      await driver.goOnline();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<DriverProvider>();
    final stats = driver.stats;

    // When a dispatched ride is accepted it becomes the active ride — hand off
    // to the ride-flow screen.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _PlanBanner(onSubscribe: widget.onSubscribe),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _OnlineToggle(
                    isOnline: driver.isOnline,
                    busy: driver.busy,
                    onToggle: _toggleOnline,
                    pulse: _pulse,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _TodaySummary(stats: stats),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Recent trips (from backend stats, empty state otherwise)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's Trips", style: AppTextStyles.h4),
                      const SizedBox(height: 10),
                      if (stats.recentTrips.isEmpty)
                        _EmptyTrips()
                      else
                        ...stats.recentTrips.map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _TripTile(ride: r),
                            )),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // Incoming ride request overlay — driven by real dispatch
          if (driver.hasIncoming)
            _NewRideOverlay(
              ride: driver.incomingRide!,
              onAccept: () async {
                final ok = await driver.acceptIncoming();
                if (ok) widget.onNewRide?.call();
              },
              onDecline: () => driver.declineIncoming(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final user = context.watch<AuthProvider>().user;
    final name = (user?.name.isNotEmpty ?? false) ? user!.name : 'Driver';
    final rating = user != null && user.rating > 0
        ? user.rating.toStringAsFixed(1)
        : 'New';
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 12, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back,', style: AppTextStyles.bodySmWhite),
                  Text(name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                ],
              ),
              Row(
                children: [
                  _HeaderIcon(Icons.notifications_outlined, () {}),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withOpacity(0.3),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 22),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatPill(Icons.star_rounded, rating, AppColors.starColor),
              const SizedBox(width: 10),
              _StatPill(Icons.electric_bike_rounded,
                  '${user?.totalRides ?? 0} rides', Colors.white38),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIcon(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatPill(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.caption.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _PlanBanner extends StatelessWidget {
  final VoidCallback? onSubscribe;
  const _PlanBanner({this.onSubscribe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSubscribe,
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.3),
              blurRadius: 16, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.verified_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plan Active', style: AppTextStyles.h5White),
                  Text('Expires: 20 May 2024 · 11:59 PM',
                      style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Renew', style: AppTextStyles.labelSm.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnlineToggle extends StatelessWidget {
  final bool isOnline;
  final bool busy;
  final VoidCallback onToggle;
  final Animation<double> pulse;
  const _OnlineToggle({
    required this.isOnline,
    required this.busy,
    required this.onToggle,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isOnline
            ? const LinearGradient(colors: AppColors.successGradient)
            : const LinearGradient(colors: [Color(0xFFF0F2F5), Color(0xFFE8ECF4)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isOnline
            ? [BoxShadow(color: AppColors.success.withOpacity(0.3),
                blurRadius: 20, offset: const Offset(0, 6))]
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'You are Online' : 'You are Offline',
                  style: isOnline
                      ? AppTextStyles.h3White
                      : AppTextStyles.h3,
                ),
                const SizedBox(height: 4),
                Text(
                  isOnline
                      ? 'Ready to accept rides'
                      : 'Go online to start accepting rides',
                  style: isOnline
                      ? AppTextStyles.bodySmWhite
                      : AppTextStyles.bodyMd,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: busy ? null : onToggle,
            child: AnimatedBuilder(
              animation: pulse,
              builder: (_, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isOnline)
                      Container(
                        width: 68 + pulse.value * 12,
                        height: 68 + pulse.value * 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15 * pulse.value),
                        ),
                      ),
                    child!,
                  ],
                );
              },
              child: Container(
                width: 68, height: 68,
                decoration: BoxDecoration(
                  color: isOnline ? Colors.white : AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isOnline ? Colors.white : AppColors.primary).withOpacity(0.3),
                      blurRadius: 16, offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: busy
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          strokeWidth: 3, color: AppColors.primary),
                      )
                    : Icon(
                        isOnline ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: isOnline ? AppColors.success : Colors.white,
                        size: 34,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaySummary extends StatelessWidget {
  final DriverStats stats;
  const _TodaySummary({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Summary", style: AppTextStyles.h4),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _SummaryCard('₹${stats.todayEarnings}', 'Total Earnings',
                Icons.currency_rupee_rounded, AppColors.success)),
            const SizedBox(width: 10),
            Expanded(child: _SummaryCard('${stats.ridesCompleted}', 'Rides Completed',
                Icons.electric_bike_rounded, AppColors.primary)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _SummaryCard('₹${stats.incentives}', 'Incentives',
                Icons.star_rounded, AppColors.warning)),
            const SizedBox(width: 10),
            Expanded(child: _SummaryCard('${stats.cancellationRate.toStringAsFixed(0)}%',
                'Cancellation', Icons.cancel_outlined, AppColors.error)),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _SummaryCard(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark,
                    )),
                Text(label, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripTile extends StatelessWidget {
  final RideModel ride;
  const _TripTile({required this.ride});

  @override
  Widget build(BuildContext context) {
    final route = '${ride.pickup.name} → ${ride.drop.name}';
    final time = ride.completedAt != null
        ? TimeOfDay.fromDateTime(ride.completedAt!).format(context)
        : '';
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.electric_bike_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(route, style: AppTextStyles.h5, maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(time, style: AppTextStyles.bodySm),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${ride.fare}',
                  style: AppTextStyles.priceSmall.copyWith(color: AppColors.success)),
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyTrips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        children: [
          Icon(Icons.electric_bike_outlined,
              color: AppColors.textLight, size: 32),
          const SizedBox(height: 8),
          Text('No trips yet today', style: AppTextStyles.bodyMd),
          const SizedBox(height: 2),
          Text('Go online to start earning', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _NewRideOverlay extends StatefulWidget {
  final RideModel ride;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  const _NewRideOverlay({
    required this.ride,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<_NewRideOverlay> createState() => _NewRideOverlayState();
}

class _NewRideOverlayState extends State<_NewRideOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  int _countdown = 20;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        if (_countdown <= 1) {
          widget.onDecline();
        } else {
          setState(() => _countdown--);
        }
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dim background
        GestureDetector(
          onTap: widget.onDecline,
          child: Container(color: Colors.black54),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _slide,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2),
                      blurRadius: 30, offset: const Offset(0, -8)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Countdown ring + label
                  Row(
                    children: [
                      // Countdown
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 52, height: 52,
                            child: CircularProgressIndicator(
                              value: _countdown / 20,
                              strokeWidth: 4,
                              backgroundColor: AppColors.greyBg,
                              color: AppColors.primary,
                            ),
                          ),
                          Text('$_countdown',
                              style: AppTextStyles.h4.copyWith(color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('New Ride Request',
                                      style: AppTextStyles.labelSm.copyWith(color: AppColors.primary)),
                                ),
                                const SizedBox(width: 8),
                                Text(widget.ride.serviceType.label,
                                    style: AppTextStyles.labelMd.copyWith(color: AppColors.textMedium)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('${widget.ride.distanceKm.toStringAsFixed(1)} km trip',
                                style: AppTextStyles.h5.copyWith(color: AppColors.info)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Route
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.greyBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _RideRow(Icons.radio_button_checked_rounded,
                            AppColors.mapPickup, widget.ride.pickup.name),
                        const SizedBox(height: 6),
                        _RideRow(Icons.location_on_rounded,
                            AppColors.mapDrop, widget.ride.drop.name),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Fare
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Estimated Fare', style: AppTextStyles.bodyMd),
                      Text('₹${widget.ride.fare}',
                          style: AppTextStyles.h3.copyWith(color: AppColors.success)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Decline',
                          variant: AppButtonVariant.outline,
                          customColor: AppColors.error,
                          onTap: widget.onDecline,
                          height: 50,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: AppGradientButton(
                          label: 'Accept Ride',
                          onTap: widget.onAccept,
                          height: 50,
                          prefixIcon: Icons.check_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RideRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _RideRow(this.icon, this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppTextStyles.bodyMd)),
      ],
    );
  }
}


