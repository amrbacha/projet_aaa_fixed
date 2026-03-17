import 'dart:math' as math;
import 'dart:ui';

class GeometryUtils {
  static Offset? midPoint(Offset? a, Offset? b) {
    if (a == null || b == null) return null;
    return Offset(
      (a.dx + b.dx) / 2,
      (a.dy + b.dy) / 2,
    );
  }

  static double lineAngleFromHorizontal(Offset a, Offset b) {
    final radians = math.atan2(b.dy - a.dy, b.dx - a.dx);
    final degrees = radians * 180 / math.pi;
    return degrees.abs();
  }

  static double lineAngleFromVertical(Offset a, Offset b) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final radians = math.atan2(dx.abs(), dy.abs());
    return radians * 180 / math.pi;
  }

  static double jointAngle(Offset a, Offset b, Offset c) {
    final ab = Offset(a.dx - b.dx, a.dy - b.dy);
    final cb = Offset(c.dx - b.dx, c.dy - b.dy);

    final dot = (ab.dx * cb.dx) + (ab.dy * cb.dy);
    final magAB = math.sqrt((ab.dx * ab.dx) + (ab.dy * ab.dy));
    final magCB = math.sqrt((cb.dx * cb.dx) + (cb.dy * cb.dy));

    if (magAB == 0 || magCB == 0) return 0.0;

    final cosine = (dot / (magAB * magCB)).clamp(-1.0, 1.0);
    return math.acos(cosine) * 180 / math.pi;
  }

  static double lerp(double a, double b, double t) => a + (b - a) * t;

  static double minValues(List<double> values) => values.reduce(math.min);

  static double maxValues(List<double> values) => values.reduce(math.max);
}