import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:sadhak/tests_screen.dart'; // For TestInfo
import 'package:sadhak/camera_screen.dart'; // For CameraScreen

// Import main screens for the bottom navigation bar (if needed, or remove if not used here)
import 'home_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'util/log.dart';

class TestInstructionScreen extends StatefulWidget {
  final TestInfo testInfo;

  const TestInstructionScreen({super.key, required this.testInfo});

  @override
  State<TestInstructionScreen> createState() => _TestInstructionsScreenState();
}

class _TestInstructionsScreenState extends State<TestInstructionScreen> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.testInfo.demoVideoPath != null &&
        widget.testInfo.demoVideoPath!.isNotEmpty) {
      _controller = VideoPlayerController.asset(widget.testInfo.demoVideoPath!);
      _initializeVideoPlayerFuture = _controller!
          .initialize()
          .then((_) {
            // Ensure the first frame is shown after the video is initialized,
            // and Ccall setState to rebuild the UI.
            setState(() {});
          })
          .catchError((error) {
            // Handle error during initialization, e.g., video not found
            logDebug("Error initializing video: $error");
            setState(() {
              _controller = null; // Clear controller on error
            });
          });
      _controller!.setLooping(true);
    } else {
      // Set _initializeVideoPlayerFuture to a completed future if no video path
      _initializeVideoPlayerFuture = Future.value();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF20D36A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.testInfo.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {
              /* TODO: Show info */
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Demo Video',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (_controller != null && _controller!.value.isInitialized) {
                  return AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        VideoPlayer(_controller!),
                        VideoProgressIndicator(
                          _controller!,
                          allowScrubbing: true,
                        ),
                        _PlayPauseOverlay(controller: _controller!),
                      ],
                    ),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  );
                } else {
                  // If no video or error, show placeholder (e.g., original image or an icon)
                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                        image: widget.testInfo.imageUrl.isNotEmpty
                            ? DecorationImage(
                                image: AssetImage(widget.testInfo.imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          widget.testInfo.imageUrl.isNotEmpty
                              ? Icons.play_circle_outline
                              : Icons.videocam_off,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Test Rules',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: widget.testInfo.rules.length,
                itemBuilder: (context, index) {
                  return _buildRule(widget.testInfo.rules[index]);
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to CameraScreen with all required parameters
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraScreen(
                        analyzer: widget.testInfo.analyzer,
                        testName: widget.testInfo.title,
                        durationSeconds: widget.testInfo.durationInSeconds ?? 60,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text('Take Test', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildRule(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayPauseOverlay extends StatefulWidget {
  final VideoPlayerController controller;

  const _PlayPauseOverlay({required this.controller});

  @override
  State<_PlayPauseOverlay> createState() => _PlayPauseOverlayState();
}

class _PlayPauseOverlayState extends State<_PlayPauseOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: widget.controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              widget.controller.value.isPlaying
                  ? widget.controller.pause()
                  : widget.controller.play();
            });
          },
        ),
      ],
    );
  }
}

// Common bottom navigation bar
BottomNavigationBar _buildBottomNavBar(BuildContext context) {
  const primaryGreen = Color(0xFF20D36A);
  void handleNavBarTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
        break;
      case 1:
        // If you want to go back to TestsScreen, ensure it's imported and TestInfo is handled if it needs it.
        // For now, this assumes TestsScreen() constructor is parameterless.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TestsScreen()),
          (route) => false,
        );
        break;
      case 2:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ProgressScreen()),
          (route) => false,
        );
        break;
      case 3:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
          (route) => false,
        );
        break;
    }
  }

  return BottomNavigationBar(
    currentIndex:
        1, // This might need to be dynamic if TestInstructionScreen can be accessed from different tabs
    selectedItemColor: primaryGreen,
    unselectedItemColor: Colors.grey.shade600,
    onTap: handleNavBarTap,
    type: BottomNavigationBarType.fixed,
    showUnselectedLabels: true,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Tests'),
      BottomNavigationBarItem(
        icon: Icon(Icons.show_chart_outlined),
        label: 'Progress',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Profile',
      ),
    ],
  );
}
