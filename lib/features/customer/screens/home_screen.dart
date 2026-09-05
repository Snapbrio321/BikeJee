import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/bikejee_logo.dart';

class CustomerHomeScreen extends StatefulWidget {
  final void Function(String service, String destination)? onBookRide;
  final VoidCallback? onParcel;

  const CustomerHomeScreen({super.key, this.onBookRide, this.onParcel});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
    with TickerProviderStateMixin {
  final _destinationCtrl = TextEditingController();
  final _focusNode = FocusNode();
  String _activeService = 'Bike'; // Bike | Auto | Cab | Parcel
  bool _showSuggestions = false;
  final bool _isSurge = true;

  late AnimationController _pulseCtrl;
  late AnimationController _captainCtrl;

  // Simulated recent places
  final _recentPlaces = [
    _Place('Home', 'Koramangala, Bangalore', Icons.home_rounded, '2.1 km'),
    _Place('Work', 'Electronic City, Bangalore', Icons.work_rounded, '8.4 km'),
    _Place('MGM Hospital', 'MG Road, Bangalore', Icons.local_hospital_rounded, '4.2 km'),
    _Place('Forum Mall', 'Koramangala, Bangalore', Icons.shopping_bag_rounded, '1.8 km'),
  ];

  // Simulated popular places
  final _popular = [
    _Place('Bangalore Airport', 'Devanahalli', Icons.flight_rounded, '34 km'),
    _Place('Whitefield', 'Whitefield Main Rd', Icons.location_on_rounded, '18 km'),
    _Place('Indiranagar', '100 Feet Road', Icons.location_on_rounded, '5.3 km'),
    _Place('HSR Layout', 'Sector 2', Icons.location_on_rounded, '3.7 km'),
    _Place('JP Nagar', '7th Phase', Icons.location_on_rounded, '6.1 km'),
  ];

  // Simulated nearby captains on map
  final _captainDots = <_CaptainDot>[];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _captainCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 8))..repeat();

    // Generate random nearby captain dots
    final rng = math.Random(42);
    for (int i = 0; i < 6; i++) {
      _captainDots.add(_CaptainDot(
        x: 0.1 + rng.nextDouble() * 0.8,
        y: 0.1 + rng.nextDouble() * 0.7,
        angle: rng.nextDouble() * 2 * math.pi,
      ));
    }
  }

  @override
  void dispose() {
    _destinationCtrl.dispose();
    _focusNode.dispose();
    _pulseCtrl.dispose();
    _captainCtrl.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _showSuggestions = true);
    // Focus the field after it's rendered in the suggestions sheet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);
  }

  void _selectPlace(_Place place) {
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);

    if (_activeService == 'Parcel') {
      widget.onParcel?.call();
    } else {
      widget.onBookRide?.call(_activeService, place.name);
    }
    // Clear after navigating so home is fresh on return
    _destinationCtrl.clear();
  }

  List<_Place> get _filteredSuggestions {
    final q = _destinationCtrl.text.toLowerCase();
    if (q.isEmpty) return _recentPlaces;
    return [..._recentPlaces, ..._popular]
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.address.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Full-screen map ──────────────────────────────────────────────
          Positioned.fill(child: _MapBackground(
            captainDots: _captainDots,
            captainAnim: _captainCtrl,
            pulseAnim: _pulseCtrl,
          )),

          // ── Top bar (logo + notifications) ───────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Row(
                    children: [
                      const BikeJeeLogo(darkBg: true),
                      const Spacer(),
                      // Surge badge
                      if (_isSurge)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt_rounded,
                                  color: Colors.white, size: 13),
                              const SizedBox(width: 3),
                              Text('Surge',
                                  style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      const SizedBox(width: 10),
                      // Notification bell
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Service tabs (Bike/Auto/Cab/Parcel) ──────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 16,
            right: 16,
            child: _ServiceTabRow(
              active: _activeService,
              onSelect: (s) => setState(() => _activeService = s),
            ),
          ),

          // ── "Where are you going?" bottom sheet ──────────────────────────
          if (!_showSuggestions)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _WhereToSheet(
                controller: _destinationCtrl,
                service: _activeService,
                isSurge: _isSurge,
                onTapSearch: _openSearch,
                onSchedule: _showScheduleSheet,
                onForSomeone: _showForSomeoneSheet,
              ),
            ),

          // ── Search suggestions overlay ────────────────────────────────────
          if (_showSuggestions)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeSearch,
                child: Container(color: Colors.black.withOpacity(0.4)),
              ),
            ),

          if (_showSuggestions)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _SuggestionsSheet(
                controller: _destinationCtrl,
                focusNode: _focusNode,
                suggestions: _filteredSuggestions,
                onSelect: _selectPlace,
                onChanged: () => setState(() {}),
                service: _activeService,
                onServiceChange: (s) => setState(() => _activeService = s),
                onClose: _closeSearch,
              ),
            ),
        ],
      ),
    );
  }

  void _showScheduleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScheduleSheet(
        onScheduled: (dt) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ride scheduled for ${_formatDateTime(dt)}'),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  void _showForSomeoneSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ForSomeoneSheet(),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]}, $h:$m $ampm';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Map background with animated captain dots
// ─────────────────────────────────────────────────────────────────────────────
class _MapBackground extends StatelessWidget {
  final List<_CaptainDot> captainDots;
  final Animation<double> captainAnim;
  final Animation<double> pulseAnim;

  const _MapBackground({
    required this.captainDots,
    required this.captainAnim,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base map color
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A2035), Color(0xFF0E1525)],
            ),
          ),
        ),
        // Grid lines (street simulation)
        CustomPaint(
          size: Size.infinite,
          painter: _StreetPainter(),
        ),
        // User location dot (center)
        Center(
          child: AnimatedBuilder(
            animation: pulseAnim,
            builder: (_, __) => Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 56 + pulseAnim.value * 20,
                  height: 56 + pulseAnim.value * 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(
                        0.15 * (1 - pulseAnim.value)),
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Captain dots
        ...captainDots.map((dot) => AnimatedBuilder(
          animation: captainAnim,
          builder: (_, __) {
            final t = captainAnim.value;
            final dx = math.sin(t * 2 * math.pi + dot.angle) * 8;
            final dy = math.cos(t * 2 * math.pi + dot.angle) * 6;
            return Positioned(
              left: MediaQuery.of(context).size.width * dot.x + dx,
              top: MediaQuery.of(context).size.height * dot.y + dy,
              child: _CaptainMarker(),
            );
          },
        )),
      ],
    );
  }
}

