import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// Import all necessary files for navigation and analysis
import 'home_screen.dart';
import 'tests_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'camera_screen.dart';
import 'pose_analyzer.dart';
// Still needed if you retain video review for some tests
import 'report_screen.dart';
import 'report_models.dart';

// --- Global constants for consistent styling ---
const primaryGreen = Color(0xFF20D36A);
const lightGreyButton = Color(0xFFF0F0F0);

// --- 1. Result Screen for RUNNING tests (Now a StatefulWidget) ---
class RunResultScreen extends StatefulWidget {
  final String testTitle;
  final List<String> feedback; // Changed from String to List<String>
  final String imageUrl;
  // final bool hasReviewButton; // Removed as per request
  // final XFile? recordedVideo; // Removed as per request
  final int correctReps;
  final int wrongReps;

  const RunResultScreen({
    super.key,
    required this.testTitle,
    required this.feedback, // Changed
    required this.imageUrl,
    // this.hasReviewButton = false, // Removed
    // this.recordedVideo, // Removed
    this.correctReps = 0,
    this.wrongReps = 0,
  });

  @override
  State<RunResultScreen> createState() => _RunResultScreenState();
}

class _RunResultScreenState extends State<RunResultScreen> {
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Submit Test?'),
          content: const Text('Are you sure you want to submit this result?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog

                // Dynamically create the report from the test results
                final TestReport reportToShow = TestReport(
                  testTitle: widget.testTitle,
                  imageUrl: widget.imageUrl,
                  headlineResult: '00:00', // Placeholder for time
                  resultSummary:
                      'You completed the run. Review the feedback from your coach to see how you can improve your time and endurance for the next attempt.',
                  breakdownMetrics: [
                    ReportMetric(label: 'Time', value: '00:00'), // Placeholder
                    ReportMetric(label: 'Distance', value: '0m'), // Placeholder
                    ReportMetric(
                      label: 'Pace',
                      value: '0\'00"/km',
                    ), // Placeholder
                  ],
                  // --- Placeholder data for fields not available in this context ---
                  comparisonMetrics: [
                    ReportMetric(label: 'Avg. Time', value: '07:30'),
                    ReportMetric(label: 'Personal Best', value: '06:45'),
                  ],
                  coachTips: widget.feedback.map((tip) {
                    return CoachTip(
                      icon: Icons.directions_run,
                      title: 'Running Feedback', // Generic title
                      description: tip,
                    );
                  }).toList(),
                  progressTitle: 'Run Time Over Time',
                  progressValue: '-15s',
                  progressPeriod: 'Last 3 attempts',
                  progressTrend: 'down', // 'up', 'down', or 'flat'
                  progressChartData: [
                    // Dummy chart data
                    const FlSpot(0, 480), // 8:00
                    const FlSpot(1, 465), // 7:45
                    const FlSpot(2, 450), // 7:30
                  ],
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReportScreen(reportData: reportToShow),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final bool canReview = widget.hasReviewButton && widget.recordedVideo != null; // Removed

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, widget.testTitle),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildImagePlaceholder(widget.imageUrl),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildTimeBox('00', 'Minutes'), // Placeholder values
                const SizedBox(width: 16),
                _buildTimeBox('00', 'Seconds'), // Placeholder values
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Distance: 0m',
              style: TextStyle(color: Colors.grey),
            ), // Placeholder
            const SizedBox(height: 24),
            _buildFeedbackSection(widget.feedback), // Pass the list
            const Spacer(),
            Column(
              children: [
                // Review video button removed
                _buildStyledButton(
                  text: 'Retake',
                  onPressed: () {
                    final analyzer = _getAnalyzerForTest(widget.testTitle);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(
                          analyzer: analyzer,
                          testName: widget.testTitle,
                          // durationInSeconds: null, // Consider if duration needs to be passed for retake
                        ),
                      ),
                    );
                  },
                  isFilled: false,
                ),
                const SizedBox(height: 12),
                _buildStyledButton(
                  text: 'Submit',
                  onPressed: () => _showConfirmationDialog(context),
                  isFilled: true,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildTimeBox(String time, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              time,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// --- 2. Result Screen for JUMPING/REP tests (Now a StatefulWidget) ---
class JumpResultScreen extends StatefulWidget {
  final String testTitle;
  final List<String> feedback;
  final int correctReps;
  final int wrongReps;
  final int? testDurationSeconds;
  final XFile? recordedVideo;

  const JumpResultScreen({
    super.key,
    required this.testTitle,
    required this.feedback,
    this.correctReps = 0,
    this.wrongReps = 0,
    this.testDurationSeconds,
    this.recordedVideo,
  });

  @override
  State<JumpResultScreen> createState() => _JumpResultScreenState();
}

class _JumpResultScreenState extends State<JumpResultScreen> {
  String _formatDuration(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds < 0) return 'N/A';
    final duration = Duration(seconds: totalSeconds);
    // Pad with '0' to ensure two digits for minutes and seconds
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Submit Test?'),
          content: const Text('Are you sure you want to submit this result?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog first

                // Dynamically create the report from the test results
                final TestReport reportToShow = TestReport(
                  testTitle: widget.testTitle,
                  imageUrl: 'https://i.imgur.com/G06sW7s.jpeg',
                  headlineResult: '${widget.correctReps} Reps',
                  resultSummary:
                      'You completed ${widget.correctReps} correct reps and had ${widget.wrongReps} incorrect reps in ${_formatDuration(widget.testDurationSeconds)}. Review the feedback for tips on how to improve your form.',
                  breakdownMetrics: [
                    ReportMetric(
                      label: 'Correct Reps',
                      value: widget.correctReps.toString(),
                    ),
                    ReportMetric(
                      label: 'Incorrect Reps',
                      value: widget.wrongReps.toString(),
                    ),
                    ReportMetric(
                      label: 'Total Reps',
                      value: (widget.correctReps + widget.wrongReps).toString(),
                    ),
                    ReportMetric(
                      label: 'Time Taken',
                      value: _formatDuration(widget.testDurationSeconds),
                    ),
                  ],
                  comparisonMetrics: [
                    ReportMetric(label: 'Avg. Reps', value: '12'),
                    ReportMetric(label: 'Personal Best', value: '18'),
                  ],
                  coachTips: widget.feedback.map((tip) {
                    return CoachTip(
                      icon: Icons.check_circle_outline,
                      title: 'Form Feedback',
                      description: tip,
                    );
                  }).toList(),
                  progressTitle: 'Reps Over Time',
                  progressValue: '+2',
                  progressPeriod: 'Last 7 days',
                  progressTrend: 'up',
                  progressChartData: [
                    const FlSpot(0, 8),
                    const FlSpot(1, 10),
                    const FlSpot(2, 9),
                    const FlSpot(3, 11),
                    const FlSpot(4, 12),
                    const FlSpot(5, 14),
                    const FlSpot(6, 15),
                  ],
                  videoFile: widget.recordedVideo,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReportScreen(reportData: reportToShow),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, widget.testTitle),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRepCounter('CORRECT', widget.correctReps, primaryGreen),
                _buildRepCounter('INCORRECT', widget.wrongReps, Colors.red),
              ],
            ),
            const SizedBox(height: 16), // Adjusted spacing
            Center(
              // Centering the time taken text
              child: Text(
                'Time Taken: ${_formatDuration(widget.testDurationSeconds)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16), // Adjusted spacing
            Expanded(child: _buildFeedbackSection(widget.feedback)),
            const Spacer(),
            Column(
              children: [
                _buildStyledButton(
                  text: 'Retake',
                  onPressed: () {
                    final analyzer = _getAnalyzerForTest(widget.testTitle);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(
                          analyzer: analyzer,
                          testName: widget.testTitle,
                        ),
                      ),
                    );
                  },
                  isFilled: false,
                ),
                const SizedBox(height: 12),
                _buildStyledButton(
                  text: 'Submit',
                  onPressed: () => _showConfirmationDialog(context),
                  isFilled: true,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildRepCounter(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: color,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        ),
      ],
    );
  }
}

// --- HELPER FUNCTIONS and WIDGETS ---

PoseAnalyzer _getAnalyzerForTest(String testTitle) {
  final t = testTitle.toLowerCase();
  if (t.contains('push')) {
    return PushUpAnalyzer();
  } else if (t.contains('sit')) {
    return SitUpAnalyzer();
  } else if (t.contains('squat')) {
    return SquatAnalyzer();
  } else if (t.contains('broad')) {
    return StandingBroadJumpAnalyzer();
  } else if (t.contains('vertical') ||
      t.contains('jump') ||
      t.contains('jack')) {
    return StandingVerticalJumpAnalyzer();
  }

  // Default conservative fallback
  return NoAIAnalyzer();
}

AppBar _buildAppBar(BuildContext context, String title) {
  return AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () => Navigator.of(context).pop(),
    ),
    title: Text(
      title,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.info_outline, color: Colors.black),
        onPressed: () {
          // Placeholder for info action
        },
      ),
    ],
    centerTitle: true,
    backgroundColor: Colors.white,
    elevation: 0,
  );
}

