import 'package:flutter/material.dart';
import 'package:sadhak/user_model.dart'; // Assuming user_model.dart path

class AppState extends ChangeNotifier {
  UserProfile? _userProfile;
  Locale? _locale;

  UserProfile? get userProfile => _userProfile;
  Locale? get locale => _locale;

  void setUserProfile(UserProfile? profile) {
    _userProfile = profile;
    notifyListeners();
  }

  void setLocale(Locale? locale) {
    _locale = locale;
    notifyListeners();
  }
}