class _CaptainMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6),
        ],
      ),
      child: const Icon(Icons.electric_bike_rounded,
          color: AppColors.primary, size: 18),
    );
  }
}

class _StreetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 2;
    final major = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 4;

    // Horizontal roads
    for (double y = 0; y < size.height; y += size.height / 8) {
      final p = y == 0 ? major : road;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    // Vertical roads
    for (double x = 0; x < size.width; x += size.width / 6) {
      final p = x == 0 ? major : road;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    // Diagonal accent roads
    final diag = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(0, size.height * 0.3),
        Offset(size.width, size.height * 0.6), diag);
    canvas.drawLine(Offset(size.width * 0.2, 0),
        Offset(size.width * 0.8, size.height), diag);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Service tab row (Bike / Auto / Cab / Parcel)
// ─────────────────────────────────────────────────────────────────────────────
class _ServiceTabRow extends StatelessWidget {
  final String active;
  final Function(String) onSelect;

  const _ServiceTabRow({required this.active, required this.onSelect});

  static const _tabs = [
    ('Bike', Icons.electric_bike_rounded),
    ('Auto', Icons.airport_shuttle_rounded),
    ('Cab', Icons.local_taxi_rounded),
    ('Parcel', Icons.inventory_2_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _tabs.map((tab) {
        final isActive = active == tab.$1;
        return GestureDetector(
          onTap: () => onSelect(tab.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isActive
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.2),
                width: isActive ? 0 : 1,
              ),
              boxShadow: isActive
                  ? [BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 12, offset: const Offset(0, 3))]
                  : null,
            ),
            child: Row(
              children: [
                Icon(tab.$2, size: 14, color: isActive ? Colors.white : Colors.white70),
                const SizedBox(width: 4),
                Text(
                  tab.$1,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
      ),  // Row
    );  // SingleChildScrollView
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "Where to?" bottom sheet (default state)
// ─────────────────────────────────────────────────────────────────────────────
class _WhereToSheet extends StatelessWidget {
  final TextEditingController controller;
  final String service;
  final bool isSurge;
  final VoidCallback onTapSearch;
  final VoidCallback onSchedule;
  final VoidCallback onForSomeone;

  const _WhereToSheet({
    required this.controller,
    required this.service,
    required this.isSurge,
    required this.onTapSearch,
    required this.onSchedule,
    required this.onForSomeone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Greeting
          Row(
            children: [
              Text('Good morning! 👋',
                  style: AppTextStyles.bodySm),
              const Spacer(),
              // Nearby captains count
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text('6 captains nearby',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // "Where to?" search bar — tapping opens suggestions
          GestureDetector(
            onTap: onTapSearch,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.greyBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.mapDrop,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Where to?',
                      style: AppTextStyles.h4.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  // Surge badge inside search bar
                  if (isSurge)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded,
                              color: AppColors.warning, size: 13),
                          Text('Surge',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Quick action chips
          Row(
            children: [
              _QuickChip(
                icon: Icons.access_time_rounded,
                label: 'Schedule',
                color: AppColors.info,
                onTap: onSchedule,
              ),
              const SizedBox(width: 10),
              _QuickChip(
                icon: Icons.person_add_rounded,
                label: 'For someone',
                color: AppColors.accentOrange,
                onTap: onForSomeone,
              ),
              const SizedBox(width: 10),
              _QuickChip(
                icon: Icons.local_offer_rounded,
                label: 'Offers',
                color: AppColors.primary,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Saved places quick row
          Row(
            children: [
              Expanded(
                child: _SavedPlaceTile(
                  icon: Icons.home_rounded,
                  color: AppColors.info,
                  title: 'Home',
                  subtitle: 'Koramangala',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SavedPlaceTile(
                  icon: Icons.work_rounded,
                  color: AppColors.accentOrange,
                  title: 'Work',
                  subtitle: 'Electronic City',
                  onTap: () {},
                ),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search suggestions sheet
// ─────────────────────────────────────────────────────────────────────────────
class _SuggestionsSheet extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<_Place> suggestions;
  final Function(_Place) onSelect;
  final VoidCallback onChanged;
  final String service;
  final Function(String) onServiceChange;
  final VoidCallback onClose;

  const _SuggestionsSheet({
    required this.controller,
    required this.focusNode,
    required this.suggestions,
    required this.onSelect,
    required this.onChanged,
    required this.service,
    required this.onServiceChange,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Route input area (pickup + drop)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.greyBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // Pickup
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.mapPickup,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('Current location',
                              style: AppTextStyles.bodyMd
                                  .copyWith(color: AppColors.textMedium)),
                        ),
                        const Icon(Icons.my_location_rounded,
                            color: AppColors.primary, size: 18),
                      ],
                    ),
                  ),
                  const Divider(height: 1, indent: 34),
                  // Drop search field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.mapDrop,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            autofocus: true,
                            style: AppTextStyles.h5,
                            onChanged: (_) => onChanged(),
                            decoration: InputDecoration(
                              hintText: 'Enter destination',
                              hintStyle: AppTextStyles.bodyMd,
                              border: InputBorder.none,
                              filled: false,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12),
                            ),
                          ),
                        ),
                        if (controller.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              controller.clear();
                              onChanged();
                            },
                            child: const Icon(Icons.close_rounded,
                                color: AppColors.textLight, size: 18),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Service selector inside suggestions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: ['Bike', 'Auto', 'Cab', 'Parcel'].map((s) {
                final isActive = service == s;
                return GestureDetector(
                  onTap: () => onServiceChange(s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.greyBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      s,
                      style: AppTextStyles.labelMd.copyWith(
                        color: isActive ? Colors.white : AppColors.textMedium,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // Suggestions list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: suggestions.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      controller.text.isEmpty
                          ? 'Recent places'
                          : 'Search results',
                      style: AppTextStyles.h5.copyWith(
                          color: AppColors.textLight),
                    ),
                  );
                }
                final place = suggestions[i - 1];
                return GestureDetector(
                  onTap: () => onSelect(place),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.greyBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(place.icon,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(place.name, style: AppTextStyles.h5),
                              Text(place.address,
                                  style: AppTextStyles.bodySm),
                            ],
                          ),
                        ),
                        Text(place.distance,
                            style: AppTextStyles.labelMd
                                .copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Schedule Ride Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ScheduleSheet extends StatefulWidget {
  final Function(DateTime) onScheduled;
  const _ScheduleSheet({required this.onScheduled});

  @override
  State<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<_ScheduleSheet> {
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  int _selectedHour = DateTime.now().add(const Duration(hours: 1)).hour;

  @override
  Widget build(BuildContext context) {
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.access_time_rounded,
                    color: AppColors.info, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Schedule a Ride', style: AppTextStyles.h4),
                  Text('Book in advance for your next trip',
                      style: AppTextStyles.bodySm),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Time slots
          Text('Pick a time', style: AppTextStyles.h5),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              itemBuilder: (_, i) {
                final dt = DateTime.now().add(Duration(hours: i + 1));
                final isSelected = _selectedHour == dt.hour;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedHour = dt.hour;
                    _selectedDate = dt;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.greyBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      '${dt.hour > 12 ? dt.hour - 12 : dt.hour}:00 ${dt.hour >= 12 ? "PM" : "AM"}',
                      style: AppTextStyles.labelMd.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textMedium,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => widget.onScheduled(_selectedDate),
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.info,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('Confirm Schedule',
                      style: AppTextStyles.btnLg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Book For Someone Else Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ForSomeoneSheet extends StatelessWidget {
  const _ForSomeoneSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_add_rounded,
                    color: AppColors.warning, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Book for someone', style: AppTextStyles.h4),
                  Text("Enter their mobile number",
                      style: AppTextStyles.bodySm),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.greyBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text('🇮🇳 +91',
                      style: AppTextStyles.h5
                          .copyWith(color: AppColors.textMedium)),
                ),
                Container(width: 1, height: 24, color: AppColors.border),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    style: AppTextStyles.h4,
                    decoration: const InputDecoration(
                      hintText: 'Mobile number',
                      border: InputBorder.none,
                      filled: false,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Contacts list
          Text('From contacts', style: AppTextStyles.h5),
          const SizedBox(height: 10),
          ...[
            ('Mom', '98765-43210'),
            ('Dad', '87654-32109'),
            ('Friend Raj', '76543-21098'),
          ].map((c) => GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primarySurface,
                        child: Text(c.$1[0],
                            style: AppTextStyles.h5
                                .copyWith(color: AppColors.primary)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.$1, style: AppTextStyles.h5),
                            Text(c.$2, style: AppTextStyles.bodySm),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Text('Select',
                            style: AppTextStyles.labelSm
                                .copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────
class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickChip({
    required this.icon, required this.label,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: AppTextStyles.labelSm
                    .copyWith(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _SavedPlaceTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final VoidCallback onTap;

  const _SavedPlaceTile({
    required this.icon, required this.color,
    required this.title, required this.subtitle, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.greyBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h5,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(subtitle, style: AppTextStyles.caption,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────
class _Place {
  final String name, address, distance;
  final IconData icon;
  const _Place(this.name, this.address, this.icon, this.distance);
}

class _CaptainDot {
  final double x, y, angle;
  const _CaptainDot({required this.x, required this.y, required this.angle});
}
