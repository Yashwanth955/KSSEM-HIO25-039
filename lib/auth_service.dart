// lib/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'util/log.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Get the stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with Email & Password
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // You can handle specific errors here, like 'user-not-found' or 'wrong-password'
      logDebug(e.message ?? 'Auth error');
      return null;
    }
  }

  // Sign up with Email & Password
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Handle errors like 'email-already-in-use'
      logDebug(e.message ?? 'Auth error');
      return null;
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential result = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      logDebug(e.message ?? 'Google sign-in error');
      return null;
    }
  }

  // Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      logDebug('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      logDebug('Error sending password reset email: ${e.message}');
      // Optionally, rethrow the exception or return a bool to indicate success/failure
    }
  }

  // Sign out
  // In lib/auth_service.dart

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
      logDebug("Signed out from Google.");
    } catch (e) {
      logDebug("Error signing out from Google: $e");
    }

    await _firebaseAuth.signOut();
    logDebug("Signed out from Firebase.");
  }
}
