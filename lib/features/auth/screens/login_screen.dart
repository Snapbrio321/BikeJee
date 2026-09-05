import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  final Function(String phone) onOtpSent;
  final VoidCallback? onBack;

  const LoginScreen({
    super.key,
    required this.role,
    required this.onOtpSent,
    this.onBack,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  bool _isValid = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _phoneController.addListener(() {
      final v = _phoneController.text.length == 10;
      if (v != _isValid) setState(() => _isValid = v);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  bool _sending = false;

  void _sendOtp() async {
    if (!_isValid || _sending) return;
    setState(() => _sending = true);

    final auth = context.read<AuthProvider>();
    // Tell the provider which role is logging in
    auth.setRole(_isDriver ? UserRole.driver : UserRole.customer);

    final ok = await auth.sendOtp(_phoneController.text);

    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) {
      widget.onOtpSent(_phoneController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Failed to send OTP'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  bool get _isDriver => widget.role == 'driver';

  @override
  Widget build(BuildContext context) {
    const headerColor = AppColors.secondary; // Always deep navy

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Container(
              color: headerColor,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: widget.onBack,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Yellow label chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _isDriver ? 'DRIVER PARTNER' : 'CUSTOMER',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondary,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isDriver
                            ? 'Welcome to\nBikeJee Partner'
                            : 'Welcome to\nBikeJee',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isDriver
                            ? 'Earn more. Ride more. Be your own boss.'
                            : 'Ride Fast. Deliver Smart.',
                        style: AppTextStyles.bodyMd
                            .copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── White form area ────────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      Text('Enter Mobile Number',
                          style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                          "We'll send a 4-digit OTP to verify your number",
                          style: AppTextStyles.bodyMd),
                      const SizedBox(height: 22),

                      // Phone input
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.greyBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _isValid
                                ? AppColors.primary
                                : AppColors.border,
                            width: _isValid ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 16),
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                      color: AppColors.border),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🇮🇳',
                                      style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 5),
                                  Text('+91',
                                      style: AppTextStyles.h5.copyWith(
                                          color: AppColors.textMedium)),
                                  const SizedBox(width: 3),
                                  const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: AppColors.textLight),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: AppTextStyles.h4,
                                decoration: InputDecoration(
                                  hintText: 'Mobile number',
                                  hintStyle: AppTextStyles.bodyMd,
                                  border: InputBorder.none,
                                  filled: false,
                                  counterText: '',
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 14),
                                ),
                              ),
                            ),
                            if (_isValid)
                              const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.success,
                                    size: 20),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // CTA button — green
                      GestureDetector(
                        onTap: _isValid ? _sendOtp : null,
                        child: Container(
                          height: 52,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _isValid ? AppColors.primary : AppColors.border,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_sending) ...[
                                const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                                ),
                              ] else ...[
                                Text(
                                  'Get OTP',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _isValid
                                        ? Colors.white
                                        : AppColors.textLight,
                                  ),
                                ),
                                if (_isValid) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded,
                                      color: Colors.white, size: 18),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14),
                            child: Text('or',
                                style: AppTextStyles.bodySm),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _SocialBtn(
                              label: 'Google',
                              icon: Icons.g_mobiledata_rounded,
                              color: const Color(0xFFDB4437),
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SocialBtn(
                              label: 'Apple',
                              icon: Icons.apple_rounded,
                              color: Colors.black,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTextStyles.bodySm,
                            children: [
                              const TextSpan(
                                  text: 'By continuing you agree to our '),
                              TextSpan(
                                text: 'Terms',
                                style: AppTextStyles.bodyMdOrange
                                    .copyWith(fontSize: 12),
                              ),
                              const TextSpan(text: ' & '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: AppTextStyles.bodyMdOrange
                                    .copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SocialBtn(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.greyBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 7),
            Text(label, style: AppTextStyles.h5),
          ],
        ),
      ),
    );
  }
}
