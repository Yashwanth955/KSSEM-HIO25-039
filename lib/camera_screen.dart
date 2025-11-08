import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'
    as ml;
import 'pose_analyzer.dart';
import 'pose_painter.dart';
import 'enhanced_pose_processor.dart' as epp;
import 'test_result_screens.dart';
import 'tts_service.dart';

class CameraScreen extends StatefulWidget {
  final PoseAnalyzer analyzer;
  final String testName;
  final int? durationInSeconds;

  const CameraScreen({
    required this.analyzer,
    required this.testName,
    this.durationInSeconds,
    super.key,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  late ml.PoseDetector _poseDetector;
  bool _isDetectingPoses = false;
  ml.Pose? _detectedPose;
  Size _imageSize = Size.zero;
  ml.InputImageRotation _imageRotation = ml.InputImageRotation.rotation0deg;
  bool _isTestStarted = false;
  DateTime? _testStartTime; // Added for tracking test duration

  List<CameraDescription> _cameras = [];
  int _selectedCameraIdx = 0;
  bool _isSwitchingCamera = false;

  Timer? _countdownTimer;
  int _currentCountdown = 3;
  bool _isCountdownInProgress = false;

  Timer? _testTimer;
  int _remainingTestSeconds = 0;

  // Enhanced processor for multi-person & fraud detection (single person for now)
  // ignore: unused_field
  late epp.EnhancedPoseProcessor _processor;
  bool _fraudDetected = false;
  XFile? _recordedVideo;

  @override
  void initState() {
    super.initState();
    if (widget.durationInSeconds != null && widget.durationInSeconds! > 0) {
      _remainingTestSeconds = widget.durationInSeconds!;
    }
    _initializeCameraAndPoseDetector();
  }

  Future<void> _initializeCameraAndPoseDetector() async {
    _cameras = await availableCameras();
    final options = ml.PoseDetectorOptions(
      model: ml.PoseDetectionModel.accurate, // use more accurate model
      mode: ml.PoseDetectionMode.stream, // real-time
    );
    _poseDetector = ml.PoseDetector(options: options);

    if (_cameras.isNotEmpty) {
      _selectedCameraIdx = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (_selectedCameraIdx == -1) _selectedCameraIdx = 0;
      await _initializeCameraController(_cameras[_selectedCameraIdx]);
    }

    _processor =
        epp.EnhancedPoseProcessor(analyzerFactory: () => widget.analyzer)
          ..onFraudDetected = (tracker) {
            if (mounted) {
              setState(() => _fraudDetected = true);
            }
          };
  }

  Future<void> _initializeCameraController(
    CameraDescription cameraDescription,
  ) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high, // higher resolution improves landmark accuracy
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();
      // Try to set a target FPS if supported
      try {
        await _controller!.setFocusMode(FocusMode.auto);
        await _controller!.setFlashMode(FlashMode.off);
      } catch (_) {}
      if (mounted) {
        await _controller!.startImageStream(_processCameraImage);
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isSwitchingCamera) {
      return;
    }
    setState(() {
      _isSwitchingCamera = true;
    });

    await _controller?.stopImageStream();
    _selectedCameraIdx = (_selectedCameraIdx + 1) % _cameras.length;
    await _initializeCameraController(_cameras[_selectedCameraIdx]);

    if (mounted) {
      setState(() {
        _isSwitchingCamera = false;
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _testTimer?.cancel();
    _controller?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isDetectingPoses) {
      return;
    }
    _isDetectingPoses = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();
      final imageRotation =
          ml.InputImageRotationValue.fromRawValue(
            _controller!.description.sensorOrientation,
          ) ??
          ml.InputImageRotation.rotation0deg;
      final imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final inputImageFormat =
          ml.InputImageFormatValue.fromRawValue(image.format.raw) ??
          ml.InputImageFormat.nv21;

      final inputImage = ml.InputImage.fromBytes(
        bytes: bytes,
        metadata: ml.InputImageMetadata(
          size: imageSize,
          rotation: imageRotation,
          format: inputImageFormat,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final List<ml.Pose> poses = await _poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        // Feed first pose into analyzer via unified interface when test running
        if (_isTestStarted) {
          widget.analyzer.analyze(
            poses.first,
            imageSize,
            allowCounting: !_fraudDetected,
          );
        }
        if (mounted) {
          setState(() {
            _detectedPose = poses.first;
            _imageSize = imageSize; // size from camera frame
            _imageRotation = imageRotation;
          });
        }
      }
    } finally {
      _isDetectingPoses = false;
    }
  }

  Future<void> _stopAndNavigate() async {
    if (!mounted) return;

    XFile? videoFile;
    if (_controller?.value.isRecordingVideo ?? false) {
      videoFile = await _controller?.stopVideoRecording();
    }

    _testTimer?.cancel();
    setState(() {
      _isTestStarted = false;
      if (videoFile != null) {
        _recordedVideo = videoFile;
      }
    });

    int testDurationSeconds = 0;
    if (_testStartTime != null) {
      testDurationSeconds = DateTime.now()
          .difference(_testStartTime!)
          .inSeconds;
    }

    List<String> feedbackMessages = widget.analyzer.getFeedback();
    if (_fraudDetected) {
      feedbackMessages = [
        "Irregular movement detected. Result flagged.",
        ...feedbackMessages,
      ];
    }

    // Use a local variable for the context to avoid async gaps
    final navContext = context;
    if (!mounted) return;

    Navigator.pushReplacement(
      navContext,
      MaterialPageRoute(
        builder: (context) => JumpResultScreen(
          testTitle: widget.testName,
          feedback: feedbackMessages,
          correctReps: widget.analyzer.repCount,
          wrongReps: widget.analyzer.wrongRepCount,
          testDurationSeconds: testDurationSeconds,
          recordedVideo: _recordedVideo,
        ),
      ),
    );
  }

  void _initiateTestSequence() async {
    if (!_isCameraInitialized ||
        !mounted ||
        _isTestStarted ||
        _isCountdownInProgress) {
      return;
    }

    final ttsService = TtsService();
    await ttsService.init();

    setState(() {
      _isCountdownInProgress = true;
      _currentCountdown = 3;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_currentCountdown > 0) {
        await ttsService.speak(_currentCountdown.toString());
        if (mounted) {
          setState(() {
            _currentCountdown--;
          });
        }
      } else {
        timer.cancel();
        await ttsService.speak("Start");
        if (mounted) {
          setState(() => _isCountdownInProgress = false);
          _beginPoseAnalysis();
        }
      }
    });
  }

  void _beginPoseAnalysis() {
    if (!_isCameraInitialized || !mounted) {
      return;
    }
    widget.analyzer.reset();
    _controller?.startVideoRecording();
    setState(() {
      _isTestStarted = true;
      _testStartTime = DateTime.now(); // Record start time of the test
    });
    if (widget.durationInSeconds != null && widget.durationInSeconds! > 0) {
      _startActualTestTimer();
    }
  }

  void _startActualTestTimer() {
    _testTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingTestSeconds > 0) {
        setState(() => _remainingTestSeconds--);
      } else {
        timer.cancel();
        _stopAndNavigate();
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // final cameraAspectRatio = _controller!.value.aspectRatio; // Kept for reference if needed

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover, // This ensures full screen without black bars
              child: SizedBox(
                width: _controller!
                    .value
                    .previewSize!
                    .height, // Swap width/height for rotation
                height: _controller!.value.previewSize!.width,
                child: CameraPreview(_controller!),
              ),
            ),
          if (_detectedPose != null)
            CustomPaint(
              painter: PosePainter(
                [_detectedPose!],
                _imageSize,
                _imageRotation,
                formIsCorrect: _isTestStarted
                    ? widget.analyzer.formIsCorrect
                    : true,
                cameraLensDirection: _controller!.description.lensDirection,
              ),
            ),
          if (_isCountdownInProgress)
            Center(
              child: Text(
                _currentCountdown > 0 ? _currentCountdown.toString() : "Go!",
                style: const TextStyle(
                  fontSize: 96,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 10)],
                ),
              ),
            ),
          _buildUIControls(),
        ],
      ),
    );
  }

  Widget _buildUIControls() {
    String timerText = _formatDuration(_remainingTestSeconds);

    return Padding(
      padding: const EdgeInsets.all(20.0).copyWith(bottom: 40.0),
      child: Column(
        children: [
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!_isTestStarted && !_isCountdownInProgress)
                  IconButton(
                    icon: const Icon(
                      Icons.flip_camera_ios_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _switchCamera,
                  ),
                if (_isTestStarted)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.analyzer.getFeedback().join('\n'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.durationInSeconds != null)
                            Text(
                              timerText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ...(!_isTestStarted ? [const Spacer()] : []),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          if (_isTestStarted)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCounter(
                    'CORRECT',
                    widget.analyzer.repCount,
                    Colors.green,
                  ),
                  _buildCounter(
                    'INCORRECT',
                    widget.analyzer.wrongRepCount,
                    Colors.red,
                  ),
                  if (_fraudDetected)
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 30,
                    ),
                ],
              ),
            ),
          const Spacer(),
          if (!_isTestStarted && !_isCountdownInProgress)
            ElevatedButton.icon(
              onPressed: _initiateTestSequence,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          if (_isTestStarted)
            ElevatedButton.icon(
              onPressed: _stopAndNavigate,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Stop & Get Result'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCounter(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
