import 'package:flutter/material.dart';

class VersionProvider extends ChangeNotifier {
  String _version = 'nvi';

  String get version => _version;

  void changeVersion(String newVersion) {
    _version = newVersion;
    notifyListeners();
  }
}