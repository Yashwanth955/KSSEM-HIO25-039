import 'package:flutter/material.dart';
import 'widgets/glass_card.dart';

// Import services and models
import 'isar_service.dart';
import 'badge_model.dart' as model;

// Import main screens for the bottom navigation bar
import 'home_screen.dart';
import 'tests_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isarService = IsarService();

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Achievements',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Earned'),
                  const SizedBox(height: 16),
                  FutureBuilder<List<model.Badge>>(
                    future: isarService.getEarnedBadges(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error loading badges.'),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assests/images/badges.png',
                                  height: 100,
                                  color: Colors.grey.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No earned badges yet. Keep testing!',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      final badges = snapshot.data!;
                      return _buildBadgesGrid(badges, isEarned: true);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Unearned'),
                  const SizedBox(height: 16),
                  FutureBuilder<List<model.Badge>>(
                    future: isarService.getUnearnedBadges(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error loading badges.'),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Congratulations, you have earned all badges!',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        );
                      }
                      final badges = snapshot.data!;
                      return _buildBadgesGrid(badges, isEarned: false);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBadgesGrid(List<model.Badge> badges, {bool isEarned = true}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badges.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final badge = badges[index];
        return _buildBadgeItem(
          context,
          name: badge.name,
          description: badge.description,
          imageUrl: 'assests/images/badges.png',
          isEarned: isEarned,
        );
      },
    );
  }

  Widget _buildBadgeItem(
    BuildContext context, {
    required String name,
    required String description,
    required String imageUrl,
    bool isEarned = true,
  }) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: isEarned
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : Colors.grey.withValues(alpha: 0.15),
            child: Image.asset(
              'assests/images/badges.png',
              color: isEarned
                  ? theme.colorScheme.primary
                  : Colors.grey.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Common bottom navigation bar for all secondary screens
BottomNavigationBar _buildBottomNavBar(BuildContext context) {
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

  final theme = Theme.of(context);
  return BottomNavigationBar(
    currentIndex:
        1, // Set to a relevant index for this screen, e.g., Tests or Home
    onTap: handleNavBarTap,
    selectedItemColor: theme.colorScheme.primary,
    unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
    type: BottomNavigationBarType.fixed,
    showUnselectedLabels: true,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
      BottomNavigationBarItem(
        icon: Icon(Icons.assignment_outlined),
        label: 'Tests',
      ),
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
