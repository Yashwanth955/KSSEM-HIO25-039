// lib/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Added for Provider
import 'auth_service.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'basic_details_screen.dart';
import 'isar_service.dart';
// import 'package:sadhak/l10n/app_localizations.dart'; // Temporarily removed for debugging

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _isarService = IsarService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    final user = await authService.signInWithEmailAndPassword(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (user == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login failed. Please check your credentials."),
        ), // Hardcoded string
      );
    }
  }

  void _googleSignIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() {
      _isLoading = true;
    });
    final user = await authService.signInWithGoogle();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    if (user != null) {
      final userProfile = await _isarService.getUserProfileById(user.uid);
      if (!mounted) return;
      if (userProfile == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BasicDetailsScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1FFF83);
    final textFieldBorder = OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(12),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text(
                "SADHAK",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ), // Hardcoded string
              const SizedBox(height: 16),
              const Text(
                "Welcome Back!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ), // Hardcoded string
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: textFieldBorder,
                ), // Hardcoded string
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: textFieldBorder,
                ), // Hardcoded string
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.black54),
                  ), // Hardcoded string
                ),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ), // Hardcoded string
              ),
              const SizedBox(height: 24),
              const Text(
                "Or continue with",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ), // Hardcoded string
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _isLoading ? null : _googleSignIn,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Text(
                  "Continue with Google",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ), // Hardcoded string
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {}, // Apple Sign-in not implemented
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Text(
                  "Continue with Apple",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ), // Hardcoded string
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.black54),
                  ), // Hardcoded string
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ), // Hardcoded string
                  ),
                ],
              ),
              const Spacer(),
              const Text(
                "The body achieves what the mind believes.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ), // Hardcoded string
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
