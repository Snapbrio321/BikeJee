import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _tabs = ['All Offers', 'Ride', 'Parcel'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.primary,
            title: const Text('Offers for you',
                style: TextStyle(color: Colors.white)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 28,
                      left: 20,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.local_offer_rounded,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Exclusive Deals',
                                  style: AppTextStyles.h4White),
                              Text('Save big on every ride & delivery',
                                  style: AppTextStyles.bodySmWhite),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabCtrl,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textMedium,
                  labelStyle: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _OfferList(filter: 'all'),
            _OfferList(filter: 'ride'),
            _OfferList(filter: 'parcel'),
          ],
        ),
      ),
    );
  }
}

class _OfferList extends StatelessWidget {
  final String filter;
  const _OfferList({required this.filter});

  static final _offers = [
    _Offer(
      title: '20% OFF',
      subtitle: 'On your first 3 rides',
      code: 'BIKEJEE20',
      expiry: 'Valid Till: 31 May 2024',
      type: 'ride',
      color: AppColors.primary,
      bgColor: Color(0xFFFFF3E0),
      icon: Icons.electric_bike_rounded,
      isHighlight: true,
    ),
    _Offer(
      title: 'FLAT ₹30 OFF',
      subtitle: 'On parcel delivery',
      code: 'PARCEL30',
      expiry: 'Valid Till: 31 May 2024',
      type: 'parcel',
      color: AppColors.primary,
      bgColor: Color(0xFFF3E5F5),
      icon: Icons.inventory_2_rounded,
      isHighlight: false,
    ),
    _Offer(
      title: 'UPTO 15% OFF',
      subtitle: 'On Auto rides',
      code: 'AUTO15',
      expiry: 'Valid Till: 15 Jun 2024',
      type: 'ride',
      color: AppColors.info,
      bgColor: Color(0xFFE3F2FD),
      icon: Icons.airport_shuttle_rounded,
      isHighlight: false,
    ),
    _Offer(
      title: 'FREE RIDE',
      subtitle: 'Refer a friend & earn a free ride',
      code: 'REFER50',
      expiry: 'No Expiry',
      type: 'ride',
      color: AppColors.success,
      bgColor: Color(0xFFE8F5E9),
      icon: Icons.card_giftcard_rounded,
      isHighlight: false,
    ),
    _Offer(
      title: '₹50 CASHBACK',
      subtitle: 'On first wallet recharge of ₹200+',
      code: 'WALLET50',
      expiry: 'Valid Till: 30 Jun 2024',
      type: 'parcel',
      color: AppColors.warning,
      bgColor: Color(0xFFFFF8E1),
      icon: Icons.account_balance_wallet_rounded,
      isHighlight: false,
    ),
  ];

  List<_Offer> get _filtered =>
      filter == 'all' ? _offers : _offers.where((o) => o.type == filter).toList();

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _OfferCard(offer: items[i]),
    );
  }
}

class _OfferCard extends StatefulWidget {
  final _Offer offer;
  const _OfferCard({required this.offer});

  @override
  State<_OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<_OfferCard> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.offer.code));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.offer;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: o.isHighlight ? o.color : AppColors.border,
              width: o.isHighlight ? 1.5 : 0.8,
            ),
            boxShadow: o.isHighlight
                ? [
                    BoxShadow(
                      color: o.color.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Column(
            children: [
              // Top banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: o.bgColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: o.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(o.icon, color: o.color, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            o.title,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: o.color,
                            ),
                          ),
                          Text(o.subtitle, style: AppTextStyles.bodyMd),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom: code + expiry + button
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dashed code box
                          GestureDetector(
                            onTap: _copy,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: o.color.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: o.color.withOpacity(0.4),
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    o.code,
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: o.color,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _copied ? Icons.check_rounded : Icons.copy_rounded,
                                    color: o.color,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(o.expiry, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _copy,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: _copied ? AppColors.success : o.color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _copied ? 'Copied!' : 'Apply',
                          style: AppTextStyles.btnMd,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (o.isHighlight)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: o.color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('HOT DEAL',
                  style: AppTextStyles.caption
                      .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
      ],
    );
  }
}

class _Offer {
  final String title, subtitle, code, expiry, type;
  final Color color, bgColor;
  final IconData icon;
  final bool isHighlight;
  const _Offer({
    required this.title, required this.subtitle, required this.code,
    required this.expiry, required this.type, required this.color,
    required this.bgColor, required this.icon, required this.isHighlight,
  });
}
