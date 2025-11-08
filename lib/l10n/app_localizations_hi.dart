// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'साधक';

  @override
  String homeScreenGreeting(String userName) {
    return 'नमस्ते $userName 👋, आज अपनी फिटनेस का परीक्षण करने के लिए तैयार हैं?';
  }

  @override
  String get language => 'भाषा';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get hindi => 'हिंदी';

  @override
  String get kannada => 'कन्नड़';

  @override
  String get startFitnessTest => 'फिटनेस टेस्ट शुरू करें';

  @override
  String get bestScore => 'सर्वश्रेष्ठ स्कोर';

  @override
  String get leaderboard => 'लीडरबोर्ड';

  @override
  String get badges => 'बैज';

  @override
  String get loginFailedError => 'लॉगिन विफल। कृपया अपनी क्रेडेंशियल जांचें।';

  @override
  String get loginScreenAppName => 'साधक';

  @override
  String get loginWelcomeBack => 'वापसी पर स्वागत है!';

  @override
  String get loginEmailHint => 'ईमेल';

  @override
  String get loginPasswordHint => 'पासवर्ड';

  @override
  String get loginForgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get loginButton => 'लॉगिन';

  @override
  String get loginOrContinueWith => 'या इसके साथ जारी रखें';

  @override
  String get loginContinueWithGoogle => 'Google के साथ जारी रखें';

  @override
  String get loginContinueWithApple => 'Apple के साथ जारी रखें';

  @override
  String get loginDontHaveAccount => 'खाता नहीं है?';

  @override
  String get loginSignUpButton => 'साइन अप करें';

  @override
  String get loginMotivationalQuote => 'शरीर वह हासिल करता है जो मन मानता है।';
}
