import 'dart:collection';
import 'package:biblia_flutter_app/data/verses_dao.dart';
import 'package:biblia_flutter_app/models/verse_model.dart';
import 'package:biblia_flutter_app/themes/theme_colors.dart';
import 'package:flutter/material.dart';

import 'books_dao.dart';

class SavedVersesProvider extends ChangeNotifier {
  List<VerseModel> _lista = [];
  int _qtdVerses = 0;
  String _version = 'nvi';
  bool _versesSelected = false;
  List<Map<String, dynamic>> _listMap = [];
  String _color = 'todas';

  UnmodifiableListView<VerseModel> get lista => UnmodifiableListView(_lista);

  int get qtdVerses => _qtdVerses;

  String get version => _version;

  String get color => _color;

  bool get versesSelected => _versesSelected;

  List<Map<String, dynamic>> get listMap => _listMap;

  void orderListByColor(String option) {
    switch (option) {
      case 'todas':
        _color = 'todas';
        break;
      case 'azul':
        _color = ThemeColors.colorString2;
        break;
      case 'amarelo':
        _color = ThemeColors.colorString3;
        break;
      case 'marrom':
        _color = ThemeColors.colorString4;
        break;
      case 'vermelho':
        _color = ThemeColors.colorString5;
        break;
      case 'laranja':
        _color = ThemeColors.colorString6;
        break;
      case 'verde':
        _color = ThemeColors.colorString7;
        break;
      case 'rosa':
        _color = ThemeColors.colorString8;
        break;
      case 'ciano':
        _color = ThemeColors.colorString1;
        break;
    }
    notifyListeners();
  }

  bool verseSelectedExists(List<Map<String, dynamic>> listMap) {
    for (var element in listMap) {
      if (element.containsValue(true)) {
        _versesSelected = true;
        notifyListeners();
        return true;
      }
    }
    notifyListeners();
    _versesSelected = false;
    return false;
  }

  bool bookIsReadCheckBox(bool isChecked) {
    if (isChecked == true) {
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  void clearSelectedVerses(List<Map<String, dynamic>> listMap) {
    for (var element in listMap) {
      element["isSelected"] = false;
    }
    notifyListeners();
  }

  void changeVersion(String newVersion) {
    _version = newVersion;
    notifyListeners();
  }

  void refresh() async {
    _lista = await VersesDao().findAll();
    await BooksDao().findAll().then((value) {
      _listMap = value;
    });
    _qtdVerses = _lista.length;
    notifyListeners();
  }
}
