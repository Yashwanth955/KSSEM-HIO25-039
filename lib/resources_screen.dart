import 'package:flutter/material.dart';

// Import main screens for the bottom navigation bar
import 'home_screen.dart';
import 'tests_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Resources',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildSectionTitle('Warm-up & Stretching'),
            _buildResourceCard(
              label: 'Guide',
              title: 'Dynamic Warm-up',
              description:
                  'Prepare your body for activity with dynamic movements.',
              imageUrl: 'https://i.imgur.com/eYn6p5A.png', // Placeholder
            ),
            _buildResourceCard(
              label: 'Guide',
              title: 'Static Stretching',
              description: 'Improve flexibility with static stretches.',
              imageUrl: 'https://i.imgur.com/7aD4wwy.jpeg', // Placeholder
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Safety Tips'),
            _buildResourceCard(
              label: 'Tip',
              title: 'Proper Form',
              description:
                  'Maintain correct form during exercises to prevent injuries.',
              imageUrl: 'https://i.imgur.com/gK2x3m0.jpeg', // Placeholder
            ),
            _buildResourceCard(
              label: 'Tip',
              title: 'Listen to Your Body',
              description: 'Stop if you feel pain or discomfort.',
              imageUrl: 'https://i.imgur.com/9C0F1g1.jpeg', // Placeholder
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(
        context,
        0,
      ), // Changed to index 0 for home
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search resources',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildResourceCard({
    required String label,
    required String title,
    required String description,
    required String imageUrl,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A common bottom navigation bar for all secondary screens
BottomNavigationBar _buildBottomNavBar(BuildContext context, int currentIndex) {
  void handleNavBarTap(int index) {
    // Do not navigate if already on the selected screen
    if (currentIndex == index) return;

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

  return BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: handleNavBarTap,
    selectedItemColor: const Color(0xFF20D36A),
    unselectedItemColor: Colors.grey.shade600,
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
