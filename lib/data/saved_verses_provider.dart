import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:biblia_flutter_app/data/verses_dao.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:biblia_flutter_app/models/verse_model.dart';
import 'package:biblia_flutter_app/services/bible_service.dart';
import 'package:biblia_flutter_app/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../helpers/alert_dialog.dart';
import 'books_dao.dart';

class SavedVersesProvider extends ChangeNotifier {
  BibleService service = BibleService();
  List<VerseModel> _lista = [];
  int _qtdVerses = 0;
  bool _versesSelected = false;
  List<Map<String, dynamic>> _listMap = [];
  final Map<String, dynamic> _verseInfo = {};
  String _color = 'todas';

  UnmodifiableListView<VerseModel> get lista => UnmodifiableListView(_lista);

  int get qtdVerses => _qtdVerses;

  String get color => _color;

  bool get versesSelected => _versesSelected;

  Map<String, dynamic> get verseInfo => _verseInfo;

  List<Map<String, dynamic>> get listMap => _listMap;

  Future<void> getImage() async {
    await service.getRandomImage().then((value) => verseInfo["url"] = value);
  }

  Future<Map<String, dynamic>> getRandomVerse() async {
    getImage();
    service.getRandomVerse().then((value) async => {
      await service.getBookDetail(value["book"]["abbrev"]["pt"]).then((value) => {_verseInfo["chapters"] = value["chapters"]}),
      _verseInfo["bookName"] = value["book"]["name"],
      _verseInfo["abbrev"] = value["book"]["abbrev"]["pt"],
      _verseInfo["chapter"] = value["chapter"],
      _verseInfo["verseNumber"] = value["number"],
      _verseInfo["verse"] = value["text"]
    }).catchError((error) {
          var innerError = error as TimeoutException;
          alertDialog(title: 'Erro ${innerError.message}',
              content:
              'O servidor demorou pra responder. Tente novamente mais tarde.');
        }, test: (error) => error is TimeoutException,
    ).catchError((error) {
          var innerError = error as HttpException;
          alertDialog(title: 'Erro ${innerError.message}',
              content:
              'O servidor demorou pra responder. Tente novamente mais tarde.');
        }, test: (error) => error is HttpException,
    );

    return _verseInfo;
  }

  void share(String bookName, String verse, int chapter, int verseNumber) {
    Share.share('$bookName $chapter:$verseNumber $verse');
  }

  void copyText(String bookName, String verse, int chapter, int verseNumber) async {
    await Clipboard.setData(ClipboardData(text: '$bookName $chapter:$verseNumber $verse'));
  }

  Future<void> deleteVerse(String verse) async {
    await VersesDao().delete(verse);
    notifyListeners();
  }

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

  void refresh() async {
    _lista = await VersesDao().findAll();
    await BooksDao().findAll().then((value) {
      _listMap = value;
    });
    _qtdVerses = _lista.length;
    notifyListeners();
  }
}
