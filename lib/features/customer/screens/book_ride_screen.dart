import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_map_placeholder.dart';
import '../../../providers/ride_provider.dart';
import '../../../data/models/ride_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Pricing config — ₹8/km base, per tier
// ─────────────────────────────────────────────────────────────────────────────
class RidePricing {
  static const double baseKmRate     = 8.0;   // Go: ₹8/km
  static const double plusKmRate     = 11.0;
  static const double premiumKmRate  = 14.0;

  static const double goBase         = 20.0;
  static const double plusBase       = 25.0;
  static const double premiumBase    = 30.0;

  static const double goMin          = 30.0;
  static const double plusMin        = 40.0;
  static const double premiumMin     = 55.0;

  static int fare(double km, double rate, double base, double min) {
    final f = base + km * rate;
    return (f < min ? min : f).toInt();
  }
}

class BookRideScreen extends StatefulWidget {
  final String service;       // Bike | Auto | Cab | Parcel
  final String destination;   // pre-filled from home
  final VoidCallback? onBooked;
  final VoidCallback? onBack;

  const BookRideScreen({
    super.key,
    this.service = 'Bike',
    this.destination = '',
    this.onBooked,
    this.onBack,
  });

  @override
  State<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen>
    with TickerProviderStateMixin {
  final _pickupCtrl =
      TextEditingController(text: 'Current Location');
  late TextEditingController _dropCtrl;

  int _selectedTier  = 0;   // 0=Go, 1=Plus, 2=Premium
  String _payment    = 'Cash';
  final bool _isSurge = true;
  double _distanceKm = 3.0; // fallback until the real distance loads

  // Quick chat messages (Rapido feature)
  bool _showChat = false;

  late AnimationController _sheetCtrl;
  late Animation<Offset>   _sheetAnim;
  late AnimationController _routeCtrl;
  late Animation<double>   _routeAnim;

  List<_Tier> get _tiers => [
    _Tier(
      name: 'BikeJee Go',
      icon: Icons.electric_bike_rounded,
      color: AppColors.primary,
      eta: '2–4 min',
      kmRate: RidePricing.baseKmRate,
      fare: RidePricing.fare(
          _distanceKm, RidePricing.baseKmRate,
          RidePricing.goBase, RidePricing.goMin),
      tag: 'Best Value',
      surgeMultiplier: _isSurge ? 1.2 : 1.0,
    ),
    _Tier(
      name: 'BikeJee Plus',
      icon: Icons.electric_bike_rounded,
      color: AppColors.info,
      eta: '4–6 min',
      kmRate: RidePricing.plusKmRate,
      fare: RidePricing.fare(
          _distanceKm, RidePricing.plusKmRate,
          RidePricing.plusBase, RidePricing.plusMin),
      tag: null,
      surgeMultiplier: _isSurge ? 1.15 : 1.0,
    ),
    _Tier(
      name: 'BikeJee Premium',
      icon: Icons.electric_bike_rounded,
      color: AppColors.accentOrange,
      eta: '5–8 min',
      kmRate: RidePricing.premiumKmRate,
      fare: RidePricing.fare(
          _distanceKm, RidePricing.premiumKmRate,
          RidePricing.premiumBase, RidePricing.premiumMin),
      tag: null,
      surgeMultiplier: 1.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _dropCtrl = TextEditingController(text: widget.destination);

    // Pull the real distance computed by RideProvider (haversine / Distance Matrix).
    // Pickup is now set from the user's location in home_screen, so this is real.
    final ride = context.read<RideProvider>();
    if (ride.distanceKm > 0) {
      _distanceKm = ride.distanceKm;
    }
    // Prefill the pickup label from the resolved pickup place.
    if (ride.pickup?.name.isNotEmpty ?? false) {
      _pickupCtrl.text = ride.pickup!.name;
    }

    _sheetCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _sheetAnim = Tween<Offset>(
            begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _sheetCtrl, curve: Curves.easeOutCubic));

    _routeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _routeAnim =
        CurvedAnimation(parent: _routeCtrl, curve: Curves.easeOut);

    // Animate sheet in on load
    Future.microtask(() {
      _sheetCtrl.forward();
      _routeCtrl.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Keep the displayed distance in sync with the provider's real value
    // (it may recalculate asynchronously in real/backend mode).
    final r = context.read<RideProvider>();
    if (r.distanceKm > 0 && r.distanceKm != _distanceKm) {
      _distanceKm = r.distanceKm;
    }
  }

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropCtrl.dispose();
    _sheetCtrl.dispose();
    _routeCtrl.dispose();
    super.dispose();
  }

  _Tier get _selected => _tiers[_selectedTier];

  // Books the ride via RideProvider, then triggers navigation to Finding Driver.
  void _confirmBooking() async {
    final ride = context.read<RideProvider>();
    // Map the selected tier index to the RideTier enum
    ride.setTier(RideTier.values[_selectedTier.clamp(0, 2)]);
    // customerId is stored in AuthProvider — use a placeholder if absent
    await ride.bookRide('current-user');
    if (!mounted) return;
    widget.onBooked?.call();
  }

  int get _finalFare =>
      (_selected.fare * _selected.surgeMultiplier).toInt();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Full map ────────────────────────────────────────────────────
          Positioned.fill(
            child: AppMapPlaceholder(
                isFullScreen: true, showRoute: true),
          ),

          // ── Route distance badge ────────────────────────────────────────
          AnimatedBuilder(
            animation: _routeAnim,
            builder: (_, __) => Positioned(
              top: MediaQuery.of(context).padding.top + 14,
              left: 0, right: 0,
              child: Opacity(
                opacity: _routeAnim.value,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.mapPickup,
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text('Current Location',
                            style: AppTextStyles.labelSm),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: List.generate(
                              4, (_) => Container(
                                width: 3, height: 3,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                    color: AppColors.textLight,
                                    shape: BoxShape.circle),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                              color: AppColors.mapDrop,
                              borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.destination.isNotEmpty
                              ? widget.destination
                              : 'Destination',
                          style: AppTextStyles.labelSm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Back button ─────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 14,
            left: 14,
            child: GestureDetector(
              onTap: widget.onBack,
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8)
                  ],
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.textDark, size: 20),
              ),
            ),
          ),

          // ── Distance + surge pill ────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 14,
            right: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.route_rounded,
                          color: AppColors.primary, size: 13),
                      const SizedBox(width: 4),
                      Text('${_distanceKm.toStringAsFixed(1)} km',
                          style: AppTextStyles.labelMd
                              .copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                if (_isSurge) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded,
                            color: Colors.white, size: 13),
                        Text('Surge',
                            style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Quick chat messages overlay ──────────────────────────────────
          if (_showChat)
            Positioned(
              bottom: 340,
              left: 16, right: 16,
              child: _QuickChatBubbles(
                  onClose: () => setState(() => _showChat = false)),
            ),

          // ── Bottom fare sheet ────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SlideTransition(
              position: _sheetAnim,
              child: _FareSheet(
                tiers: _tiers,
                selectedIndex: _selectedTier,
                onSelect: (i) => setState(() => _selectedTier = i),
                distanceKm: _distanceKm,
                finalFare: _finalFare,
                isSurge: _isSurge,
                payment: _payment,
                onPaymentTap: _showPaymentSheet,
                onChatTap: () =>
                    setState(() => _showChat = !_showChat),
                onBook: _confirmBooking,
                dropCtrl: _dropCtrl,
                pickupCtrl: _pickupCtrl,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentSheet(
        selected: _payment,
        onSelect: (m) {
          setState(() => _payment = m);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fare sheet — single-tap confirm
// ─────────────────────────────────────────────────────────────────────────────
class _FareSheet extends StatelessWidget {
  final List<_Tier> tiers;
  final int selectedIndex;
  final Function(int) onSelect;
  final double distanceKm;
  final int finalFare;
  final bool isSurge;
  final String payment;
  final VoidCallback onPaymentTap;
  final VoidCallback onChatTap;
  final VoidCallback? onBook;
  final TextEditingController dropCtrl;
  final TextEditingController pickupCtrl;

  const _FareSheet({
    required this.tiers,
    required this.selectedIndex,
    required this.onSelect,
    required this.distanceKm,
    required this.finalFare,
    required this.isSurge,
    required this.payment,
    required this.onPaymentTap,
    required this.onChatTap,
    required this.onBook,
    required this.dropCtrl,
    required this.pickupCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final selected = tiers[selectedIndex];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(
            color: Colors.black26, blurRadius: 20,
            offset: Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),

          // Route summary (editable)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.greyBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _RouteRow(
                    dot: AppColors.mapPickup,
                    isCircle: true,
                    child: Text(pickupCtrl.text,
                        style: AppTextStyles.bodyMd,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const Divider(height: 1, indent: 40),
                  _RouteRow(
                    dot: AppColors.mapDrop,
                    isCircle: false,
                    child: TextField(
                      controller: dropCtrl,
                      style: AppTextStyles.bodyMd,
                      decoration: InputDecoration(
                        hintText: 'Enter destination',
                        hintStyle: AppTextStyles.bodyMd,
                        border: InputBorder.none,
                        filled: false,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Fare breakdown banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.primary, size: 15),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${selected.name}: ₹${selected.kmRate.toInt()}/km  ·  '
                      '${distanceKm.toStringAsFixed(1)} km  ·  '
                      'Base ₹${selected.name == "BikeJee Go" ? RidePricing.goBase.toInt() : selected.name == "BikeJee Plus" ? RidePricing.plusBase.toInt() : RidePricing.premiumBase.toInt()}'
                      '${isSurge && selected.surgeMultiplier > 1.0 ? "  ·  🔥 Surge ×${selected.surgeMultiplier}" : ""}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Tier cards — horizontal scroll
          SizedBox(
            height: 98,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tiers.length,
              itemBuilder: (_, i) {
                final tier = tiers[i];
                final isSelected = selectedIndex == i;
                final displayFare =
                    (tier.fare * tier.surgeMultiplier).toInt();

                return GestureDetector(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 140,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? tier.color.withOpacity(0.08)
                          : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? tier.color
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(
                              color: tier.color.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 3))]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(tier.icon,
                                color: tier.color, size: 20),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                tier.name.replaceFirst('BikeJee ', ''),
                                style: AppTextStyles.h5
                                    .copyWith(color: tier.color),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(tier.eta,
                            style: AppTextStyles.caption),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₹$displayFare',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? tier.color
                                      : AppColors.textDark,
                                )),
                            if (isSurge &&
                                tier.surgeMultiplier > 1.0) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.bolt_rounded,
                                  color: AppColors.warning, size: 14),
                            ],
                          ],
                        ),
                        if (tier.tag != null)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(tier.tag!,
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary)),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Payment + chat row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Payment pill
                GestureDetector(
                  onTap: onPaymentTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.greyBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.payment_rounded,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(payment,
                            style: AppTextStyles.labelMd
                                .copyWith(color: AppColors.primary)),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Quick chat
                GestureDetector(
                  onTap: onChatTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.greyBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded,
                            color: AppColors.textMedium, size: 16),
                        const SizedBox(width: 6),
                        Text('Quick Chat',
                            style: AppTextStyles.labelMd),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Total fare
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹$finalFare',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
                    Text('Total fare',
                        style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Book button
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 0, 16,
                MediaQuery.of(context).padding.bottom + 12),
            child: GestureDetector(
              onTap: onBook,
              child: Container(
                height: 54,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: AppColors.primaryGradient),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Book ${tiers[selectedIndex].name.replaceFirst("BikeJee ", "")} · ₹$finalFare',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
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

// ─────────────────────────────────────────────────────────────────────────────
// Quick Chat Bubbles (Rapido feature)
// ─────────────────────────────────────────────────────────────────────────────
class _QuickChatBubbles extends StatelessWidget {
  final VoidCallback onClose;
  const _QuickChatBubbles({required this.onClose});

  static const _messages = [
    "I'm waiting at pickup",
    "Where are you?",
    "I'll be there in 2 mins",
    "Please come to gate 2",
    "Can you hurry please?",
    "I've arrived at drop",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Quick Messages', style: AppTextStyles.h5),
              const Spacer(),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close_rounded,
                    color: AppColors.textLight, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _messages.map((msg) => GestureDetector(
              onTap: () {
                onClose();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sent: "$msg"'),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Text(msg,
                    style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.primaryDark)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Route row widget
// ─────────────────────────────────────────────────────────────────────────────
class _RouteRow extends StatelessWidget {
  final Color dot;
  final bool isCircle;
  final Widget child;
  const _RouteRow(
      {required this.dot, required this.isCircle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          isCircle
              ? Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                      color: dot, shape: BoxShape.circle))
              : Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                      color: dot,
                      borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment sheet
// ─────────────────────────────────────────────────────────────────────────────
class _PaymentSheet extends StatelessWidget {
  final String selected;
  final Function(String) onSelect;
  const _PaymentSheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final methods = [
      ('Cash', Icons.money_rounded, Colors.green,
          'Pay after the ride'),
      ('UPI', Icons.qr_code_scanner_rounded, Colors.deepPurple,
          'Google Pay, PhonePe, Paytm'),
      ('Card', Icons.credit_card_rounded, AppColors.info,
          'Visa, Mastercard, RuPay'),
      ('BikeJee Wallet', Icons.account_balance_wallet_rounded,
          AppColors.primary, 'Balance: ₹320'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Payment Method', style: AppTextStyles.h4),
          const SizedBox(height: 14),
          ...methods.map((m) {
            final isSel = selected == m.$1;
            return GestureDetector(
              onTap: () => onSelect(m.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSel
                      ? AppColors.primarySurface
                      : AppColors.greyBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSel
                        ? AppColors.primary
                        : AppColors.border,
                    width: isSel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: m.$3.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(m.$2, color: m.$3, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.$1, style: AppTextStyles.h5),
                          Text(m.$4, style: AppTextStyles.bodySm),
                        ],
                      ),
                    ),
                    if (isSel)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 22),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────
class _Tier {
  final String name, eta;
  final IconData icon;
  final Color color;
  final double kmRate, surgeMultiplier;
  final int fare;
  final String? tag;

  const _Tier({
    required this.name,
    required this.icon,
    required this.color,
    required this.eta,
    required this.kmRate,
    required this.fare,
    required this.surgeMultiplier,
    this.tag,
  });
}
