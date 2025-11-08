import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show WriteBuffer;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'
    as ml;

import 'pose_analyzer.dart';
import 'pose_painter.dart';
import 'test_result_screens.dart';

class CameraScreen extends StatefulWidget {
  final PoseAnalyzer analyzer;
  final String testName;
  final int durationSeconds;

  const CameraScreen({
    super.key,
    required this.analyzer,
    required this.testName,
    this.durationSeconds = 60,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  ml.PoseDetector? poseDetector;

  bool detecting = false;
  ml.Pose? pose;
  Size imageSize = const Size(1, 1);
  ml.InputImageRotation _rotation = ml.InputImageRotation.rotation0deg;

  int remaining = 0;
  Timer? timer;
  bool _isTestStarted = false;

  @override
  void initState() {
    super.initState();
    remaining = widget.durationSeconds;
    init();
  }

  Future<void> init() async {
    final cameras = await availableCameras();
    controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await controller!.initialize();

    poseDetector = ml.PoseDetector(
      options: ml.PoseDetectorOptions(
        mode: ml.PoseDetectionMode.stream,
        model: ml.PoseDetectionModel.accurate,
      ),
    );

    if (mounted) setState(() {});
  }

  Future<void> processFrame(CameraImage img) async {
    if (detecting) return;
    detecting = true;

    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in img.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = allBytes.done().buffer.asUint8List();
    final inputImg = ml.InputImage.fromBytes(
      bytes: bytes,
      metadata: ml.InputImageMetadata(
        size: Size(img.width.toDouble(), img.height.toDouble()),
        rotation:
            ml.InputImageRotationValue.fromRawValue(
              controller!.description.sensorOrientation,
            ) ??
            ml.InputImageRotation.rotation0deg,
        format: ml.InputImageFormat.yuv420,
        bytesPerRow: img.planes[0].bytesPerRow,
      ),
    );
    _rotation = inputImg.metadata!.rotation;

    final poses = await poseDetector!.processImage(inputImg);

    if (poses.isNotEmpty) {
      pose = poses.first;
      imageSize = Size(img.width.toDouble(), img.height.toDouble());
      // PoseAnalyzer API uses processPose(pose, imageSize)
      widget.analyzer.processPose(pose!, imageSize);
    } else {
      pose = null;
    }

    detecting = false;
    if (mounted) setState(() {});
  }

  void startTest() {
    if (_isTestStarted) return;
    setState(() {
      _isTestStarted = true;
    });
    controller!.startImageStream(processFrame);
    startCountdown();
  }

  void startCountdown() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => remaining--);
      if (remaining <= 0) {
        stopTest();
      }
    });
  }

  Future<void> stopTest() async {
    timer?.cancel();
    if (controller?.value.isStreamingImages ?? false) {
      await controller?.stopImageStream();
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => JumpResultScreen(
          testTitle: widget.testName,
          feedback: widget.analyzer.getFeedback(),
          correctReps: widget.analyzer.repCount,
          wrongReps: widget.analyzer.wrongRepCount,
          testDurationSeconds: (widget.durationSeconds - remaining).clamp(
            0,
            widget.durationSeconds,
          ),
          recordedVideo: null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    controller?.dispose();
    poseDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isRotated =
        _rotation == ml.InputImageRotation.rotation90deg ||
        _rotation == ml.InputImageRotation.rotation270deg;

    final previewSize = controller!.value.previewSize!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: isRotated ? previewSize.height : previewSize.width,
                height: isRotated ? previewSize.width : previewSize.height,
                child: CameraPreview(controller!),
              ),
            ),
          ),
          if (pose != null)
            CustomPaint(
              size: Size.infinite,
              painter: PosePainter(
                [pose!],
                imageSize,
                _rotation,
                formIsCorrect: widget.analyzer.formIsCorrect,
                cameraLensDirection: controller!.description.lensDirection,
              ),
            ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Reps: ${widget.analyzer.repCount}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "$remaining s",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: _isTestStarted
                  ? FloatingActionButton.extended(
                      onPressed: stopTest,
                      label: const Text("Stop Test"),
                      icon: const Icon(Icons.stop),
                    )
                  : FloatingActionButton.extended(
                      onPressed: startTest,
                      label: const Text("Start Test"),
                      icon: const Icon(Icons.play_arrow),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
