import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/rating_stars.dart';

class RideCompletedScreen extends StatefulWidget {
  final VoidCallback? onDone;

  const RideCompletedScreen({super.key, this.onDone});

  @override
  State<RideCompletedScreen> createState() => _RideCompletedScreenState();
}

class _RideCompletedScreenState extends State<RideCompletedScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkCtrl;
  late AnimationController _confettiCtrl;
  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;
  double _selectedRating = 4;
  int _selectedTip = 0;
  final _tipLabels = ['₹10', '₹20', '₹30', 'Other'];

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _checkScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut),
    );
    _checkOpacity = CurvedAnimation(parent: _checkCtrl, curve: Curves.easeIn);

    _checkCtrl.forward().then((_) => _confettiCtrl.forward());
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Confetti
          AnimatedBuilder(
            animation: _confettiCtrl,
            builder: (_, __) => CustomPaint(
              size: Size(MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height),
              painter: _ConfettiPainter(_confettiCtrl.value),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Success check
                  ScaleTransition(
                    scale: _checkScale,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.successGradient),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success,
                            blurRadius: 28,
                            spreadRadius: -6,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
                    ),
                  ),

                  const SizedBox(height: 20),

                  FadeTransition(
                    opacity: _checkOpacity,
                    child: Column(
                      children: [
                        Text('Trip Completed!', style: AppTextStyles.h2),
                        const SizedBox(height: 6),
                        Text(
                          'Thanks for riding with BikeJee!',
                          style: AppTextStyles.bodyMd,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Fare breakdown
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Fare', style: AppTextStyles.h4),
                            Text('₹45',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                )),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(),
                        const SizedBox(height: 10),
                        _FareRow('Base Fare', '₹35'),
                        _FareRow('Distance (4.2 km)', '₹8'),
                        _FareRow('Convenience Fee', '₹2'),
                        const Divider(),
                        _FareRow('Total', '₹45', bold: true),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.greyBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.payment_rounded,
                                  color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              Text('Payment Method', style: AppTextStyles.bodyMd),
                              const Spacer(),
                              Text('Cash',
                                  style: AppTextStyles.labelLg.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Rate driver
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rate your driver', style: AppTextStyles.h4),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: const Icon(Icons.person_rounded,
                                  color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 10),
                            Text('Arjun Kumar', style: AppTextStyles.h5),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: TappableRatingStars(
                            initial: _selectedRating,
                            onRated: (r) => setState(() => _selectedRating = r),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tip driver
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add a tip for your driver', style: AppTextStyles.h4),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(4, (i) {
                            final isSelected = _selectedTip == i;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedTip = i),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary.withOpacity(0.1)
                                          : AppColors.greyBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected ? AppColors.primary : AppColors.border,
                                        width: isSelected ? 1.5 : 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      _tipLabels[i],
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.labelMd.copyWith(
                                        color: isSelected ? AppColors.primary : AppColors.textMedium,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  AppGradientButton(label: 'Done', onTap: widget.onDone),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'View Trip Details',
                    variant: AppButtonVariant.outline,
                    onTap: () {},
                    height: 48,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _FareRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: bold ? AppTextStyles.h5 : AppTextStyles.bodyMd),
          Text(value,
              style: bold
                  ? AppTextStyles.h5.copyWith(color: AppColors.primary)
                  : AppTextStyles.labelLg),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  static final _rng = math.Random(42);
  static final _particles = List.generate(60, (_) => _Particle(_rng));

  _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    for (final p in _particles) {
      final t = (progress * 1.5).clamp(0.0, 1.0);
      final x = p.x * size.width;
      final y = p.startY * size.height + t * size.height * p.speed;
      final opacity = (1 - t * 1.4).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final paint = Paint()..color = p.color.withOpacity(opacity);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * p.rotation);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.4),
          const Radius.circular(1),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.progress != progress;
}

class _Particle {
  final double x, startY, speed, size, rotation;
  final Color color;

  _Particle(math.Random rng)
      : x = rng.nextDouble(),
        startY = -0.1 - rng.nextDouble() * 0.3,
        speed = 0.5 + rng.nextDouble() * 0.6,
        size = 6 + rng.nextDouble() * 10,
        rotation = (rng.nextDouble() - 0.5) * 6 * math.pi,
        color = [
          AppColors.primary,
          AppColors.success,
          AppColors.info,
          AppColors.warning,
          AppColors.primary,
          Colors.pink,
        ][rng.nextInt(6)];
}
