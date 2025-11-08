import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// NEW: Import the main screens for navigation
import 'home_screen.dart';
import 'tests_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

// A dedicated screen for full-screen video playback.
class VideoPreviewScreen extends StatefulWidget {
  final XFile videoFile;

  const VideoPreviewScreen({super.key, required this.videoFile});

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    // Initialize the controller and start playing the video.
    _controller = VideoPlayerController.file(File(widget.videoFile.path))
      ..initialize().then((_) {
        setState(() {}); // Update UI once initialized
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    // Dispose the controller to free up resources.
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Center the video player
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: GestureDetector(
                      onTap: _togglePlayback,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const CircularProgressIndicator(), // Show loading spinner
          ),
          // Play/Pause icon overlay
          Center(
            child: !_isPlaying
                ? Icon(
                    Icons.play_arrow,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 80,
                  )
                : null,
          ),
          // Close button in the top corner
          Positioned(
            top: 40,
            left: 10,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
      // NEW: Added the BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Tests Tab
        selectedItemColor: const Color(0xFF20D36A),
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white, // Ensure the nav bar has a background
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        onTap: (index) {
          // This logic provides a clean navigation stack reset
          switch (index) {
            case 0: // Home
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false, // This removes all previous routes
              );
              break;
            case 1: // Tests
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const TestsScreen()),
                (route) => false,
              );
              break;
            case 2: // Progress
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ProgressScreen()),
                (route) => false,
              );
              break;
            case 3: // Profile
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
                (route) => false,
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
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
      ),
    );
  }
}
