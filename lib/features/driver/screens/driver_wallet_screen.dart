import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';

class DriverWalletScreen extends StatefulWidget {
  const DriverWalletScreen({super.key});

  @override
  State<DriverWalletScreen> createState() => _DriverWalletScreenState();
}

class _DriverWalletScreenState extends State<DriverWalletScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  final double _balance = 320;
  final double _available = 320;
  final _amountCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _amountCtrl.dispose();
    _upiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildWalletCard()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickAmount(label: '₹100', onTap: () => _showWithdrawSheet(100)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickAmount(label: '₹300', onTap: () => _showWithdrawSheet(300)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickAmount(label: '₹500', onTap: () => _showWithdrawSheet(500)),
                  ),
                ],
              ),
            ),
          ),

          // Transactions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Transactions', style: AppTextStyles.h4),
                  TextButton(
                    onPressed: () {},
                    child: Text('View All', style: AppTextStyles.bodyMdOrange),
                  ),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: _WalletTx(tx: _transactions[i]),
              ),
              childCount: _transactions.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Current Balance', style: AppTextStyles.bodyMdWhite),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.success, shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text('Active', style: AppTextStyles.caption.copyWith(color: AppColors.success)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Text(
              '₹${(_balance * _anim.value).toStringAsFixed(0)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success, shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text('Available: ₹$_available',
                  style: AppTextStyles.bodySmWhite),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _CardAction(
                  Icons.add_rounded, 'Add Money',
                  onTap: () => _showAddSheet(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CardAction(
                  Icons.arrow_upward_rounded, 'Withdraw',
                  onTap: () => _showWithdrawSheet(0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddMoneySheet(),
    );
  }

  void _showWithdrawSheet(double amount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _WithdrawSheet(initialAmount: amount),
    );
  }

  static final _transactions = [
    _WTx('Added Money', '+₹200', '20 May, 10:33 AM', AppColors.success, true),
    _WTx('Ride Earnings', '+₹120', '20 May, 09:15 AM', AppColors.success, true),
    _WTx('Incentive', '+₹30', '20 May, 08:30 AM', AppColors.warning, true),
    _WTx('Withdrawal', '-₹1,00', '19 May, 05:00 PM', AppColors.error, false),
    _WTx('Ride Earnings', '+₹450', '18 May, 10:20 AM', AppColors.success, true),
  ];
}

class _CardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _CardAction(this.icon, this.label, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.labelMd.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _QuickAmount extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickAmount({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
      ),
    );
  }
}

class _WalletTx extends StatelessWidget {
  final _WTx tx;
  const _WalletTx({required this.tx});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: tx.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              tx.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: tx.color, size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.label, style: AppTextStyles.h5),
                Text(tx.time, style: AppTextStyles.bodySm),
              ],
            ),
          ),
          Text(tx.amount,
              style: AppTextStyles.priceSmall.copyWith(color: tx.color)),
        ],
      ),
    );
  }
}

class _AddMoneySheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            ),
            Text('Add Money to Wallet', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                prefixText: '₹  ',
                prefixStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.primary),
                hintText: '0',
                filled: true, fillColor: AppColors.greyBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            AppGradientButton(
              label: 'Proceed',
              onTap: () => Navigator.pop(context),
              gradient: AppColors.darkGradient,
            ),
          ],
        ),
      ),
    );
  }
}

class _WithdrawSheet extends StatelessWidget {
  final double initialAmount;
  const _WithdrawSheet({required this.initialAmount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            ),
            Text('Withdraw', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text('Available: ₹320', style: AppTextStyles.bodyMd.copyWith(color: AppColors.success)),
            const SizedBox(height: 16),
            TextField(
              controller: initialAmount > 0
                  ? TextEditingController(text: initialAmount.toInt().toString())
                  : null,
              keyboardType: TextInputType.number,
              style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                prefixText: '₹  ',
                prefixStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.primary),
                hintText: '0',
                filled: true, fillColor: AppColors.greyBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter UPI ID',
                hintStyle: AppTextStyles.bodyMd,
                filled: true, fillColor: AppColors.greyBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.qr_code_rounded, size: 20, color: AppColors.textLight),
              ),
            ),
            const SizedBox(height: 20),
            AppGradientButton(
              label: 'Withdraw Now',
              onTap: () => Navigator.pop(context),
              gradient: AppColors.darkGradient,
            ),
          ],
        ),
      ),
    );
  }
}

class _WTx {
  final String label, amount, time;
  final Color color;
  final bool isCredit;
  const _WTx(this.label, this.amount, this.time, this.color, this.isCredit);
}
