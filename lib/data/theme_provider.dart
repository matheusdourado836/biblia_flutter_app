import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode? themeMode;
  bool _isOn = true;

  bool get isOn => _isOn;

  Future<void> getThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool lightTheme = prefs.getBool('themeMode') ?? true;
    _isOn = lightTheme;

    themeMode = lightTheme ? ThemeMode.light : ThemeMode.dark;

    notifyListeners();
    return;
  }

  void toggleTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isOn = !_isOn;
    await prefs.setBool('themeMode', isOn);
    themeMode = _isOn ? ThemeMode.light : ThemeMode.dark;

    notifyListeners();
  }
}