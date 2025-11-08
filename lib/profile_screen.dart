import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'util/log.dart';

// Import services and models
import 'isar_service.dart';
import 'user_model.dart';
import 'auth_service.dart';
import 'app_state.dart';

// Import main screens for navigation
import 'home_screen.dart';
import 'tests_screen.dart';
import 'progress_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Consider using a logger or showing a snackbar for error reporting
      logDebug('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    const lightBg = Color(0xFFF9F9F9);

    final isarService = Provider.of<IsarService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: lightBg,
        elevation: 0,
      ),
      body: FutureBuilder<UserProfile?>(
        future: isarService.getCurrentUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          UserProfile? userProfile = snapshot.data;

          // Provide fallback dummy data only if userProfile is null
          userProfile ??= UserProfile(
            firebaseUid:
                "SFf4ClDM5NPQ0ypFUBHZX7shAzi1", // Keeping the UID you provided
            name: 'Yash',
            email: 'yashu1234@sai.com',
            mobileNumber: '+91 98765 43210',
            age: 32,
            sport: 'Running',
            height: 178.0, // cm
            weight: 75.0, // kg
            profilePhotoPath:
                null, // This will allow your placeholder 'assets/images/placeholder.png' to be used
            gender: 'Male',
            coachName: 'Ravi Shastri', // Example coach name
            coachPhoneNumber: '+91 87654 32109',
            coachWhatsappNumber: '+91 85469 09047',
            isCoachUser: false, // Assuming this is an athlete's profile
            assignedAthleteIds:
                [], // Athletes typically don't have assigned athletes
            createdAt: DateTime.now().subtract(
              const Duration(days: 90),
            ), // Joined 3 months ago
            location: 'Bangalore, India',
          );

          // Use 'userProfile' (which is now guaranteed to be non-null)
          // for the rest of the UI.

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              children: [
                // Profile avatar without placeholder asset dependency
                Builder(
                  builder: (_) {
                    final up = userProfile!;
                    final hasPhoto =
                        up.profilePhotoPath != null &&
                        up.profilePhotoPath!.isNotEmpty;
                    if (hasPhoto) {
                      return CircleAvatar(
                        radius: 60,
                        backgroundImage: FileImage(File(up.profilePhotoPath!)),
                      );
                    }
                    // Fallback: initials avatar
                    final displayName = (up.name ?? 'User').trim();
                    final parts = displayName.split(' ');
                    final initials = parts.length >= 2
                        ? (parts[0].isNotEmpty ? parts[0][0] : '') +
                              (parts[1].isNotEmpty ? parts[1][0] : '')
                        : (displayName.isNotEmpty ? displayName[0] : 'U');
                    return CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      child: Text(
                        initials.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  userProfile.name ?? 'User Name',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Age: ${userProfile.age ?? 'N/A'}, Sport: ${userProfile.sport ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF20D36A),
                  ),
                ),
                const SizedBox(height: 32),

                if (userProfile.coachName !=
                    null) // Check if coach assigned (can be athlete's or coach's own)
                  _buildCoachSection(
                    context: context,
                    // Display based on whether the user is a coach or an athlete with an assigned coach
                    title: userProfile.isCoachUser
                        ? 'Your Coach Profile'
                        : 'Assigned Coach',
                    name: userProfile.coachName!,
                    phone: userProfile.coachPhoneNumber,
                    whatsapp: userProfile.coachWhatsappNumber,
                    isCurrentUserCoach: userProfile
                        .isCoachUser, // Pass this to potentially alter UI
                  ),

                const SizedBox(height: 32),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Basic Details',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  label1: 'Mobile',
                  value1: userProfile.mobileNumber ?? 'N/A',
                  label2: 'Sport',
                  value2: userProfile.sport ?? 'N/A',
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  label1: 'Height',
                  value1:
                      '${userProfile.height?.toStringAsFixed(1) ?? 'N/A'} cm',
                  label2: 'Weight',
                  value2:
                      '${userProfile.weight?.toStringAsFixed(1) ?? 'N/A'} kg',
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  label1: 'Location',
                  value1: userProfile.location ?? 'N/A',
                  label2: 'Gender',
                  value2: userProfile.gender ?? 'N/A', // Added Gender
                ),
                const SizedBox(height: 32),

                if (userProfile.isCoachUser &&
                    userProfile.assignedAthleteIds.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Assigned Athletes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userProfile.assignedAthleteIds.join(', '),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                ],

                _buildProfileOption(
                  icon: Icons.description_outlined,
                  text: 'Relevant Documents',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.edit_outlined,
                  text: 'Edit Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    ).then((_) {
                      if (mounted) {
                        setState(() {});
                      }
                    });
                  },
                ),
                _buildProfileOption(
                  icon: Icons.notifications_outlined,
                  text: 'Notification Settings',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.shield_outlined,
                  text: 'Privacy Settings',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.help_outline,
                  text: 'Legal & Support',
                  onTap: () {},
                ),
                const Divider(height: 24),
                _buildProfileOption(
                  icon: Icons.logout,
                  text: 'Sign Out',
                  onTap: () async {
                    final appStateCaptured = appState; // Use captured appState
                    final navigatorCaptured = Navigator.of(context);

                    await authService.signOut();

                    appStateCaptured.setUserProfile(null);
                    if (mounted) {
                      navigatorCaptured.pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildCoachSection({
    required BuildContext context,
    required String title, // Added title
    required String name,
    String? phone,
    String? whatsapp,
    bool isCurrentUserCoach = false, // Added to know context
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=10',
                  ), // Placeholder
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // No longer needed: const Text('Assigned Coach', style: TextStyle(color: Colors.grey)),
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                if (phone != null)
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () => _launchURL('tel:$phone'),
                  ),
                if (whatsapp != null)
                  IconButton(
                    icon: const Icon(Icons.message, color: Colors.green),
                    onPressed: () => _launchURL('https://wa.me/$whatsapp'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Refactored to take two items for a row
  Widget _buildDetailRow(
    BuildContext context, {
    required String label1,
    required String value1,
    String? label2,
    String? value2,
  }) {
    return Row(
      children: [
        _buildDetailItem(label1, value1),
        if (label2 != null && value2 != null) ...[
          // If the second item exists
          const SizedBox(width: 16), // Spacing between items
          _buildDetailItem(label2, value2),
        ] else ...[
          // If the second item does not exist
          const Expanded(child: SizedBox()), // Fill remaining space
        ],
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icon, color: Colors.grey.shade800),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar(BuildContext context) {
    void handleNavBarTap(int index) {
      final navigator = Navigator.of(context);
      // Avoid navigating to the same screen if it's already active
      if (ModalRoute.of(context)?.settings.name ==
              _getRouteNameForIndex(index) &&
          index != 3 /* allow profile refresh */ ) {
        return;
      }
      if (index == 3 && ModalRoute.of(context)?.settings.name == '/profile') {
        if (mounted) setState(() {}); // Refresh profile if tapped again
        return;
      }

      switch (index) {
        case 0:
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
              settings: const RouteSettings(name: '/home'),
            ),
            (route) => false,
          );
          break;
        case 1:
          navigator.pushReplacement(
            MaterialPageRoute(
              builder: (context) => const TestsScreen(),
              settings: const RouteSettings(name: '/tests'),
            ),
          );
          break;
        case 2:
          navigator.pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ProgressScreen(),
              settings: const RouteSettings(name: '/progress'),
            ),
          );
          break;
        case 3:
          // If not already on profile, navigate. If on profile, handled by setState above for refresh.
          if (ModalRoute.of(context)?.settings.name != '/profile') {
            navigator.pushReplacement(
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
                settings: const RouteSettings(name: '/profile'),
              ),
            );
          }
          break;
      }
    }

    return BottomNavigationBar(
      currentIndex: _getCurrentIndex(context),
      onTap: handleNavBarTap,
      selectedItemColor: const Color(0xFF20D36A),
      unselectedItemColor: Colors.grey.shade600,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
          tooltip: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          label: 'Tests',
          tooltip: 'Tests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart_outlined),
          label: 'Progress',
          tooltip: 'Progress',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
          tooltip: 'Profile',
        ),
      ],
    );
  }

  // Helper to get route name for comparison
  String? _getRouteNameForIndex(int index) {
    switch (index) {
      case 0:
        return '/home';
      case 1:
        return '/tests';
      case 2:
        return '/progress';
      case 3:
        return '/profile';
      default:
        return null;
    }
  }

  // Helper to determine current index for BottomNavBar based on route
  int _getCurrentIndex(BuildContext context) {
    final String? currentRouteName = ModalRoute.of(context)?.settings.name;
    if (currentRouteName == '/home') return 0;
    if (currentRouteName == '/tests') return 1;
    if (currentRouteName == '/progress') return 2;
    if (currentRouteName == '/profile') return 3;
    return 3; // Default to profile if route unknown
  }
}
