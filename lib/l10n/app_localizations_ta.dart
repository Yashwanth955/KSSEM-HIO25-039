// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => '[சாதக் - Sadhak in Tamil]';

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
  String get loginFailedError =>
      '[Login failed. Please check your credentials. - Tamil]';

  @override
  String get loginScreenAppName => '[Sadhaka - Tamil]';

  @override
  String get loginWelcomeBack => '[Welcome Back - Tamil]';

  @override
  String get loginEmailHint => '[Email or Username - Tamil]';

  @override
  String get loginPasswordHint => '[Password - Tamil]';

  @override
  String get loginForgotPassword => '[Forgot Password? - Tamil]';

  @override
  String get loginButton => '[Login - Tamil]';

  @override
  String get loginOrContinueWith => '[Or continue with - Tamil]';

  @override
  String get loginContinueWithGoogle => '[Continue with Google - Tamil]';

  @override
  String get loginContinueWithApple => '[Continue with Apple - Tamil]';

  @override
  String get loginDontHaveAccount => '[Don\'t have an account? - Tamil]';

  @override
  String get loginSignUpButton => '[Sign Up - Tamil]';

  @override
  String get loginMotivationalQuote =>
      '[\"The only bad workout is the one that didn\'t happen.\" - Tamil]';
}
