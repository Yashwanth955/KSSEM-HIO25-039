// lib/pose_painter.dart

import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'
    as ml;
import 'package:camera/camera.dart';

class PosePainter extends CustomPainter {
  final List<ml.Pose> poses;
  final Size imageSize;
  final ml.InputImageRotation imageRotation;
  final bool formIsCorrect;
  final CameraLensDirection cameraLensDirection; // For mirroring

  PosePainter(
    this.poses,
    this.imageSize,
    this.imageRotation, {
    required this.formIsCorrect,
    this.cameraLensDirection = CameraLensDirection.back,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final lineColor = formIsCorrect ? Colors.greenAccent : Colors.redAccent;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final jointPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 4.0
      ..style = PaintingStyle.fill;

    // Determine rotated image dimensions
    final bool isRotated =
        imageRotation == ml.InputImageRotation.rotation90deg ||
        imageRotation == ml.InputImageRotation.rotation270deg;
    final double imgW = isRotated ? imageSize.height : imageSize.width;
    final double imgH = isRotated ? imageSize.width : imageSize.height;

    // Match full-screen preview using cover scaling
    final double scaleX = size.width / imgW;
    final double scaleY = size.height / imgH;
    final double scale = scaleX > scaleY ? scaleX : scaleY; // cover
    final double dx = (size.width - imgW * scale) / 2;
    final double dy = (size.height - imgH * scale) / 2;

    Offset transform(double x, double y) {
      double tx = x;
      double ty = y;
      switch (imageRotation) {
        case ml.InputImageRotation.rotation90deg:
          tx = y;
          ty = imageSize.width - x;
          break;
        case ml.InputImageRotation.rotation180deg:
          tx = imageSize.width - x;
          ty = imageSize.height - y;
          break;
        case ml.InputImageRotation.rotation270deg:
          tx = imageSize.height - y;
          ty = x;
          break;
        case ml.InputImageRotation.rotation0deg:
          break;
      }

      double sx = dx + tx * scale;
      double sy = dy + ty * scale;
      if (cameraLensDirection == CameraLensDirection.front) {
        sx = size.width - sx; // mirror horizontally for front camera
      }
      return Offset(sx, sy);
    }

    for (final pose in poses) {
      void drawLine(ml.PoseLandmarkType a, ml.PoseLandmarkType b) {
        final l1 = pose.landmarks[a];
        final l2 = pose.landmarks[b];
        if (l1 != null && l2 != null) {
          canvas.drawLine(
            transform(l1.x, l1.y),
            transform(l2.x, l2.y),
            linePaint,
          );
        }
      }

      // Torso
      drawLine(
        ml.PoseLandmarkType.leftShoulder,
        ml.PoseLandmarkType.rightShoulder,
      );
      drawLine(ml.PoseLandmarkType.leftHip, ml.PoseLandmarkType.rightHip);
      drawLine(ml.PoseLandmarkType.leftShoulder, ml.PoseLandmarkType.leftHip);
      drawLine(ml.PoseLandmarkType.rightShoulder, ml.PoseLandmarkType.rightHip);

      // Arms
      drawLine(ml.PoseLandmarkType.leftShoulder, ml.PoseLandmarkType.leftElbow);
      drawLine(ml.PoseLandmarkType.leftElbow, ml.PoseLandmarkType.leftWrist);
      drawLine(
        ml.PoseLandmarkType.rightShoulder,
        ml.PoseLandmarkType.rightElbow,
      );
      drawLine(ml.PoseLandmarkType.rightElbow, ml.PoseLandmarkType.rightWrist);

      // Legs
      drawLine(ml.PoseLandmarkType.leftHip, ml.PoseLandmarkType.leftKnee);
      drawLine(ml.PoseLandmarkType.leftKnee, ml.PoseLandmarkType.leftAnkle);
      drawLine(ml.PoseLandmarkType.rightHip, ml.PoseLandmarkType.rightKnee);
      drawLine(ml.PoseLandmarkType.rightKnee, ml.PoseLandmarkType.rightAnkle);

      // Joints
      for (final e in pose.landmarks.entries) {
        final p = transform(e.value.x, e.value.y);
        canvas.drawCircle(p, 3.0, jointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses ||
        oldDelegate.formIsCorrect != formIsCorrect ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.imageRotation != imageRotation ||
        oldDelegate.cameraLensDirection != cameraLensDirection;
  }
}
