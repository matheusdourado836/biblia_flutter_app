import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode? themeMode;
  bool _isOn = true;

  bool get isOn => _isOn;

  void getThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.getBool('themeMode') == null ? _isOn = true : _isOn = prefs.getBool('themeMode')!;
    if(prefs.getBool('themeMode') == null) {
      themeMode = ThemeMode.light;
      return;
    }
    themeMode = prefs.getBool('themeMode')! ? ThemeMode.light : ThemeMode.dark;

    notifyListeners();
  }

  void toggleTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isOn = !_isOn;
    await prefs.setBool('themeMode', isOn);
    getThemeMode();

    notifyListeners();
  }
}