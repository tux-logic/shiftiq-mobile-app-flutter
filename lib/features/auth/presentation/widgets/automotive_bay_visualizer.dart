import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AutomotiveBayVisualizer extends StatefulWidget {
  const AutomotiveBayVisualizer({super.key});

  @override
  State<AutomotiveBayVisualizer> createState() => _AutomotiveBayVisualizerState();
}

class _AutomotiveBayVisualizerState extends State<AutomotiveBayVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _liftAnimation;
  late final Animation<double> _busWaveAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _liftAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
      ),
    );

    _busWaveAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      _pulseController,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.techCardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.techCardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeaderBadges(),
          _buildWorkshopStage(),
          _buildFooterTelemetry(),
        ],
      ),
    );
  }

  Widget _buildHeaderBadges() {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // PLAN PRO Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, color: AppColors.neonGreen, size: 14),
                SizedBox(width: 5),
                Text(
                  'PLAN PRO · ACTIVO',
                  style: TextStyle(
                    color: AppColors.neonGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // OS Version Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: const Text(
              'SHIFTIQ OS  v2.4',
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopStage() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 190),
          painter: _WorkshopBayPainter(
            liftProgress: _liftAnimation.value,
            waveProgress: _busWaveAnimation.value,
          ),
        );
      },
    );
  }

  Widget _buildFooterTelemetry() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF132238), width: 1),
        ),
      ),
      child: Row(
        children: [
          const Text(
            '3',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 4),
          const Text(
            'BAHÍAS ACTIVAS',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('|', style: TextStyle(color: Color(0xFF334155), fontSize: 12)),
          ),
          const Text(
            '5',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 4),
          const Text(
            'ÓRDENES',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          // Animated CAN-BUS online pulsing dot
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final opacity = 0.4 + 0.6 * math.sin(_pulseController.value * math.pi);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neonGreen.withValues(alpha: opacity.clamp(0.2, 1.0)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonGreen.withValues(alpha: 0.8),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'CAN-BUS ONLINE',
                    style: TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WorkshopBayPainter extends CustomPainter {
  final double liftProgress;
  final double waveProgress;

  _WorkshopBayPainter({
    required this.liftProgress,
    required this.waveProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final floorY = size.height - 20;

    // 1. Draw floor dashed guidelines
    final floorPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (double x = 18; x < size.width - 18; x += 10) {
      canvas.drawLine(Offset(x, floorY), Offset(x + 5, floorY), floorPaint);
    }

    // 2. Bahía 01 - Hydraulic Elevator Posts
    final liftPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 2.0;

    const liftLeftX = 40.0;
    const liftRightX = 145.0;
    canvas.drawLine(const Offset(liftLeftX, 40), Offset(liftLeftX, floorY), liftPaint);
    canvas.drawLine(const Offset(liftRightX, 40), Offset(liftRightX, floorY), liftPaint);

    // Hydraulic platform that moves up and down
    final platformY = floorY - 25 - (liftProgress * 35);
    final platformPaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..strokeWidth = 4.0;
    canvas.drawLine(Offset(liftLeftX - 10, platformY), Offset(liftRightX + 10, platformY), platformPaint);

    // Vehicle on lift
    _drawVehicleSilhouette(canvas, Offset(liftLeftX + 5, platformY - 28), const Color(0xFF7DD3FC));

    // Label Bahía 01
    _drawText(canvas, 'BAHÍA 01 · ELEVADOR 1', const Offset(42, 18), const Color(0xFF38BDF8), 9.0);

    // 3. Central DTC Terminal Rack
    const dtcX = 155.0;
    const dtcY = 50.0;
    const dtcW = 65.0;
    const dtcH = 75.0;

    final dtcBgPaint = Paint()..color = const Color(0xFF030E20);
    final dtcBorder = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.7)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(dtcX, dtcY, dtcW, dtcH),
      const Radius.circular(8),
    );
    canvas.drawRRect(rrect, dtcBgPaint);
    canvas.drawRRect(rrect, dtcBorder);

    // DTC Texts
    _drawText(canvas, 'LIVE DTC BUS', const Offset(dtcX + 8, dtcY + 6), const Color(0xFF94A3B8), 7.5);
    _drawText(canvas, 'P0300 OK', const Offset(dtcX + 8, dtcY + 35), const Color(0xFF38BDF8), 7.0);
    _drawText(canvas, 'CAN 0x7E0', const Offset(dtcX + 8, dtcY + 46), const Color(0xFF64748B), 6.5);
    _drawText(canvas, 'SYNC 12ms', const Offset(dtcX + 8, dtcY + 58), const Color(0xFF10B981), 7.0);

    // Oscilloscope pulse wave inside DTC box
    final wavePath = Path();
    final waveY = dtcY + 24;
    wavePath.moveTo(dtcX + 8, waveY);
    for (double i = 0; i <= 48; i += 2) {
      final y = waveY + math.sin(waveProgress + (i * 0.25)) * 4.5;
      wavePath.lineTo(dtcX + 8 + i, y);
    }
    final wavePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(wavePath, wavePaint);

    // 4. Bahía 02 Vehicle on ground floor
    final car2X = size.width - 110;
    _drawVehicleSilhouette(canvas, Offset(car2X, floorY - 32), const Color(0xFF60A5FA));
    _drawText(canvas, 'BAHÍA 02', Offset(car2X + 15, 20), const Color(0xFF38BDF8), 9.0);
  }

  void _drawVehicleSilhouette(Canvas canvas, Offset pos, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final path = Path();
    final x = pos.dx;
    final y = pos.dy;

    // Stylized automotive profile line
    path.moveTo(x, y + 16);
    path.lineTo(x + 12, y + 16);
    path.lineTo(x + 22, y + 6);
    path.lineTo(x + 48, y + 6);
    path.lineTo(x + 58, y + 16);
    path.lineTo(x + 75, y + 16);
    path.lineTo(x + 75, y + 24);
    path.lineTo(x, y + 24);
    path.close();

    canvas.drawPath(path, paint);

    // Wheels
    final wheelPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(x + 16, y + 24), 5.5, wheelPaint);
    canvas.drawCircle(Offset(x + 58, y + 24), 5.5, wheelPaint);
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color, double fontSize) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _WorkshopBayPainter oldDelegate) {
    return oldDelegate.liftProgress != liftProgress ||
        oldDelegate.waveProgress != waveProgress;
  }
}
