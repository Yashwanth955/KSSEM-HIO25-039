// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appTitle => 'ಸಾಧಕ್';

  @override
  String homeScreenGreeting(String userName) {
    return 'ನಮಸ್ಕಾರ $userName 👋, ಇಂದು ನಿಮ್ಮ ಫಿಟ್ನೆಸ್ ಪರೀಕ್ಷಿಸಲು ಸಿದ್ಧರಿದ್ದೀರಾ?';
  }

  @override
  String get language => 'ಭಾಷೆ';

  @override
  String get english => 'ಆಂಗ್ಲ';

  @override
  String get hindi => 'ಹಿಂದಿ';

  @override
  String get kannada => 'ಕನ್ನಡ';

  @override
  String get startFitnessTest => 'ಫಿಟ್ನೆಸ್ ಪರೀಕ್ಷೆಯನ್ನು ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get bestScore => 'ಅತ್ಯುತ್ತಮ ಸ್ಕೋರ್';

  @override
  String get leaderboard => 'ನಾಯಕ ಮಂಡಳಿ';

  @override
  String get badges => 'ಬ್ಯಾಡ್ಜ್‌ಗಳು';

  @override
  String get loginFailedError =>
      'ಲಾಗಿನ್ ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ನಿಮ್ಮ ರುಜುವಾತುಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get loginScreenAppName => 'ಸಾಧಕ್';

  @override
  String get loginWelcomeBack => 'ಮರಳಿ ಸ್ವಾಗತ!';

  @override
  String get loginEmailHint => 'ಇಮೇಲ್';

  @override
  String get loginPasswordHint => 'ಪಾಸ್ವರ್ಡ್';

  @override
  String get loginForgotPassword => 'ಪಾಸ್ವರ್ಡ್ ಮರೆತಿರಾ?';

  @override
  String get loginButton => 'ಲಾಗಿನ್';

  @override
  String get loginOrContinueWith => 'ಅಥವಾ ಇದರೊಂದಿಗೆ ಮುಂದುವರಿಸಿ';

  @override
  String get loginContinueWithGoogle => 'Google ನೊಂದಿಗೆ ಮುಂದುವರಿಸಿ';

  @override
  String get loginContinueWithApple => 'Apple ನೊಂದಿಗೆ ಮುಂದುವರಿಸಿ';

  @override
  String get loginDontHaveAccount => 'ಖಾತೆ ಇಲ್ಲವೇ?';

  @override
  String get loginSignUpButton => 'ಸೈನ್ ಅಪ್ ಮಾಡಿ';

  @override
  String get loginMotivationalQuote => 'ದೇಹವು ಮನಸ್ಸು ನಂಬುವುದನ್ನು ಸಾಧಿಸುತ್ತದೆ.';
}
