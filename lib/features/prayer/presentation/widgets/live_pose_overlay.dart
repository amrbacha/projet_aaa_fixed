import 'package:flutter/material.dart';
import 'package:projet_aaa_fixed/core/services/pose_detection_service.dart';

class LivePoseOverlay extends StatelessWidget {
  final PrayerPosition position;
  final bool centered;
  final Color color;

  const LivePoseOverlay({
    super.key,
    required this.position,
    required this.centered,
    this.color = Colors.greenAccent,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LivePoseOverlayPainter(
        position: position,
        centered: centered,
        color: color.withOpacity(centered ? 0.85 : 0.45),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _LivePoseOverlayPainter extends CustomPainter {
  final PrayerPosition position;
  final bool centered;
  final Color color;

  _LivePoseOverlayPainter({
    required this.position,
    required this.centered,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = centered ? 3.5 : 2.2;

    final cx = size.width / 2;
    final top = size.height * 0.18;
    final headR = size.width * 0.07;

    switch (position) {
      case PrayerPosition.ruku:
        _drawRuku(canvas, size, p, cx, top, headR);
        break;
      case PrayerPosition.sujud:
        _drawSujud(canvas, size, p);
        break;
      case PrayerPosition.sitting:
        _drawSitting(canvas, size, p, cx, top, headR);
        break;
      case PrayerPosition.takbir:
      case PrayerPosition.standing:
      case PrayerPosition.unknown:
        _drawStanding(canvas, size, p, cx, top, headR, takbir: position == PrayerPosition.takbir);
        break;
    }
  }

  void _drawStanding(Canvas canvas, Size size, Paint p, double cx, double top, double headR, {bool takbir = false}) {
    canvas.drawCircle(Offset(cx, top), headR, p);
    canvas.drawLine(Offset(cx, top + headR), Offset(cx, size.height * 0.55), p);
    final armY = size.height * 0.30;
    final leftArmX = takbir ? cx - size.width * 0.12 : cx - size.width * 0.16;
    final rightArmX = takbir ? cx + size.width * 0.12 : cx + size.width * 0.16;
    final armTopY = takbir ? size.height * 0.18 : armY;
    canvas.drawLine(Offset(cx, armY), Offset(leftArmX, armTopY), p);
    canvas.drawLine(Offset(cx, armY), Offset(rightArmX, armTopY), p);
    canvas.drawLine(Offset(cx, size.height * 0.55), Offset(cx - size.width * 0.09, size.height * 0.84), p);
    canvas.drawLine(Offset(cx, size.height * 0.55), Offset(cx + size.width * 0.09, size.height * 0.84), p);
  }

  void _drawRuku(Canvas canvas, Size size, Paint p, double cx, double top, double headR) {
    final backStart = Offset(cx - size.width * 0.12, size.height * 0.33);
    final backEnd = Offset(cx + size.width * 0.12, size.height * 0.36);
    canvas.drawCircle(Offset(cx - size.width * 0.16, size.height * 0.30), headR * 0.85, p);
    canvas.drawLine(backStart, backEnd, p);
    canvas.drawLine(Offset(cx - size.width * 0.06, size.height * 0.35), Offset(cx - size.width * 0.18, size.height * 0.48), p);
    canvas.drawLine(Offset(cx + size.width * 0.06, size.height * 0.36), Offset(cx + size.width * 0.18, size.height * 0.48), p);
    canvas.drawLine(Offset(cx - size.width * 0.02, size.height * 0.39), Offset(cx - size.width * 0.02, size.height * 0.82), p);
    canvas.drawLine(Offset(cx + size.width * 0.08, size.height * 0.39), Offset(cx + size.width * 0.08, size.height * 0.82), p);
  }

  void _drawSujud(Canvas canvas, Size size, Paint p) {
    final y = size.height * 0.66;
    canvas.drawCircle(Offset(size.width * 0.60, y), size.width * 0.05, p);
    canvas.drawLine(Offset(size.width * 0.32, y - 0.01 * size.height), Offset(size.width * 0.56, y), p);
    canvas.drawLine(Offset(size.width * 0.36, y + size.height * 0.02), Offset(size.width * 0.22, y + size.height * 0.12), p);
    canvas.drawLine(Offset(size.width * 0.46, y + size.height * 0.02), Offset(size.width * 0.34, y + size.height * 0.16), p);
    canvas.drawLine(Offset(size.width * 0.56, y + size.height * 0.02), Offset(size.width * 0.74, y + size.height * 0.06), p);
    canvas.drawLine(Offset(size.width * 0.48, y + size.height * 0.06), Offset(size.width * 0.66, y + size.height * 0.18), p);
  }

  void _drawSitting(Canvas canvas, Size size, Paint p, double cx, double top, double headR) {
    canvas.drawCircle(Offset(cx, top), headR, p);
    canvas.drawLine(Offset(cx, top + headR), Offset(cx, size.height * 0.42), p);
    canvas.drawLine(Offset(cx, size.height * 0.30), Offset(cx - size.width * 0.14, size.height * 0.44), p);
    canvas.drawLine(Offset(cx, size.height * 0.30), Offset(cx + size.width * 0.14, size.height * 0.44), p);
    canvas.drawLine(Offset(cx, size.height * 0.42), Offset(cx - size.width * 0.14, size.height * 0.62), p);
    canvas.drawLine(Offset(cx, size.height * 0.42), Offset(cx + size.width * 0.14, size.height * 0.62), p);
    canvas.drawLine(Offset(cx - size.width * 0.14, size.height * 0.62), Offset(cx + size.width * 0.02, size.height * 0.70), p);
    canvas.drawLine(Offset(cx + size.width * 0.14, size.height * 0.62), Offset(cx + size.width * 0.22, size.height * 0.76), p);
  }

  @override
  bool shouldRepaint(covariant _LivePoseOverlayPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.centered != centered ||
        oldDelegate.color != color;
  }
}
