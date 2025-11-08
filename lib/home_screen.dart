import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'isar_service.dart';
import 'user_model.dart';
import 'test_result.dart';
import 'leaderboard_model.dart';
import 'badge_model.dart' as app;
import 'sponsor_model.dart';

import 'tests_screen.dart';
import 'package:sadhak/leaderboard_screen.dart';
import 'package:sadhak/sponsor_screen.dart';
import 'package:sadhak/resources_screen.dart';
import 'package:sadhak/badges_screen.dart';
import 'package:sadhak/progress_screen.dart';
import 'package:sadhak/profile_screen.dart';
import 'streaks_screen.dart';
import 'notifications_screen.dart';
import 'chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _userProfile;
  List<TestResult> _allResults = [];
  List<LeaderboardEntry> _leaderboard = [];
  List<app.Badge> _badges = [];
  List<Sponsor> _sponsors = [];

  String _selectedTimeFrame = 'Daily';
  List<FlSpot> _chartData = [];
  final String _selectedChallenge = '1.6km Run';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final isarService = Provider.of<IsarService>(context, listen: false);
    final user = await isarService.getCurrentUserProfile();
    final results = await isarService.getAllTestResults();
    final leaderboard = await isarService.getLeaderboard();
    final badges = await isarService.getEarnedBadges();
    final sponsors = await isarService.getAllSponsors();

    if (mounted) {
      setState(() {
        _userProfile = user;
        _allResults = results;
        _leaderboard = leaderboard;
        _badges = badges;
        _sponsors = sponsors;
        _updateChartData();
      });
    }
  }

  double parseScore(String resultValue) {
    final score = double.tryParse(resultValue.split(' ').first);
    return score ?? 0.0;
  }

  void _updateChartData() {
    if (_allResults.isEmpty) {
      _chartData = [];
      if (mounted) setState(() {});
      return;
    }

    final now = DateTime.now();
    Map<int, double> bestScores = {};

    if (_selectedTimeFrame == 'Daily') {
      for (int i = 0; i < 7; i++) {
        final day = now.subtract(Duration(days: 6 - i));
        final dayResults = _allResults.where((r) {
          return r.date.year == day.year &&
              r.date.month == day.month &&
              r.date.day == day.day;
        }).toList();

        double bestScoreOfDay = 0;
        for (var result in dayResults) {
          double score = parseScore(result.resultValue);
          if (score > bestScoreOfDay) bestScoreOfDay = score;
        }
        bestScores[i] = bestScoreOfDay;
      }

      _chartData = List.generate(7, (index) {
        double lastScore = 0;
        if (bestScores.containsKey(index)) {
          lastScore = bestScores[index]!;
        }
        return FlSpot(index.toDouble(), lastScore);
      });
    } else if (_selectedTimeFrame == 'Weekly') {
      for (int i = 0; i < 4; i++) {
        final weekStart = now.subtract(
          Duration(days: now.weekday - 1 + (3 - i) * 7),
        );
        final weekEnd = weekStart.add(const Duration(days: 7));
        final weekResults = _allResults
            .where((r) => r.date.isAfter(weekStart) && r.date.isBefore(weekEnd))
            .toList();
        double bestScoreOfWeek = 0;
        for (var result in weekResults) {
          double score = parseScore(result.resultValue);
          if (score > bestScoreOfWeek) bestScoreOfWeek = score;
        }
        bestScores[i] = bestScoreOfWeek;
      }
      _chartData = List.generate(
        4,
        (index) => FlSpot(index.toDouble(), bestScores[index] ?? 0.0),
      );
    } else if (_selectedTimeFrame == 'Monthly') {
      for (int i = 0; i < 6; i++) {
        final monthStart = DateTime(now.year, now.month - (5 - i), 1);
        final monthEnd = DateTime(now.year, now.month - (4 - i), 0);
        final monthResults = _allResults
            .where(
              (r) => r.date.isAfter(monthStart) && r.date.isBefore(monthEnd),
            )
            .toList();
        double bestScoreOfMonth = 0;
        for (var result in monthResults) {
          double score = parseScore(result.resultValue);
          if (score > bestScoreOfMonth) bestScoreOfMonth = score;
        }
        bestScores[i] = bestScoreOfMonth;
      }
      _chartData = List.generate(
        6,
        (index) => FlSpot(index.toDouble(), bestScores[index] ?? 0.0),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    // Use a local variable for the context to avoid async gaps.
    final navContext = context;
    if (!mounted) return;

    // Set state to update the UI, then navigate.
    setState(() {
      _selectedIndex = index;
    });

    // Use pushAndRemoveUntil for root navigation to avoid stack buildup.
    switch (index) {
      case 0:
        // Already on home, setState is enough to update UI if needed.
        break;
      case 1:
        Navigator.pushAndRemoveUntil(
          navContext,
          MaterialPageRoute(builder: (context) => const TestsScreen()),
          (route) => false,
        );
        break;
      case 2:
        Navigator.pushAndRemoveUntil(
          navContext,
          MaterialPageRoute(builder: (context) => const ProgressScreen()),
          (route) => false,
        );
        break;
      case 3:
        Navigator.pushAndRemoveUntil(
          navContext,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
          (route) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF20D36A);
    const darkCardBg = Color(0xFF0E1F3C);
    const lightBg = Color(0xFFF9F9F9);
    const greyText = Color(0xFF6F6F6F);

    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(context),
                const SizedBox(height: 24),
                _buildGreetingSection(),
                const SizedBox(height: 24),
                _buildConsistencyBanner(context, primaryGreen, darkCardBg),
                const SizedBox(height: 20),
                _buildStartTestButton(context, primaryGreen),
                const SizedBox(height: 30),
                _buildBestScoreSection(primaryGreen, greyText),
                const SizedBox(height: 30),
                _buildLeaderboardSection(context, greyText),
                const SizedBox(height: 30),
                _buildBadgesSection(context, darkCardBg, greyText),
                const SizedBox(height: 30),
                _buildSponsorMatchingCard(context),
                const SizedBox(height: 20),
                _buildDailyChallengeCard(primaryGreen, _selectedChallenge),
                const SizedBox(height: 20),
                _buildResourcesSection(context, greyText),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(
        primaryGreen,
        greyText,
        _selectedIndex,
        _onItemTapped,
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Sadhak',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatbotScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined, size: 28),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGreetingSection() {
    return Text(
      'Hello, ${_userProfile?.name ?? 'Athlete'}',
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildConsistencyBanner(
    BuildContext context,
    Color primaryGreen,
    Color darkCardBg,
  ) {
    return Card(
      color: darkCardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1519861531473-9200262188bf?q=80&w=2071',
            ),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                "🎉 You've been consistent for 3 days!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StreaksScreen()),
              ),
              style: TextButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('View past'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartTestButton(BuildContext context, Color primaryGreen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TestsScreen()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Start Fitness Test',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBestScoreSection(Color primaryGreen, Color greyText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Best Score',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedTimeFrame,
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 2,
              style: TextStyle(color: greyText, fontWeight: FontWeight.bold),
              underline: Container(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTimeFrame = newValue;
                    _updateChartData();
                  });
                }
              },
              items: <String>['Daily', 'Weekly', 'Monthly']
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 120,
          child: _chartData.isEmpty
              ? const Center(
                  child: Text('Save test results to see your scores!'),
                )
              : LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _chartData,
                        isCurved: true,
                        color: primaryGreen,
                        barWidth: 4,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              primaryGreen.withAlpha(77), // 30% opacity
                              primaryGreen.withAlpha(0), // 0% opacity
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Icon(Icons.arrow_forward_ios, size: 16),
      ],
    );
  }

  Widget _buildLeaderboardSection(BuildContext context, Color greyText) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
      ),
      child: Column(
        children: [
          _buildSectionHeader('Leaderboard'),
          const SizedBox(height: 16),
          if (_leaderboard.isEmpty)
            const Text('No leaderboard data available yet.')
          else
            ..._leaderboard.take(3).map((entry) {
              return _buildLeaderboardEntry(
                entry.rank.toString(),
                entry.name,
                '${entry.score} pts',
                isUser: entry.name == _userProfile?.name,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLeaderboardEntry(
    String rank,
    String name,
    String score, {
    bool isUser = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser
            ? Colors.green.withAlpha(26)
            : Colors.transparent, // 10% opacity
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rank, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(score, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(
    BuildContext context,
    Color darkCardBg,
    Color greyText,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BadgesScreen()),
      ),
      child: Column(
        children: [
          _buildSectionHeader('Badges'),
          const SizedBox(height: 16),
          if (_badges.isEmpty)
            const Text('No badges earned yet.')
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _badges
                  .take(3)
                  .map(
                    (badge) =>
                        const Icon(Icons.star, color: Colors.amber, size: 40),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSponsorMatchingCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SponsorScreen()),
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(
                Icons.business_center,
                size: 40,
                color: Colors.blueAccent,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sponsor Matching',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_sponsors.isNotEmpty)
                      Text(
                        'You have matched with ${_sponsors.length} sponsors!',
                      )
                    else
                      const Text(
                        'Find sponsors who value your athletic skills.',
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChallengeCard(
    Color primaryGreen,
    String selectedChallenge,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Challenge',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              selectedChallenge,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Complete this to maintain your streak!'),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesSection(BuildContext context, Color greyText) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ResourcesScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Resources'),
          const SizedBox(height: 16),
          // Placeholder for resources
          const Text(
            'Explore articles and videos to improve your performance.',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(
    Color primaryGreen,
    Color greyText,
    int currentIndex,
    void Function(int) onTap,
  ) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: primaryGreen,
      unselectedItemColor: greyText,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Tests'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: onTap,
    );
  }
}
