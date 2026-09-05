import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/bikejee_logo.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));
    _fadeAnim = _fadeController;

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.secondary, AppColors.secondaryLight, AppColors.secondary],
          ),
        ),
        child: Stack(
          children: [
            // Background circles
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.06),
                ),
              ),
            ),
            // City skyline bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 160),
                  painter: _CitySkylinePainter(),
                ),
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: const BikeJeeLogoCenter(size: 1.1, darkBg: true),
                    ),
                  ),
                  const SizedBox(height: 48),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading your ride experience...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Version
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Text(
                  'v1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 12,
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

class _CitySkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.04);
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.5);
    path.lineTo(size.width * 0.05, size.height * 0.5);
    path.lineTo(size.width * 0.05, size.height * 0.3);
    path.lineTo(size.width * 0.1, size.height * 0.3);
    path.lineTo(size.width * 0.1, size.height * 0.45);
    path.lineTo(size.width * 0.18, size.height * 0.45);
    path.lineTo(size.width * 0.18, size.height * 0.2);
    path.lineTo(size.width * 0.22, size.height * 0.2);
    path.lineTo(size.width * 0.22, size.height * 0.1);
    path.lineTo(size.width * 0.26, size.height * 0.1);
    path.lineTo(size.width * 0.26, size.height * 0.4);
    path.lineTo(size.width * 0.35, size.height * 0.4);
    path.lineTo(size.width * 0.35, size.height * 0.25);
    path.lineTo(size.width * 0.42, size.height * 0.25);
    path.lineTo(size.width * 0.42, size.height * 0.5);
    path.lineTo(size.width * 0.55, size.height * 0.5);
    path.lineTo(size.width * 0.55, size.height * 0.3);
    path.lineTo(size.width * 0.62, size.height * 0.3);
    path.lineTo(size.width * 0.62, size.height * 0.15);
    path.lineTo(size.width * 0.67, size.height * 0.15);
    path.lineTo(size.width * 0.67, size.height * 0.35);
    path.lineTo(size.width * 0.75, size.height * 0.35);
    path.lineTo(size.width * 0.75, size.height * 0.5);
    path.lineTo(size.width * 0.85, size.height * 0.5);
    path.lineTo(size.width * 0.85, size.height * 0.3);
    path.lineTo(size.width * 0.92, size.height * 0.3);
    path.lineTo(size.width * 0.92, size.height * 0.45);
    path.lineTo(size.width, size.height * 0.45);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
