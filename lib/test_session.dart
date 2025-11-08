// lib/test_session.dart
import 'dart:ui';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'
    as ml;
import 'pose_analyzer.dart';
import 'isar_service.dart';
import 'test_result.dart';

class TestSession {
  final PoseAnalyzer analyzer;
  final IsarService isarService;
  final String testTitle;

  TestSession({
    required this.analyzer,
    required this.isarService,
    required this.testTitle,
  });

  void processFrame(ml.Pose pose, Size imageSize) {
    // Use the unified analyzer API
    analyzer.processPose(pose, imageSize);
  }

  Future<void> finishTest() async {
    final result = TestResult(
      testTitle: testTitle,
      resultValue: analyzer.repCount.toString(),
      date: DateTime.now(),
      wrongRepCount: analyzer.wrongRepCount,
      formCorrect: analyzer.formIsCorrect,
      feedback: analyzer.getFeedback().join('\n'),
    );

    await isarService.saveTestResult(result);

    // Reset for next session
    analyzer.reset();
  }
}
