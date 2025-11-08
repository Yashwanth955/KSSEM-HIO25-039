// lib/pose_painter.dart

import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart'; // Added this line

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation imageRotation;
  final bool formIsCorrect;
  final CameraLensDirection cameraLensDirection; // To handle mirroring

  PosePainter(
      this.poses,
      this.imageSize,
      this.imageRotation, {
        required this.formIsCorrect,
        this.cameraLensDirection = CameraLensDirection.back, // Default to back
      });

  @override
  void paint(Canvas canvas, Size size) {
    final lineColor = formIsCorrect ? Colors.greenAccent : Colors.redAccent;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5 // Adjusted for thinner lines
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke; // Ensure it's for lines

    final jointPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 4.0 // Or a different size for the joint radius
      ..style = PaintingStyle.fill; // Filled circles for joints

    for (final pose in poses) {
      Offset scale(double x, double y) {
        // ... your existing scaling logic remains the same ...
        final double scaleX = size.width / imageSize.height;
        final double scaleY = size.height / imageSize.width;
        final double scaleFactor = scaleX < scaleY ? scaleX : scaleY; // Renamed for clarity

        final double offsetX = (size.width - imageSize.height * scaleFactor) / 2;
        final double offsetY = (size.height - imageSize.width * scaleFactor) / 2;

        double scaledX = x * scaleFactor + offsetX;

        if (cameraLensDirection == CameraLensDirection.front) {
          scaledX = size.width - scaledX;
        }
        return Offset(scaledX, y * scaleFactor + offsetY);
      }

      void drawLine(PoseLandmarkType type1, PoseLandmarkType type2) {
        final landmark1 = pose.landmarks[type1];
        final landmark2 = pose.landmarks[type2];
        if (landmark1 != null && landmark2 != null) {
          canvas.drawLine(
              scale(landmark1.x, landmark1.y),
              scale(landmark2.x, landmark2.y),
              linePaint); // Use linePaint
        }
      }

      // Draw lines for the torso
      drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
      drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);
      drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
      drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);

      // Draw lines for the arms
      drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
      drawLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
      drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
      drawLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);

      // Draw lines for the legs
      drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
      drawLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
      drawLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
      drawLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);

      // Draw joints
      for (final landmarkEntry in pose.landmarks.entries) {
        final landmark = landmarkEntry.value; // PoseLandmark object
        // Optionally, you can filter which landmarks to draw,
        // e.g., if (landmark.type == PoseLandmarkType.leftWrist || ...)
 // Check if landmark exists
        final Offset landmarkPosition = scale(landmark.x, landmark.y);
        canvas.drawCircle(landmarkPosition, 3.0, jointPaint); // Draw a circle with radius 3.0
            }
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses ||
        oldDelegate.formIsCorrect != formIsCorrect ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.imageRotation != imageRotation;
  }
}