Widget _buildImagePlaceholder(String imageUrl) {
  // Check if the imageUrl is a local asset or a network image
  bool isNetworkImage =
      imageUrl.startsWith('http') || imageUrl.startsWith('https');

  return AspectRatio(
    aspectRatio: 16 / 9,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.black12, // Light background for placeholder
        borderRadius: BorderRadius.circular(16),
        image: isNetworkImage
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : DecorationImage(
                image: AssetImage(imageUrl),
                fit: BoxFit.cover,
              ), // Assuming local asset
      ),
      // child: const Icon(Icons.play_circle_outline, color: Colors.white70, size: 60), // Icon can be removed or kept based on preference
    ),
  );
}

// Updated to display a list of feedback points
Widget _buildFeedbackSection(List<String> feedbackPoints) {
  if (feedbackPoints.isEmpty ||
      (feedbackPoints.length == 1 && feedbackPoints.first.isEmpty)) {
    return const Text(
      'No specific feedback points available.',
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      ),
    );
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Feedback',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(
            0xFFF9F9F9,
          ), // Light grey background for the feedback box
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: feedbackPoints.map((point) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

Widget _buildStyledButton({
  required String text,
  required VoidCallback? onPressed,
  required bool isFilled,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isFilled ? primaryGreen : lightGreyButton,
        foregroundColor: isFilled ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        elevation: 0,
        disabledBackgroundColor: Colors.grey.shade300,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

BottomNavigationBar _buildBottomNavBar(BuildContext context) {
  // Logic to determine current index can be more sophisticated
  // For now, it assumes if we are on a result screen, "Tests" was the origin.
  int currentIndex = 1; // Default to 'Tests' tab

  void handleNavBarTap(int index) {
    // Avoid navigating to the current screen again
    if (currentIndex == index &&
        (index == 1 && ModalRoute.of(context)?.settings.name == '/tests')) {
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
        break;
      case 1:
        // If already in a flow that originated from TestsScreen, perhaps just pop.
        // Otherwise, push new TestsScreen. For simplicity, always push and remove.
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
    currentIndex: currentIndex,
    selectedItemColor: primaryGreen,
    unselectedItemColor: Colors.grey.shade600,
    onTap: (index) => handleNavBarTap(index),
    type: BottomNavigationBarType.fixed, // Ensures all items are visible
    showUnselectedLabels: true, // Shows labels for unselected items
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assignment_outlined),
        activeIcon: Icon(Icons.assignment),
        label: 'Tests',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.show_chart_outlined),
        activeIcon: Icon(Icons.show_chart),
        label: 'Progress',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ],
  );
}
