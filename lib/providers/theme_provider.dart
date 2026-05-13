import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  Future<void> initTheme() async {
    try {
      final data = await AuthService.getProfile();

      _isDarkMode = data['dark_mode'] ?? false;

      notifyListeners();
    } catch (e) {
      print("Failed to load theme: $e");
    }
  }

  ThemeMode get themeMode =>
      _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}