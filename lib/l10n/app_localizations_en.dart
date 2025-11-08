// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sadhak';

  @override
  String homeScreenGreeting(String userName) {
    return 'Hi $userName 👋, ready to test your fitness today?';
  }

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi';

  @override
  String get kannada => 'Kannada';

  @override
  String get startFitnessTest => 'Start Fitness Test';

  @override
  String get bestScore => 'Best Score';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get badges => 'Badges';

  @override
  String get loginFailedError => 'Login failed. Please check your credentials.';

  @override
  String get loginScreenAppName => 'SADHAK';

  @override
  String get loginWelcomeBack => 'Welcome Back!';

  @override
  String get loginEmailHint => 'Email';

  @override
  String get loginPasswordHint => 'Password';

  @override
  String get loginForgotPassword => 'Forgot Password?';

  @override
  String get loginButton => 'Login';

  @override
  String get loginOrContinueWith => 'Or continue with';

  @override
  String get loginContinueWithGoogle => 'Continue with Google';

  @override
  String get loginContinueWithApple => 'Continue with Apple';

  @override
  String get loginDontHaveAccount => 'Don\'t have an account?';

  @override
  String get loginSignUpButton => 'Sign Up';

  @override
  String get loginMotivationalQuote =>
      'The body achieves what the mind believes.';
}
