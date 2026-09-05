import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class CustomerBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Home', isActive: currentIndex == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.receipt_long_rounded, label: 'Bookings', isActive: currentIndex == 1, onTap: () => onTap(1)),
              _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Wallet', isActive: currentIndex == 2, onTap: () => onTap(2)),
              _NavItem(icon: Icons.local_offer_rounded, label: 'Offers', isActive: currentIndex == 3, onTap: () => onTap(3)),
              _NavItem(icon: Icons.person_rounded, label: 'Profile', isActive: currentIndex == 4, onTap: () => onTap(4)),
            ],
          ),
        ),
      ),
    );
  }
}

class DriverBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DriverBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', isActive: currentIndex == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.bar_chart_rounded, label: 'Earnings', isActive: currentIndex == 1, onTap: () => onTap(1)),
              _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Wallet', isActive: currentIndex == 2, onTap: () => onTap(2)),
              _NavItem(icon: Icons.headset_mic_rounded, label: 'Support', isActive: currentIndex == 3, onTap: () => onTap(3)),
              _NavItem(icon: Icons.person_rounded, label: 'Profile', isActive: currentIndex == 4, onTap: () => onTap(4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isActive ? AppColors.primary : AppColors.navInactive,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppColors.primary : AppColors.navInactive,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
