import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/bikejee_logo.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardPage> _pages = const [
    _OnboardPage(
      icon: Icons.electric_bike_rounded,
      color: AppColors.primary,
      bgColor: Color(0xFFFFF3E0),
      title: 'Quick & Affordable\nBike Rides',
      subtitle: 'Book a bike ride in seconds. Skip the traffic and reach your destination faster than ever.',
    ),
    _OnboardPage(
      icon: Icons.local_shipping_rounded,
      color: Color(0xFF7C4DFF),
      bgColor: Color(0xFFF3E5F5),
      title: 'Door-to-Door\nParcel Delivery',
      subtitle: 'Send anything anywhere with real-time tracking. Safe, fast, and reliable parcel delivery.',
    ),
    _OnboardPage(
      icon: Icons.track_changes_rounded,
      color: AppColors.success,
      bgColor: Color(0xFFE8F5E9),
      title: 'Live Tracking &\nSafe Rides',
      subtitle: 'Track your ride in real-time, share your live location with family, and ride safely always.',
    ),
    _OnboardPage(
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF2979FF),
      bgColor: Color(0xFFE3F2FD),
      title: 'Multiple Payment\nOptions',
      subtitle: 'Pay with UPI, wallet, card, or cash. Earn rewards with every ride and save more.',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onDone();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ClipRect(
          child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BikeJeeLogo(),
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: widget.onDone,
                      child: Text('Skip', style: AppTextStyles.bodyMdOrange),
                    )
                  else
                    const SizedBox(height: 36),
                ],
              ),
            ),

            // Page content — Flexible so it never hard-overflows during resize
            Flexible(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(page: _pages[index], size: size);
                },
              ),
            ),

            // Bottom area
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == i ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? AppColors.secondary
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppGradientButton(
                      label: _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next →',
                      onTap: _next,
                      gradient: AppColors.darkGradient,
                    ),
                  ],
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatefulWidget {
  final _OnboardPage page;
  final Size size;

  const _OnboardingPage({required this.page, required this.size});

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.page;
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Animated icon
            AnimatedBuilder(
              animation: _float,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _float.value),
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: p.bgColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: p.color.withOpacity(0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Icon(p.icon, size: 72, color: p.color),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              p.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              p.subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(height: 1.6),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String subtitle;

  const _OnboardPage({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.subtitle,
  });
}
