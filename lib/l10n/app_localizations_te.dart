// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => '[సాధక్ - Sadhak in Telugu]';

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
      '[Login failed. Please check your credentials. - Telugu]';

  @override
  String get loginScreenAppName => '[Sadhaka - Telugu]';

  @override
  String get loginWelcomeBack => '[Welcome Back - Telugu]';

  @override
  String get loginEmailHint => '[Email or Username - Telugu]';

  @override
  String get loginPasswordHint => '[Password - Telugu]';

  @override
  String get loginForgotPassword => '[Forgot Password? - Telugu]';

  @override
  String get loginButton => '[Login - Telugu]';

  @override
  String get loginOrContinueWith => '[Or continue with - Telugu]';

  @override
  String get loginContinueWithGoogle => '[Continue with Google - Telugu]';

  @override
  String get loginContinueWithApple => '[Continue with Apple - Telugu]';

  @override
  String get loginDontHaveAccount => '[Don\'t have an account? - Telugu]';

  @override
  String get loginSignUpButton => '[Sign Up - Telugu]';

  @override
  String get loginMotivationalQuote =>
      '[\"The only bad workout is the one that didn\'t happen.\" - Telugu]';
}
