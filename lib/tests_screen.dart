// lib/tests_screen.dart
import 'package:flutter/material.dart';
import 'test_instruction_screen.dart';
import 'pose_analyzer.dart';

// Import main screens for the bottom navigation bar
import 'home_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'db_viewer_screen.dart';

// NEW: A model to hold the data for each test card
class TestInfo {
  final String title;
  final String description;
  final String imageUrl;
  final PoseAnalyzer analyzer; // The specific analyzer for this test
  final List<String> rules;
  final String category; // To group tests
  final String? demoVideoPath; // Added for demo video
  final int? durationInSeconds; // Added for timer

  TestInfo({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.analyzer,
    required this.rules,
    required this.category,
    this.demoVideoPath, // Added to constructor
    this.durationInSeconds, // Added to constructor
  });
}

// NEW: Moved allTests to be a top-level variable
final List<TestInfo> allTests = [
  // --- Flexibility Test ---
  TestInfo(
    category: 'Flexibility Test',
    title: 'Sit and Reach Test',
    description: 'Measure flexibility of lower back and hamstrings.',
    imageUrl: 'assets/images/sitandreach.png', // fixed path
    analyzer: SitAndReachAnalyzer(),
    rules: [
      'Sit on the floor with legs extended straight ahead. Shoes should be off.',
      'Place the soles of your feet flat against the testing box.',
      'Keeping your legs straight, slowly reach forward with both hands as far as possible.',
      'Hold the position for two seconds while the distance is recorded.',
    ],
    demoVideoPath: null,
    durationInSeconds: null,
  ),

  // --- Strength Test ---
  TestInfo(
    category: 'Strength Test',
    title: 'Push-Up Test',
    description: 'Assess upper body strength and endurance.',
    imageUrl: 'assets/images/pushups.png', // fixed path
    analyzer: PushUpAnalyzer(), // Push-up analyzer
    rules: [
      'Start in a high plank position with hands shoulder-width apart and body in a straight line.',
      'Lower your body until your chest is about a fist\'s width from the ground.',
      'Push back up to the starting position, keeping your core engaged.',
      'Perform as many repetitions as possible without breaking form.',
    ],
    demoVideoPath: 'assets/demovideo/pushup_instruction.mp4',
    durationInSeconds: 60,
  ),

  // --- Power Test ---
  TestInfo(
    category: 'Power Test',
    title: 'Standing Broad Jump',
    description: 'Evaluate explosive leg power.',
    imageUrl: 'assets/images/standingbroadjump.png', // fixed path
    analyzer: StandingBroadJumpAnalyzer(), // Broad jump analyzer
    rules: [
      'Stand behind a line with feet slightly apart.',
      'Perform a two-foot take-off and landing, swinging your arms and bending knees to provide forward drive.',
      'Jump as far as possible, landing on both feet without falling backwards.',
      'The distance is measured from the take-off line to the back of your heels.',
    ],
    demoVideoPath: null,
    durationInSeconds: null,
  ),
  TestInfo(
    category: 'Power Test',
    title: 'Standing Vertical Jump',
    description: 'Evaluate vertical jump height.',
    imageUrl: 'assets/images/standingverticaljump.png', // fixed path
    analyzer: StandingVerticalJumpAnalyzer(), // Vertical jump estimation
    rules: [
      'Stand beside a wall and reach up to mark your standing reach.',
      'From a standing position, squat down and jump as high as you can.',
      'Touch the wall at the highest point of your jump to make a second mark.',
      'The distance between the two marks is your vertical jump height.',
    ],
    demoVideoPath: null,
    durationInSeconds: null,
  ),
  TestInfo(
    category: 'Power Test',
    title: 'Medicine Ball Throw',
    description: 'Measure upper body power.',
    imageUrl: 'assets/images/medicineballthrow.png', // fixed path
    analyzer: MedicineBallThrowAnalyzer(), // Medicine ball throw analyzer
    rules: [
      'Stand with your back to the throwing direction, feet shoulder-width apart.',
      'Hold the medicine ball with both hands at your chest.',
      'Squat down and then explosively extend your body upwards and backwards.',
      'Throw the ball over your head as far as possible behind you.',
    ],
    demoVideoPath: null,
    durationInSeconds: null,
  ),

  // --- Speed Test ---
  TestInfo(
    category: 'Speed Test',
    title: '30mts Standing Start',
    description: 'Measure sprinting speed over 30 meters.',
    imageUrl: 'assets/images/standingrun.png', // fixed path
    analyzer: SprintAnalyzer(), // Sprint approximated with SprintAnalyzer
    rules: [
      'Stand behind the starting line in a stationary position.',
      'On the \'Go\' signal, sprint as fast as possible for 30 meters.',
      'Your time is recorded as you cross the 30-meter finish line.',
      'Ensure you run through the finish line at full speed.',
    ],
    demoVideoPath: null,
    durationInSeconds: null,
  ),

  // --- Agility Test ---
  TestInfo(
    category: 'Agility Test',
    title: '4*10mts Shuttle Run',
    description: 'Measure speed and agility.',
    imageUrl: 'assets/images/shuttlerun1.png', // fixed path
    analyzer: ShuttleRunAnalyzer(), // Shuttle run analyzer
    rules: [
      'Place two markers 10 meters apart. Start at one marker.',
      'On the \'Go\' signal, sprint to the opposite marker.',
      'Pick up a block (or touch the line) and sprint back to the start.',
      'Repeat the process. The test is complete when you cross the starting line.',
    ],
    demoVideoPath: null,
    durationInSeconds: null,
  ),

  // --- Endurance Run ---
  TestInfo(
    category: 'Endurance Run',
    title: '800mts Run',
    description: 'Endurance run for U12 age group.',
    imageUrl: 'assets/images/800mrun.png', // fixed path
    analyzer: EnduranceRunAnalyzer(), // Endurance run analyzer
    rules: [
      'Start at the designated starting line on a 400m track.',
      'On the \'Go\' signal, begin running at a steady, sustainable pace.',
      'Complete two full laps of the 400m track (or the full 800m distance)',
      'Your total time is recorded as you cross the finish line.',
    ],
    demoVideoPath: null,
    durationInSeconds: null,
  ),
  TestInfo(
    category: 'Endurance Run',
    title: '1.6km Run',
    description: 'Endurance run for 12+ age group.',
    imageUrl: 'assets/images/1.6km.png', // fixed path
    analyzer: EnduranceRunAnalyzer(), // Endurance run analyzer
    rules: [
      'Start at the designated starting line on a track or measured course.',
      'On the \'Go\' signal, begin running at a pace you can maintain for the full distance.',
      'Complete four full laps of a 400m track (or the full 1.6km distance).',
      'Your total time to complete the distance is recorded as your score.',
    ],
    demoVideoPath: null,
    durationInSeconds: null,
  ),
];

