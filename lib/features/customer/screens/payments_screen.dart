import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String _selected = 'Cash';

  final _methods = [
    _PayMethod('Cash', Icons.money_rounded, Colors.green, null, true),
    _PayMethod('UPI', Icons.qr_code_scanner_rounded, Colors.deepPurple,
        'Google Pay, PhonePe, Paytm', false),
    _PayMethod('Card', Icons.credit_card_rounded, AppColors.info,
        'Visa, Mastercard, RuPay', false),
    _PayMethod('BikeJee Wallet', Icons.account_balance_wallet_rounded,
        AppColors.primary, 'Balance: ₹320', false),
    _PayMethod(
        'Net Banking', Icons.account_balance_rounded, Colors.teal, null, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Select Payment Method')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Recommended
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.secondary, AppColors.secondaryLight]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BikeJee Wallet', style: AppTextStyles.h5White),
                      Text('Balance: ₹320',
                          style: AppTextStyles.bodySmWhite),
                      Text('Fastest & easiest way to pay',
                          style: AppTextStyles.caption.copyWith(color: Colors.white38)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Use', style: AppTextStyles.btnMd),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Text('Other Methods', style: AppTextStyles.h4),
          const SizedBox(height: 12),

          ..._methods.map((m) {
            final isSelected = _selected == m.label;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selected = m.label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.06)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: m.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(m.icon, color: m.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.label, style: AppTextStyles.h5),
                            if (m.subtitle != null)
                              Text(m.subtitle!,
                                  style: AppTextStyles.bodySm),
                            if (m.isPopular)
                              Container(
                                margin: const EdgeInsets.only(top: 3),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Most Popular',
                                    style: AppTextStyles.caption
                                        .copyWith(color: AppColors.success)),
                              ),
                          ],
                        ),
                      ),
                      // Radio
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: 2,
                          ),
                          color: isSelected ? AppColors.primary : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 13)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 8),

          // UPI ID field
          if (_selected == 'UPI') ...[
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enter UPI ID', style: AppTextStyles.h5),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'yourname@upi',
                      hintStyle: AppTextStyles.bodyMd,
                      filled: true,
                      fillColor: AppColors.greyBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: TextButton(
                        onPressed: () {},
                        child: Text('Verify',
                            style: AppTextStyles.bodyMdOrange),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          AppGradientButton(label: 'Confirm Payment', onTap: () {}),
        ],
      ),
    );
  }
}

class _PayMethod {
  final String label;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final bool isPopular;
  const _PayMethod(this.label, this.icon, this.color, this.subtitle, this.isPopular);
}
