import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/rating_stars.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => _tab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _TabRow(
            tabs: const ['All', 'Bike', 'Auto', 'Parcel'],
            selectedIndex: _tab,
            onSelected: (i) {
              _tabController.animateTo(i < 3 ? i : 2);
              setState(() => _tab = i);
            },
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BookingList(filter: 'all'),
          _BookingList(filter: 'bike'),
          _BookingList(filter: 'parcel'),
        ],
      ),
    );
  }
}

class _TabRow extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onSelected;

  const _TabRow({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: tabs.asMap().entries.map((e) {
          final isSelected = selectedIndex == e.key;
          return GestureDetector(
            onTap: () => onSelected(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.greyBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                e.value,
                style: AppTextStyles.labelMd.copyWith(
                  color: isSelected ? Colors.white : AppColors.textMedium,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final String filter;
  const _BookingList({required this.filter});

  static final _allBookings = [
    _Booking(
      id: '#BJ001',
      type: 'bike',
      from: 'Koramangala, Bangalore',
      to: 'MG Road, Bangalore',
      date: 'Today',
      time: '10:32 AM',
      fare: '₹45',
      status: 'completed',
      driver: 'Arjun Kumar',
      rating: 4.8,
    ),
    _Booking(
      id: '#BJ002',
      type: 'auto',
      from: 'Indiranagar → Airport',
      to: 'Kempegowda Airport',
      date: 'Yesterday',
      time: '08:45 PM',
      fare: '₹210',
      status: 'completed',
      driver: 'Ravi Sharma',
      rating: 4.5,
    ),
    _Booking(
      id: '#BJ003',
      type: 'bike',
      from: 'HSR Layout → BTM Layout',
      to: 'BTM Layout',
      date: 'Yesterday',
      time: '04:20 PM',
      fare: '₹60',
      status: 'cancelled',
      driver: 'Deepak Kumar',
      rating: 0,
    ),
    _Booking(
      id: '#BJ004',
      type: 'parcel',
      from: 'Koramangala',
      to: 'HSR Layout → BTM Layout',
      date: '22 May, 09:18 AM',
      time: '09:18 AM',
      fare: '₹50',
      status: 'completed',
      driver: 'Suresh K',
      rating: 5.0,
    ),
    _Booking(
      id: '#BJ005',
      type: 'bike',
      from: 'Whitefield',
      to: 'Electronic City',
      date: '20 May',
      time: '07:30 AM',
      fare: '₹120',
      status: 'completed',
      driver: 'Manoj B',
      rating: 4.2,
    ),
  ];

  List<_Booking> get _filtered => filter == 'all'
      ? _allBookings
      : _allBookings.where((b) => b.type == filter).toList();

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    if (items.isEmpty) {
      return _EmptyState(filter: filter);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => _BookingCard(booking: items[i]),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final _Booking booking;
  const _BookingCard({required this.booking});

  Color get _statusColor {
    switch (booking.status) {
      case 'completed': return AppColors.success;
      case 'cancelled': return AppColors.error;
      case 'ongoing': return AppColors.primary;
      default: return AppColors.textLight;
    }
  }

  IconData get _typeIcon {
    switch (booking.type) {
      case 'bike': return Icons.electric_bike_rounded;
      case 'auto': return Icons.airport_shuttle_rounded;
      case 'parcel': return Icons.inventory_2_rounded;
      default: return Icons.local_taxi_rounded;
    }
  }

  Color get _typeColor {
    switch (booking.type) {
      case 'bike': return AppColors.primary;
      case 'auto': return AppColors.info;
      case 'parcel': return AppColors.primary;
      default: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      hasShadow: true,
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_typeIcon, color: _typeColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.type[0].toUpperCase() + booking.type.substring(1),
                        style: AppTextStyles.h5,
                      ),
                      Text('${booking.date} · ${booking.time}',
                          style: AppTextStyles.bodySm),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(booking.fare, style: AppTextStyles.priceSmall),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        booking.status[0].toUpperCase() + booking.status.substring(1),
                        style: AppTextStyles.caption.copyWith(color: _statusColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Route
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.greyBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _RouteRow(
                  dot: AppColors.mapPickup,
                  label: booking.from,
                  isDot: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(
                    children: [
                      Container(width: 2, height: 16, color: AppColors.border),
                    ],
                  ),
                ),
                _RouteRow(
                  dot: AppColors.mapDrop,
                  label: booking.to,
                  isDot: false,
                ),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              children: [
                if (booking.rating > 0) ...[
                  RatingStars(rating: booking.rating, size: 14),
                  const SizedBox(width: 4),
                  Text(booking.rating.toStringAsFixed(1),
                      style: AppTextStyles.labelSm),
                ] else ...[
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.error, size: 14),
                  const SizedBox(width: 4),
                  Text('Cancelled', style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.error,
                  )),
                ],
                const Spacer(),
                _FooterAction(
                  label: 'Rebook',
                  icon: Icons.replay_rounded,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _FooterAction(
                  label: 'Invoice',
                  icon: Icons.receipt_outlined,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final Color dot;
  final String label;
  final bool isDot;
  const _RouteRow({required this.dot, required this.label, required this.isDot});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        isDot
            ? Container(
                width: 10, height: 10,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              )
            : Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: dot, borderRadius: BorderRadius.circular(2),
                ),
              ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: AppTextStyles.bodyMd, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _FooterAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _FooterAction({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.greyBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.labelSm.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 72, color: AppColors.border),
          const SizedBox(height: 16),
          Text('No ${filter == 'all' ? '' : filter} bookings yet',
              style: AppTextStyles.h4),
          const SizedBox(height: 8),
          Text('Your ride history will appear here',
              style: AppTextStyles.bodyMd, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Booking {
  final String id, type, from, to, date, time, fare, status, driver;
  final double rating;
  const _Booking({
    required this.id, required this.type, required this.from, required this.to,
    required this.date, required this.time, required this.fare,
    required this.status, required this.driver, required this.rating,
  });
}
