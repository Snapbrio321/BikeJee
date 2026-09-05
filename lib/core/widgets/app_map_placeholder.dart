import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// A beautiful map placeholder with animated route drawing
class AppMapPlaceholder extends StatefulWidget {
  final double height;
  final bool showRoute;
  final bool isFullScreen;

  const AppMapPlaceholder({
    super.key,
    this.height = 220,
    this.showRoute = true,
    this.isFullScreen = false,
  });

  @override
  State<AppMapPlaceholder> createState() => _AppMapPlaceholderState();
}

class _AppMapPlaceholderState extends State<AppMapPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.isFullScreen ? null : widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0F7),
        borderRadius: BorderRadius.circular(widget.isFullScreen ? 0 : 16),
      ),
      child: Stack(
        children: [
          // Grid lines
          CustomPaint(
            size: Size.infinite,
            painter: _MapGridPainter(),
          ),
          // Route
          if (widget.showRoute)
            CustomPaint(
              size: Size.infinite,
              painter: _RoutePainter(_animation),
            ),
          // Animated location pin
          if (widget.showRoute)
            AnimatedBuilder(
              animation: _animation,
              builder: (_, __) {
                return Positioned(
                  top: 40 + (_animation.value * 6),
                  left: 60,
                  child: _LocationPin(color: AppColors.mapPickup),
                );
              },
            ),
          // Destination pin
          Positioned(
            bottom: 40,
            right: 60,
            child: _LocationPin(color: AppColors.mapDrop),
          ),
          // Moving bike icon
          if (widget.showRoute)
            AnimatedBuilder(
              animation: _animation,
              builder: (_, __) {
                return Positioned(
                  top: 60 + (_animation.value * 30),
                  left: 80 + (_animation.value * 50),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.electric_bike_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                );
              },
            ),
          // Map label
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map_rounded, size: 12, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('Live Map', style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPin extends StatelessWidget {
  final Color color;

  const _LocationPin({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.4), blurRadius: 8),
            ],
          ),
        ),
        Container(
          width: 2,
          height: 10,
          color: color,
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.05)
      ..strokeWidth = 1;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Road-like shapes
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height * 0.35), Offset(size.width, size.height * 0.35), roadPaint);
    canvas.drawLine(Offset(size.width * 0.4, 0), Offset(size.width * 0.4, size.height), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.65), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  final Animation<double> animation;

  _RoutePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.mapRoute
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(70, 50);
    path.cubicTo(
      size.width * 0.3, size.height * 0.3,
      size.width * 0.5, size.height * 0.5,
      size.width - 70, size.height - 50,
    );

    final pathMetric = path.computeMetrics().first;
    final extractPath = pathMetric.extractPath(
      0,
      pathMetric.length * animation.value,
    );

    canvas.drawPath(extractPath, paint);

    // Dashed remaining path
    final dashedPaint = Paint()
      ..color = AppColors.mapRoute.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final remainingPath = pathMetric.extractPath(
      pathMetric.length * animation.value,
      pathMetric.length,
    );
    canvas.drawPath(remainingPath, dashedPaint);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) => true;
}
