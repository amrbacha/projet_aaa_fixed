import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../painters/pose_painter.dart';

class CameraPosePreview extends StatelessWidget {
  final CameraController controller;
  final Size displayPreviewSize;
  final Size? latestImageSize;
  final Map<PoseLandmarkType, Offset> smoothedLandmarks;
  final bool isFrontCamera;
  final double maxHeight;

  const CameraPosePreview({
    super.key,
    required this.controller,
    required this.displayPreviewSize,
    required this.latestImageSize,
    required this.smoothedLandmarks,
    required this.isFrontCamera,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      child: AspectRatio(
        aspectRatio: displayPreviewSize.width / displayPreviewSize.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.35),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: displayPreviewSize.width,
                    height: displayPreviewSize.height,
                    child: CameraPreview(controller),
                  ),
                ),
              ),
              if (latestImageSize != null)
                CustomPaint(
                  painter: PosePainter(
                    landmarks:
                        smoothedLandmarks.isEmpty ? null : smoothedLandmarks,
                    imageSize: latestImageSize!,
                    isFrontCamera: isFrontCamera,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}