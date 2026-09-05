import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String role;
  final VoidCallback onVerified;
  final VoidCallback? onBack;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.role,
    required this.onVerified,
    this.onBack,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isLoading = false;
  bool _isError = false;
  int _resendSeconds = 30;
  Timer? _timer;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(_shakeCtrl);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds == 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    _shakeCtrl.dispose();
    super.dispose();
  }

  String get _otp =>
      _controllers.map((c) => c.text).join();

  void _onDigitInput(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
    if (_otp.length == 4) _verify();
    setState(() {});
  }

  void _verify() async {
    if (_otp.length != 4) return;
    setState(() { _isLoading = true; _isError = false; });
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // Demo: accept any 4 digits except "0000"
    if (_otp == '0000') {
      setState(() { _isLoading = false; _isError = true; });
      _shakeCtrl.forward(from: 0);
      for (final c in _controllers) { c.clear(); }
      if (mounted) FocusScope.of(context).requestFocus(_focusNodes[0]);
    } else {
      setState(() => _isLoading = false);
      widget.onVerified();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDriver = widget.role == 'driver';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDriver
                      ? AppColors.darkGradient
                      : AppColors.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isDriver
                        ? AppColors.secondary
                        : AppColors.primary).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.sms_outlined,
                color: Colors.white,
                size: 42,
              ),
            ),

            const SizedBox(height: 28),

            Text('Enter OTP', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyles.bodyMd.copyWith(height: 1.5),
                children: [
                  const TextSpan(text: 'Enter the 4-digit code sent to\n'),
                  TextSpan(
                    text: '+91 ${widget.phone}',
                    style: AppTextStyles.h5,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // OTP boxes
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(_shakeAnim.value, 0),
                child: child,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final isFilled = _controllers[i].text.isNotEmpty;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 64,
                    height: 68,
                    decoration: BoxDecoration(
                      color: _isError
                          ? AppColors.error.withOpacity(0.06)
                          : isFilled
                              ? AppColors.primary.withOpacity(0.08)
                              : AppColors.greyBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isError
                            ? AppColors.error
                            : isFilled
                                ? AppColors.primary
                                : AppColors.border,
                        width: isFilled || _isError ? 1.5 : 1,
                      ),
                    ),
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _isError ? AppColors.error : AppColors.textDark,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                        filled: false,
                      ),
                      onChanged: (v) => _onDigitInput(i, v),
                    ),
                  );
                }),
              ),
            ),

            if (_isError) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.error, size: 16),
                  const SizedBox(width: 6),
                  Text('Invalid OTP. Please try again.',
                      style: AppTextStyles.labelMd
                          .copyWith(color: AppColors.error)),
                ],
              ),
            ],

            const SizedBox(height: 36),

            // Verify button
            AppGradientButton(
              label: 'Verify OTP',
              onTap: _isLoading ? null : _verify,
              gradient: isDriver
                  ? AppColors.darkGradient
                  : AppColors.primaryGradient,
            ),

            const SizedBox(height: 28),

            // Resend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Didn't receive the OTP? ", style: AppTextStyles.bodyMd),
                _resendSeconds > 0
                    ? Text(
                        'Resend in ${_resendSeconds}s',
                        style: AppTextStyles.labelMd
                            .copyWith(color: AppColors.textLight),
                      )
                    : GestureDetector(
                        onTap: () {
                          setState(() => _resendSeconds = 30);
                          _startResendTimer();
                        },
                        child: Text('Resend OTP',
                            style: AppTextStyles.bodyMdOrange),
                      ),
              ],
            ),
            // ── DEV MODE SKIP BUTTON ──────────────────────────────────────
            const SizedBox(height: 24),
            GestureDetector(
              onTap: widget.onVerified,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.developer_mode_rounded,
                        color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'DEV — Skip OTP → Dashboard',
                      style: AppTextStyles.labelMd.copyWith(color: Colors.amber),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
