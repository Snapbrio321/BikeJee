import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';

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
  bool _isOnline = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  Timer? _rideTimer;
  bool _newRideRequest = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  void _toggleOnline() {
    setState(() => _isOnline = !_isOnline);
    if (_isOnline) {
      // Simulate incoming ride after 4 seconds
      _rideTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _isOnline) {
          setState(() => _newRideRequest = true);
        }
      });
    } else {
      _rideTimer?.cancel();
      setState(() => _newRideRequest = false);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // App bar
              SliverToBoxAdapter(child: _buildHeader()),

              // Plan active banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _PlanBanner(onSubscribe: widget.onSubscribe),
                ),
              ),

              // Online toggle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _OnlineToggle(
                    isOnline: _isOnline,
                    onToggle: _toggleOnline,
                    pulse: _pulse,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Today's stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _TodaySummary(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Recent trips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's Trips", style: AppTextStyles.h4),
                      const SizedBox(height: 10),
                      ..._recentTrips.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TripTile(trip: t),
                      )),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // New Ride Request overlay
          if (_newRideRequest)
            _NewRideOverlay(
              onAccept: () {
                setState(() => _newRideRequest = false);
                widget.onNewRide?.call();
              },
              onDecline: () => setState(() => _newRideRequest = false),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
                  Text('Arjun Kumar',
                      style: GoogleFonts.poppins(
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
              _StatPill(Icons.electric_bike_rounded, 'KA 03 JE 1234', Colors.white38),
              const SizedBox(width: 10),
              _StatPill(Icons.star_rounded, '4.8', AppColors.starColor),
              const SizedBox(width: 10),
              _StatPill(Icons.cancel_outlined, '2%', AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  static final _recentTrips = [
    _Trip('Koramangala → MG Road', '₹45', '10:30 AM', true),
    _Trip('HSR Layout → Whitefield', '₹120', '08:15 AM', true),
    _Trip('BTM Layout → Silk Board', '₹35', '07:00 AM', true),
  ];
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
  final VoidCallback onToggle;
  final Animation<double> pulse;
  const _OnlineToggle({required this.isOnline, required this.onToggle, required this.pulse});

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
            onTap: onToggle,
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
                child: Icon(
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
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Summary", style: AppTextStyles.h4),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _SummaryCard('₹1,420', 'Total Earnings',
                Icons.currency_rupee_rounded, AppColors.success)),
            const SizedBox(width: 10),
            Expanded(child: _SummaryCard('12', 'Rides Completed',
                Icons.electric_bike_rounded, AppColors.primary)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _SummaryCard('₹150', 'Incentives',
                Icons.star_rounded, AppColors.warning)),
            const SizedBox(width: 10),
            Expanded(child: _SummaryCard('2%', 'Cancellation',
                Icons.cancel_outlined, AppColors.error)),
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
                    style: GoogleFonts.poppins(
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
  final _Trip trip;
  const _TripTile({required this.trip});

  @override
  Widget build(BuildContext context) {
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
                Text(trip.route, style: AppTextStyles.h5, maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(trip.time, style: AppTextStyles.bodySm),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(trip.fare, style: AppTextStyles.priceSmall.copyWith(color: AppColors.success)),
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewRideOverlay extends StatefulWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  const _NewRideOverlay({required this.onAccept, required this.onDecline});

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
                                Text('Bike', style: AppTextStyles.labelMd.copyWith(color: AppColors.textMedium)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('1.2 km away',
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
                            AppColors.mapPickup, 'Koramangala, Bangalore'),
                        const SizedBox(height: 6),
                        _RideRow(Icons.location_on_rounded,
                            AppColors.mapDrop, 'MG Road, Bangalore'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Fare
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Estimated Fare', style: AppTextStyles.bodyMd),
                      Text('₹45',
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

class _Trip {
  final String route, fare, time;
  final bool completed;
  const _Trip(this.route, this.fare, this.time, this.completed);
}
