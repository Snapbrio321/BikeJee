import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _tabs = ['Daily', 'Weekly', 'Monthly'];

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

  static const _dailyData = [
    _EarningDay('20 May 2024', '₹1,420', '12', Icons.electric_bike_rounded),
    _EarningDay('19 May 2024', '₹1,650', '14', Icons.electric_bike_rounded),
    _EarningDay('18 May 2024', '₹1,310', '11', Icons.electric_bike_rounded),
    _EarningDay('17 May 2024', '₹980',  '8',  Icons.electric_bike_rounded),
    _EarningDay('16 May 2024', '₹1,500', '13', Icons.electric_bike_rounded),
    _EarningDay('15 May 2024', '₹960',  '9',  Icons.electric_bike_rounded),
  ];

  static const _txData = [
    _EarTx('Fare Earnings', '+₹1,200', '20 May, 10:33 AM', AppColors.success, true),
    _EarTx('Incentive', '+₹150',    '20 May, 09:00 AM', AppColors.warning, true),
    _EarTx('Tip',        '+₹70',    '20 May, 08:45 AM', AppColors.info, true),
    _EarTx('Fare Earnings', '+₹1,450', '19 May, 11:20 AM', AppColors.success, true),
    _EarTx('Fare Earnings', '+₹980', '18 May, 07:15 AM', AppColors.success, true),
    _EarTx('Withdrawal', '-₹2,000', '17 May, 05:00 PM', AppColors.error, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildTabBar()),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _EarningsTab(
              totalLabel: '₹1,420',
              ridesLabel: '12 Rides',
              barData: [0.9, 0.7, 1.0, 0.6, 0.85, 0.5, 0.75],
              historyData: _dailyData,
              txData: _txData,
            ),
            _EarningsTab(
              totalLabel: '₹8,820',
              ridesLabel: '72 Rides',
              barData: [0.7, 0.8, 0.6, 0.9, 0.75, 0.65, 0.85],
              historyData: _dailyData,
              txData: _txData,
            ),
            _EarningsTab(
              totalLabel: '₹32,450',
              ridesLabel: '280 Rides',
              barData: [0.6, 0.75, 0.8, 0.7, 0.9, 0.65, 0.85],
              historyData: _dailyData,
              txData: _txData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Earnings', style: AppTextStyles.h3White),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _EarStat('Today', '₹1,420', AppColors.success),
              ),
              Container(width: 1, height: 48, color: Colors.white12),
              Expanded(
                child: _EarStat('This Week', '₹8,820', AppColors.warning),
              ),
              Container(width: 1, height: 48, color: Colors.white12),
              Expanded(
                child: _EarStat('This Month', '₹32,450', AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabCtrl,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMedium,
        labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}

class _EarStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _EarStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w700, color: color,
            )),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white54)),
      ],
    );
  }
}

class _EarningsTab extends StatelessWidget {
  final String totalLabel, ridesLabel;
  final List<double> barData;
  final List<_EarningDay> historyData;
  final List<_EarTx> txData;

  const _EarningsTab({
    required this.totalLabel,
    required this.ridesLabel,
    required this.barData,
    required this.historyData,
    required this.txData,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Bar chart
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(totalLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 26, fontWeight: FontWeight.w800,
                            color: AppColors.success,
                          )),
                      Text('$ridesLabel · Incentive ₹150',
                          style: AppTextStyles.bodySm),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up_rounded,
                            color: AppColors.success, size: 14),
                        const SizedBox(width: 4),
                        Text('+12%', style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.success)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Bar chart
              SizedBox(
                height: 90,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: barData.asMap().entries.map((e) {
                    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    final isToday = e.key == 0;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 400 + e.key * 60),
                              height: 64 * e.value,
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppColors.success
                                    : AppColors.success.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(days[e.key],
                                style: AppTextStyles.caption.copyWith(
                                  color: isToday
                                      ? AppColors.success
                                      : AppColors.textLight,
                                  fontWeight: isToday
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                )),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        Text('Earning History', style: AppTextStyles.h4),
        const SizedBox(height: 12),
        ...historyData.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(d.icon, color: AppColors.success, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.date, style: AppTextStyles.h5),
                          Text('${d.rides} Rides', style: AppTextStyles.bodySm),
                        ],
                      ),
                    ),
                    Text(d.amount,
                        style: AppTextStyles.priceSmall.copyWith(
                            color: AppColors.success)),
                  ],
                ),
              ),
            )),

        const SizedBox(height: 20),
        Text('Recent Transactions', style: AppTextStyles.h4),
        const SizedBox(height: 12),
        ...txData.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: t.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        t.isCredit
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: t.color, size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.label, style: AppTextStyles.h5),
                          Text(t.time, style: AppTextStyles.bodySm),
                        ],
                      ),
                    ),
                    Text(t.amount,
                        style: AppTextStyles.priceSmall.copyWith(color: t.color)),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _EarningDay {
  final String date, amount, rides;
  final IconData icon;
  const _EarningDay(this.date, this.amount, this.rides, this.icon);
}

class _EarTx {
  final String label, amount, time;
  final Color color;
  final bool isCredit;
  const _EarTx(this.label, this.amount, this.time, this.color, this.isCredit);
}
