import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  bool _isOn = true;

  bool get isOn => _isOn;

  void toggleTheme() {
    _isOn = !_isOn;
    themeMode = _isOn ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}