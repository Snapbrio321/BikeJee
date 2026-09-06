import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/wallet_provider.dart';

class CustomerProfileScreen extends StatelessWidget {
  final VoidCallback? onLogout;
  const CustomerProfileScreen({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverToBoxAdapter(
            child: _ProfileHeader(),
          ),

          // Stats row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _StatsRow(),
            ),
          ),

          // Menu sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MenuSection(
                    title: 'Account',
                    items: [
                      _MenuItem(Icons.person_rounded, 'Personal Information', AppColors.primary, () {}),
                      _MenuItem(Icons.location_on_rounded, 'Saved Places', AppColors.info, () {}),
                      _MenuItem(Icons.payment_rounded, 'Payment Methods', AppColors.primary, () {}),
                      _MenuItem(Icons.tune_rounded, 'Ride Preferences', AppColors.warning, () {}),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _MenuSection(
                    title: 'Rewards',
                    items: [
                      _MenuItem(Icons.card_giftcard_rounded, 'Refer & Earn', AppColors.success, () {}),
                      _MenuItem(Icons.local_offer_rounded, 'My Offers', AppColors.primary, () {}),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _MenuSection(
                    title: 'Support',
                    items: [
                      _MenuItem(Icons.headset_mic_rounded, 'Help & Support', AppColors.info, () {}),
                      _MenuItem(Icons.info_rounded, 'About BikeJee', AppColors.textMedium, () {}),
                      _MenuItem(Icons.star_rounded, 'Rate the App', AppColors.starColor, () {}),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Logout
                  AppButton(
                    label: 'Log Out',
                    variant: AppButtonVariant.outline,
                    customColor: AppColors.error,
                    onTap: onLogout,
                    prefixIcon: Icons.logout_rounded,
                    height: 50,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Profile',
                  style: AppTextStyles.h3White),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 48),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.primary, size: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Builder(builder: (context) {
            final user = context.watch<AuthProvider>().user;
            return Column(
              children: [
                Text(
                  (user?.name.isNotEmpty ?? false) ? user!.name : 'BikeJee User',
                  style: AppTextStyles.h3White,
                ),
                const SizedBox(height: 4),
                Text(
                  user != null ? '+91 ${user.phone}' : '',
                  style: AppTextStyles.bodyMdWhite,
                ),
                const SizedBox(height: 4),
                if (user?.isVerified ?? false)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('✓  Verified Account',
                        style: AppTextStyles.caption.copyWith(color: Colors.white)),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Builder(builder: (context) {
        final user = context.watch<AuthProvider>().user;
        final wallet = context.watch<WalletProvider>();
        return Row(
          children: [
            _Stat('${user?.totalRides ?? 0}', 'Total Rides'),
            _VertDivider(),
            _Stat((user?.rating ?? 0).toStringAsFixed(1), 'Avg Rating'),
            _VertDivider(),
            _Stat('₹${wallet.balance.toInt()}', 'Wallet'),
            _VertDivider(),
            _Stat('3', 'Referrals'),
          ],
        );
      }),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: AppColors.border);
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h5.copyWith(color: AppColors.textLight)),
        const SizedBox(height: 10),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.asMap().entries.map((e) {
              return Column(
                children: [
                  _MenuTile(item: e.value),
                  if (e.key < items.length - 1)
                    const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(item.label, style: AppTextStyles.bodyLg)),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.color, this.onTap);
}
