import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final Map<PoseLandmarkType, Offset>? landmarks;
  final Size imageSize;
  final bool isFrontCamera;

  PosePainter({
    required this.landmarks,
    required this.imageSize,
    required this.isFrontCamera,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks == null || landmarks!.isEmpty) return;

    final pointPaint = Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;

    final strongLinePaint = Paint()
      ..color = const Color(0xFF00E676)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    Offset? mapLandmark(PoseLandmarkType type) {
      final lm = landmarks![type];
      if (lm == null) return null;

      double dx = (lm.dx / imageSize.width) * size.width;
      final dy = (lm.dy / imageSize.height) * size.height;

      if (isFrontCamera) {
        dx = size.width - dx;
      }

      return Offset(dx, dy);
    }

    void drawLine(
      PoseLandmarkType a,
      PoseLandmarkType b, {
      bool strong = false,
    }) {
      final p1 = mapLandmark(a);
      final p2 = mapLandmark(b);
      if (p1 == null || p2 == null) return;
      canvas.drawLine(p1, p2, strong ? strongLinePaint : linePaint);
    }

    const connections = [
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
      [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
      [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
      [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
    ];

    for (final pair in connections) {
      drawLine(
        pair[0],
        pair[1],
        strong: (pair[0] == PoseLandmarkType.leftShoulder &&
                pair[1] == PoseLandmarkType.rightShoulder) ||
            (pair[0] == PoseLandmarkType.leftHip &&
                pair[1] == PoseLandmarkType.rightHip),
      );
    }

    for (final type in landmarks!.keys) {
      final p = mapLandmark(type);
      if (p == null) continue;
      canvas.drawCircle(p, 5.5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.landmarks != landmarks ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.isFrontCamera != isFrontCamera;
  }
}