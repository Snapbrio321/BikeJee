import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../providers/wallet_provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _balanceCtrl;
  late Animation<double> _balanceAnim;

  @override
  void initState() {
    super.initState();
    _balanceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _balanceAnim = CurvedAnimation(parent: _balanceCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _balanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Wallet header
          SliverToBoxAdapter(child: _WalletHeader(balance: wallet.balance, anim: _balanceAnim)),

          // Quick add amounts
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: _QuickAddRow(onAdd: (amount) => _showAddMoney(amount)),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Transactions header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transactions', style: AppTextStyles.h4),
                  TextButton(
                    onPressed: () {},
                    child: Text('View All', style: AppTextStyles.bodyMdOrange),
                  ),
                ],
              ),
            ),
          ),

          // Transaction list — real data from WalletProvider
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: _TransactionTile(tx: _txFrom(wallet.transactions[i])),
              ),
              childCount: wallet.transactions.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // Map a WalletTransaction to the tile's display model
  _Tx _txFrom(WalletTransaction t) {
    IconData icon;
    if (t.label.contains('Added')) {
      icon = Icons.add_circle_rounded;
    } else if (t.label.contains('Parcel')) {
      icon = Icons.inventory_2_rounded;
    } else if (t.label.contains('Referral') || t.label.contains('Bonus')) {
      icon = Icons.card_giftcard_rounded;
    } else if (t.label.contains('Withdraw')) {
      icon = Icons.arrow_upward_rounded;
    } else {
      icon = Icons.electric_bike_rounded;
    }
    final sign = t.isCredit ? '+' : '-';
    return _Tx(
      t.label,
      '$sign₹${t.amount.abs()}',
      _formatTime(t.time),
      icon,
      t.isCredit ? AppColors.success : AppColors.error,
      t.isCredit,
    );
  }

  String _formatTime(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]}, $h:$m $ampm';
  }

  void _showAddMoney(double amount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddMoneySheet(initialAmount: amount),
    );
  }
}

class _WalletHeader extends StatelessWidget {
  final double balance;
  final Animation<double> anim;
  const _WalletHeader({required this.balance, required this.anim});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.walletGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Wallet Balance', style: AppTextStyles.bodyMdWhite),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 5),
                    Text('BikeJee Wallet', style: AppTextStyles.caption.copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: anim,
            builder: (_, __) => Text(
              '₹${(balance * anim.value).toStringAsFixed(0)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _WalletAction(
                  icon: Icons.add_rounded,
                  label: '+ Add Money',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WalletAction(
                  icon: Icons.send_rounded,
                  label: 'Transfer',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WalletAction(
                  icon: Icons.history_rounded,
                  label: 'History',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _WalletAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: AppTextStyles.caption
                    .copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _QuickAddRow extends StatelessWidget {
  final Function(double) onAdd;
  const _QuickAddRow({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Add', style: AppTextStyles.h5),
        const SizedBox(height: 10),
        Row(
          children: [100.0, 200.0, 500.0, 1000.0].map((a) {
            return Expanded(
              child: GestureDetector(
                onTap: () => onAdd(a),
                child: Container(
                  margin: EdgeInsets.only(right: a < 1000 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.greyBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '₹${a.toInt()}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final _Tx tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: tx.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tx.icon, color: tx.color, size: 20),
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
          Text(
            tx.amount,
            style: AppTextStyles.priceSmall.copyWith(
              color: tx.isCredit ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMoneySheet extends StatefulWidget {
  final double initialAmount;
  const _AddMoneySheet({required this.initialAmount});

  @override
  State<_AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<_AddMoneySheet> {
  late TextEditingController _ctrl;
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.initialAmount > 0 ? widget.initialAmount.toInt().toString() : '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _proceed() async {
    final amount = int.tryParse(_ctrl.text) ?? 0;
    if (amount <= 0) return;
    setState(() => _paying = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await context.read<WalletProvider>().addMoney(amount);

    if (!mounted) return;
    setState(() => _paying = false);
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? '₹$amount added to wallet' : 'Payment failed'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('Add Money', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                prefixText: '₹  ',
                prefixStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary),
                hintText: '0',
                filled: true,
                fillColor: AppColors.greyBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            AppGradientButton(
              label: _paying ? 'Processing...' : 'Proceed to Pay',
              onTap: _paying ? null : _proceed,
            ),
          ],
        ),
      ),
    );
  }
}

class _Tx {
  final String label, amount, time;
  final IconData icon;
  final Color color;
  final bool isCredit;
  const _Tx(this.label, this.amount, this.time, this.icon, this.color, this.isCredit);
}
