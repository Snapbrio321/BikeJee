import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/bikejee_logo.dart';

class DriverWelcomeScreen extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback? onBack;
  const DriverWelcomeScreen({super.key, required this.onLogin, this.onBack});

  @override
  State<DriverWelcomeScreen> createState() => _DriverWelcomeScreenState();
}

class _DriverWelcomeScreenState extends State<DriverWelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroCtrl;
  late AnimationController _floatCtrl;
  late Animation<double> _fadeIn;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _fadeIn = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _float = Tween<double>(begin: -8, end: 8)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _heroCtrl.forward();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.secondary, AppColors.secondaryLight, AppColors.secondary],
          ),
        ),
        child: Stack(
          children: [
            // Background blobs
            Positioned(
              top: -60, right: -60,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              bottom: 60, left: -80,
              child: Container(
                width: 240, height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withOpacity(0.05),
                ),
              ),
            ),
            // Main scrollable content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // ── Header ──────────────────────────────────
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const BikeJeeLogo(darkBg: true),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.success.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: AppColors.success
                                            .withOpacity(0.4)),
                                  ),
                                  child: Text('Driver Partner',
                                      style: AppTextStyles.labelSm
                                          .copyWith(
                                              color: AppColors.success)),
                                ),
                              ],
                            ),
                          ),

                          // ── Hero icon ────────────────────────────────
                          Expanded(
                            child: Center(
                              child: AnimatedBuilder(
                                animation: _float,
                                builder: (_, __) => Transform.translate(
                                  offset: Offset(0, _float.value),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 150,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primary
                                                  .withOpacity(0.25),
                                              AppColors.primary
                                                  .withOpacity(0.05),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.electric_bike_rounded,
                                          color: AppColors.primary,
                                          size: 72,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.success
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: AppColors.success
                                                  .withOpacity(0.3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                                Icons.trending_up_rounded,
                                                color: AppColors.success,
                                                size: 16),
                                            const SizedBox(width: 6),
                                            Text('Earn ₹1,000+ daily',
                                                style: AppTextStyles.labelMd
                                                    .copyWith(
                                                        color:
                                                            AppColors.success)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // ── Bottom card ──────────────────────────────
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(32)),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Welcome to\nBikeJee Partner',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Earn more. Ride more. Be your own boss.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMdWhite,
                                ),
                                const SizedBox(height: 20),

                                // Perks row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: const [
                                    _Perk(Icons.repeat_rounded,
                                        'Unlimited\nRides'),
                                    _Perk(Icons.block_rounded,
                                        'No\nCommission'),
                                    _Perk(Icons.trending_up_rounded,
                                        'Higher\nEarnings'),
                                    _Perk(Icons.support_agent_rounded,
                                        'Priority\nSupport'),
                                  ],
                                ),
                                const SizedBox(height: 22),

                                AppGradientButton(
                                  label: 'Login / Register',
                                  onTap: widget.onLogin,
                                  prefixIcon: Icons.login_rounded,
                                ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: widget.onLogin,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.phone_android_rounded,
                                          color: Colors.white54, size: 15),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Continue with Phone',
                                        style: AppTextStyles.bodyMd
                                            .copyWith(color: Colors.white54),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'By continuing, you agree to our Terms & Conditions\nand Privacy Policy',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.caption
                                      .copyWith(color: Colors.white24),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Perk extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Perk(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption
              .copyWith(color: Colors.white60, height: 1.4),
        ),
      ],
    );
  }
}
