import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';

class DriverSubscriptionScreen extends StatefulWidget {
  final VoidCallback? onActivated;
  final VoidCallback? onBack;
  const DriverSubscriptionScreen({super.key, this.onActivated, this.onBack});

  @override
  State<DriverSubscriptionScreen> createState() => _DriverSubscriptionScreenState();
}

class _DriverSubscriptionScreenState extends State<DriverSubscriptionScreen> {
  String _selectedPlan = 'daily';
  String _selectedPayment = 'UPI';
  int _step = 0; // 0=plan, 1=payment, 2=success

  final _plans = [
    _Plan('daily', 'Daily Plan', '₹39', '/ Day', '24 Hours', [
      'Unlimited rides for 24 hours',
      'No commission on rides',
      'Priority support',
    ]),
    _Plan('weekly', 'Weekly Plan', '₹199', '/ Week', '7 Days', [
      'Unlimited rides for 7 days',
      'No commission on rides',
      'Priority support',
      'Save ₹74 vs daily',
    ]),
    _Plan('monthly', 'Monthly Plan', '₹599', '/ Month', '30 Days', [
      'Unlimited rides for 30 days',
      'No commission on rides',
      'Priority support',
      'Save ₹570 vs daily',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    if (_step == 2) return _SuccessScreen(onDone: widget.onActivated);
    if (_step == 1) {
      return _PaymentScreen(
        plan: _plans.firstWhere((p) => p.id == _selectedPlan),
        selectedPayment: _selectedPayment,
        onPaymentSelected: (p) => setState(() => _selectedPayment = p),
        onPay: () => setState(() => _step = 2),
        onBack: () => setState(() => _step = 0),
      );
    }
    return _PlanSelectScreen(
      plans: _plans,
      selectedPlan: _selectedPlan,
      onSelected: (id) => setState(() => _selectedPlan = id),
      onContinue: () => setState(() => _step = 1),
      onBack: widget.onBack,
    );
  }
}

class _PlanSelectScreen extends StatelessWidget {
  final List<_Plan> plans;
  final String selectedPlan;
  final Function(String) onSelected;
  final VoidCallback onContinue;
  final VoidCallback? onBack;
  const _PlanSelectScreen({
    required this.plans, required this.selectedPlan,
    required this.onSelected, required this.onContinue, this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Subscription Plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBack,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Hero
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.secondary, AppColors.secondaryLight],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.electric_bike_rounded,
                                color: AppColors.primary, size: 30),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('BikeJee Partner', style: AppTextStyles.h4White),
                              Text('Choose your plan', style: AppTextStyles.bodySmWhite),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _BenefitChip(Icons.repeat_rounded, 'Unlimited'),
                          _BenefitChip(Icons.block_rounded, 'No Commission'),
                          _BenefitChip(Icons.trending_up_rounded, 'Earn More'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text('Select Plan', style: AppTextStyles.h4),
                const SizedBox(height: 12),

                ...plans.map((plan) {
                  final isSelected = selectedPlan == plan.id;
                  final isPopular = plan.id == 'daily';
                  return GestureDetector(
                    onTap: () => onSelected(plan.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.07)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 0.8,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: AppColors.primary.withOpacity(0.12),
                                blurRadius: 16, offset: const Offset(0, 4))]
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(plan.name, style: AppTextStyles.h4),
                                        if (isPopular) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.success,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text('Popular',
                                                style: AppTextStyles.caption.copyWith(color: Colors.white)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text('Valid for ${plan.duration}',
                                        style: AppTextStyles.bodySm),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: plan.price,
                                      style: GoogleFonts.poppins(
                                        fontSize: 26, fontWeight: FontWeight.w800,
                                        color: isSelected ? AppColors.primary : AppColors.textDark,
                                      ),
                                    ),
                                    TextSpan(
                                      text: plan.period,
                                      style: AppTextStyles.bodySm,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...plan.benefits.map((b) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: isSelected ? AppColors.primary : AppColors.success,
                                    size: 15),
                                const SizedBox(width: 8),
                                Text(b, style: AppTextStyles.bodyMd),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06),
                    blurRadius: 16, offset: const Offset(0, -4)),
              ],
            ),
            child: AppGradientButton(
              label: 'Continue to Payment',
              onTap: onContinue,
              prefixIcon: Icons.arrow_forward_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentScreen extends StatelessWidget {
  final _Plan plan;
  final String selectedPayment;
  final Function(String) onPaymentSelected;
  final VoidCallback onPay;
  final VoidCallback onBack;
  const _PaymentScreen({
    required this.plan, required this.selectedPayment,
    required this.onPaymentSelected, required this.onPay, required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final methods = [
      ('UPI', Icons.qr_code_scanner_rounded, Colors.deepPurple),
      ('PhonePe', Icons.phone_android_rounded, Color(0xFF5F259F)),
      ('GooglePay', Icons.g_mobiledata_rounded, Color(0xFF4285F4)),
      ('Paytm', Icons.account_balance_wallet_rounded, Color(0xFF00BAF2)),
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBack,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Summary', style: AppTextStyles.h4),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(plan.name, style: AppTextStyles.bodyMd),
                          Text(plan.price, style: AppTextStyles.priceSmall),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Plan Type', style: AppTextStyles.bodyMd),
                          Text(plan.duration, style: AppTextStyles.labelLg),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Valid Till', style: AppTextStyles.bodyMd),
                          Text('20 May 2024, 11:59 PM', style: AppTextStyles.labelLg),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: AppTextStyles.h4),
                          Text(plan.price,
                              style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Payment Methods', style: AppTextStyles.h4),
                const SizedBox(height: 12),
                ...methods.map((m) {
                  final isSelected = selectedPayment == m.$1;
                  return GestureDetector(
                    onTap: () => onPaymentSelected(m.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.06) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 1.5 : 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(m.$2, color: m.$3, size: 24),
                          const SizedBox(width: 12),
                          Expanded(child: Text(m.$1, style: AppTextStyles.h5)),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary, size: 20),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06),
                    blurRadius: 16, offset: const Offset(0, -4)),
              ],
            ),
            child: AppGradientButton(
              label: 'Pay ${plan.price}',
              onTap: onPay,
              prefixIcon: Icons.lock_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessScreen extends StatefulWidget {
  final VoidCallback? onDone;
  const _SuccessScreen({this.onDone});

  @override
  State<_SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<_SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 120, height: 120,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.successGradient),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.success,
                          blurRadius: 30, spreadRadius: -6, offset: Offset(0, 10)),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 64),
                ),
              ),
              const SizedBox(height: 28),
              Text('Plan Activated\nSuccessfully!',
                  textAlign: TextAlign.center, style: AppTextStyles.h2),
              const SizedBox(height: 10),
              Text('You can now ride unlimited for the next 24 hours!',
                  textAlign: TextAlign.center, style: AppTextStyles.bodyMd),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.greyBg, borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Text('Expires: 20 May 2024, 11:59 PM',
                        style: AppTextStyles.bodyMd),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              AppGradientButton(
                label: 'Go to Dashboard',
                onTap: widget.onDone,
                gradient: AppColors.darkGradient,
              ),
            ],
          ),
        ),
      );
  }
}

class _BenefitChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _BenefitChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.success, size: 14),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.labelSm.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _Plan {
  final String id, name, price, period, duration;
  final List<String> benefits;
  const _Plan(this.id, this.name, this.price, this.period, this.duration, this.benefits);
}
