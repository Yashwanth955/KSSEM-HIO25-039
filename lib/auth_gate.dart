// lib/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ADDED
import 'app_state.dart'; // ADDED
import 'util/log.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'isar_service.dart'; // Import IsarService
import 'user_model.dart'; // Import UserProfile

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final IsarService _isarService = IsarService();

  Future<void> _fetchAndUpdateUserProfileInAppState(
    BuildContext context,
    User firebaseUser,
  ) async {
    // Capture AppState early to avoid using BuildContext after async gaps.
    final appState = Provider.of<AppState>(context, listen: false);
    UserProfile? userProfile = await _isarService.getUserProfileByFirebaseUid(
      firebaseUser.uid,
    );

    if (userProfile == null) {
      // Profile doesn't exist, create and save a new one
      logDebug(
        "AUTH_GATE: No profile found for UID: ${firebaseUser.uid}. Creating new one.",
      );
      userProfile = UserProfile(firebaseUid: firebaseUser.uid)
        ..email = firebaseUser.email ?? 'N/A'
        ..name = firebaseUser.displayName ?? 'New User'
        ..age = 0
        ..sport = 'Fitness'
        ..profilePhotoPath = firebaseUser.photoURL ?? ''
        ..height = 0.0
        ..weight = 0.0
        ..mobileNumber = firebaseUser.phoneNumber ?? '';
      await _isarService.saveUserProfile(userProfile);
    } else {
      logDebug("AUTH_GATE: Profile found for UID: ${firebaseUser.uid}.");
    }

    // Update AppState
    if (mounted) {
      appState.setUserProfile(userProfile);
    }
    logDebug("AUTH_GATE: AppState updated for UID: ${firebaseUser.uid}");
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(key: ValueKey("auth_waiting")),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final firebaseUser = snapshot.data!;
          return FutureBuilder<void>(
            future: _fetchAndUpdateUserProfileInAppState(context, firebaseUser),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      key: ValueKey("user_profile_loading"),
                    ),
                  ),
                );
              }
              if (asyncSnapshot.hasError) {
                logDebug(
                  "AUTH_GATE: Error during _fetchAndUpdateUserProfileInAppState: ${asyncSnapshot.error}",
                );
                // Optionally, show an error screen or a retry mechanism
                return const Scaffold(
                  body: Center(child: Text("Error loading user data.")),
                );
              }
              return const HomeScreen();
            },
          );
        } else {
          // User is not logged in, clear AppState's profile
          // Ensure this is called safely, e.g., after the build phase if it causes rebuilds.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<AppState>(context, listen: false).setUserProfile(null);
            logDebug("AUTH_GATE: User logged out, AppState profile cleared.");
          });
          return const LoginScreen();
        }
      },
    );
  }
}