class TestsScreen extends StatelessWidget {
  const TestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Group tests by category
    final Map<String, List<TestInfo>> testsByCategory = {};
    for (var test in allTests) {
      testsByCategory.putIfAbsent(test.category, () => []).add(test);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Fitness Tests',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'View DB',
            icon: const Icon(Icons.storage, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DbViewerScreen()),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 24),
          const Text(
            'Select a Test',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Dynamically build test categories and cards
          ...testsByCategory.keys.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTestCategoryTitle(category),
                ...testsByCategory[category]!.map((test) {
                  return _buildTestCard(
                    context,
                    test: test, // Pass the whole test object
                  );
                }),
              ],
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search Tests',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Renamed from _buildTestCategory to _buildTestCategoryTitle for clarity
  Widget _buildTestCategoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTestCard(BuildContext context, {required TestInfo test}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestInstructionScreen(testInfo: test),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      test.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12), // Added space
                    OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to the specific test instruction or result page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TestInstructionScreen(testInfo: test),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_circle_outline, size: 18),
                      label: const Text('Start'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  // MODIFIED from Image.network
                  test.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ), // MODIFIED for better asset error indication
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
        // Do nothing, we are on this screen
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
    currentIndex: 1, // Tests Tab
    onTap: handleNavBarTap,
    selectedItemColor: primaryGreen,
    unselectedItemColor: Colors.grey.shade600,
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
