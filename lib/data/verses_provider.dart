import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:biblia_flutter_app/data/annotations_dao.dart';
import 'package:biblia_flutter_app/data/verses_dao.dart';
import 'package:biblia_flutter_app/models/annotation.dart';
import 'package:biblia_flutter_app/models/verse.dart';
import 'package:biblia_flutter_app/screens/home_screen/widgets/random_verse_widget.dart';
import 'package:biblia_flutter_app/services/bible_service.dart';
import 'package:biblia_flutter_app/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/alert_dialog.dart';
import '../helpers/convert_colors.dart';
import 'bible_data.dart';
import 'bible_data_controller.dart';
import 'books_dao.dart';
import 'package:path_provider/path_provider.dart';

class VersesProvider extends ChangeNotifier {
  final BibleData _bibleData = BibleData();
  BibleService service = BibleService();
  List<VerseModel> _lista = [];
  List<VerseModel> _listaBd = [];
  List<Annotation> _listAnnotations = [];
  List<Annotation> _listAnnotationsDb = [];
  List<Map<String, dynamic>> _listMapVerses = [];
  List<Map<String, dynamic>> _listMap = [];
  List<int> _versesFound = [];
  bool _bottomSheetOpened = false;
  int _qtdVerses = 0;
  int _qtdAnnotations = 0;
  int _versesFoundCounter = 1;
  double _fontSize = 16;
  Map<String, dynamic> _verseInfo = {};
  Map<int, dynamic> _allVerses = {};

  String _color = 'todas';

  bool get bottomSheetOpened => _bottomSheetOpened;

  UnmodifiableListView<VerseModel> get lista => UnmodifiableListView(_lista);

  List<VerseModel> get listaBd => _listaBd;

  UnmodifiableListView<Annotation> get listaAnnotations => UnmodifiableListView(_listAnnotations);

  List<Annotation> get listaAnnotationsDb => _listAnnotationsDb;

  int get qtdVerses => _qtdVerses;

  int get qtdAnnotations => _qtdAnnotations;

  int get versesFoundCounter => _versesFoundCounter;

  double get fontSize => _fontSize;

  String get color => _color;

  Map<String, dynamic> get verseInfo => _verseInfo;

  List<Map<String, dynamic>> get listMap => _listMap;

  List<Map<String, dynamic>> get listMapVerses => _listMapVerses;

  List<int> get versesFoundList => _versesFound;

  Map<int, dynamic>? get allVerses => _allVerses;

  void loadUserData() async {
    _listaBd = [];
    _listAnnotationsDb = [];
    final versesDao = VersesDao();
    final BibleDataController bibleDataController = BibleDataController();
    await Future.wait([
      versesDao.findAll().then((verses) => _listaBd = verses),
      bibleDataController.getAllAnnotations().then((annotations) => _listAnnotationsDb = annotations)
    ]);
  }

  void newFontSize(double newSize, bool save) async {
    if(save) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('fontsize', newSize);
      _fontSize = newSize;
      notifyListeners();
      return;
    }

    notifyListeners();
  }

  void getFontSize() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.getDouble('fontsize') == null ? _fontSize = 16.0 : _fontSize = prefs.getDouble('fontsize')!;
  }

  void openBottomSheet(bool value) {
    _bottomSheetOpened = value;

    notifyListeners();
  }

  Map<int, dynamic> loadVerses(int bookIndex, String bookName, {int versionIndex = 0}) {
    if (_listMapVerses.isEmpty) {
      List<dynamic> chapters = _bibleData.data[versionIndex][bookIndex]['chapters'];
      for (int i = 0; i < chapters.length; i++) {
        refreshFunction(bookName, bookIndex, i, versionIndex: versionIndex);
      }
      notifyListeners();
      return _allVerses;
    }

    return _allVerses;
  }

  void refreshFunction(String bookName, int bookIndex, int chapter, {int versionIndex = 0}) {
    final listColorsDb = [];
    _listMapVerses = [];
    final List<dynamic> versesByChapter = _bibleData.data[versionIndex][bookIndex]['chapters'][chapter];
    final List<dynamic> versesByChapterDefault = _bibleData.data[0][bookIndex]['chapters'][chapter];

    for (var i = 0; i < versesByChapterDefault.length; i++) {
      if(_listaBd.isNotEmpty && _listaBd.where((verse) => verse.verse == versesByChapterDefault[i]).isNotEmpty) {
        final verseFound = _listaBd.where((verse) => verse.verse == versesByChapterDefault[i]).first;
        listColorsDb.add({
          "verse": versesByChapterDefault[i],
          "version": verseFound.version,
          "color": ConvertColors().convertColors(verseFound.verseColor)
        });
      }else {
        listColorsDb.add({
          "verse": versesByChapterDefault[i],
          "version": 0,
          "color": Colors.transparent
        });
      }
      final annotationFound = _listAnnotationsDb.where((annotation) => annotation.book == bookName && annotation.chapter == chapter + 1 && annotation.verseEnd == i + 1);
      _listMapVerses.add({
        "bookName": bookName,
        "chapter": chapter + 1,
        "verseNumber": i + 1,
        "verse": versesByChapter[i],
        "verseDefault": versesByChapterDefault[i],
        "verseColor": listColorsDb[i]["color"],
        "version": versionIndex,
        "isSelected": false,
        "isEditing": false,
        "annotation": annotationFound.isEmpty ? null : annotationFound.first
      });
    }
    _allVerses[chapter + 1] = _listMapVerses;
  }

  void clear() {
    _listMapVerses = [];
    _allVerses = {};
    notifyListeners();
  }

  void clearRandomVerse() {
    _verseInfo = {};
    notifyListeners();
  }

  Future<void> getImage() async {
    await service.getRandomImage().then((value) => _verseInfo["url"] = value);
  }

  Future<File?> getOnlyImage() async {
    final image = await service.getOnlyImage();
    return await FileDownloader.downloadFile(
      url: image.trim(),
      name: 'randomImage',
      downloadDestination: DownloadDestinations.appFiles,
      onDownloadError: (String error) {
        return null;
      },
      onDownloadCompleted: (String path) {
        print('FILE DOWNLOADED TO PATH: $path');
      },
    );
  }

  Future<Map<String, dynamic>> getRandomVerse() async {
    await service.getRandomVerse()
        .then((value) => {
              _verseInfo["bookName"] = value["book"]["name"],
              _verseInfo["abbrev"] = value["book"]["abbrev"]["pt"],
              _verseInfo["chapter"] = value["chapter"],
              _verseInfo["verseNumber"] = value["number"],
              _verseInfo["verse"] = value["text"]
            })
        .catchError((error) {
          var innerError = error as TimeoutException;
          alertDialog(
            title: 'Erro ${innerError.message}',
            content: 'O servidor demorou pra responder. Tente novamente mais tarde.'
          );
      },
      test: (error) => error is TimeoutException,
    ).catchError(
      (error) {
        var innerError = error as HttpException;
        alertDialog(
            title: 'Erro ${innerError.message}',
            content:
                'O servidor demorou pra responder. Tente novamente mais tarde.');
      },
      test: (error) => error is HttpException,
    );

    return _verseInfo;
  }

  Future<List<Map<String, dynamic>>> getAllBooks() async {
    final List<Map<String, dynamic>> allBooks = [];
    for (var i = 0; i < _bibleData.data[0].length; i++) {
      allBooks.add({
        'bookName': _bibleData.data[0][i]["name"],
        'abbrev': _bibleData.data[0][i]["abbrev"],
        'bookIndex': i,
        'chapters': _bibleData.data[0][i]["chapters"].length
      });
    }

    return allBooks;
  }

  Future<void> shareImageAndText() async {
    try {
      final boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        bytesToXFile(pngBytes).then((image) => Share.shareXFiles(image));
      }
    } catch (e) {
      alertDialog(
          content:
              'Não foi possível compartilhar o versículo! Se o erro persistir, envie um feedback de erro.\nErro: $e');
    }
  }

  Future<List<XFile>> bytesToXFile(Uint8List pngBytes) async {
    final files = <XFile>[];
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File tempFile = File('$tempPath/image.png');
    await tempFile.writeAsBytes(pngBytes);
    files.add(XFile(tempFile.path));

    return files;
  }

  void shareVerses(BuildContext context, List<Map<String, dynamic>> listMap, String bookName) {
    String verse = '';
    String book = '';
    for (var element in listMap) {
      book = '${element["bookName"]} ${element["chapter"]}';
      if(element["isSelected"]) {
        verse = '$verse ${element["verseNumber"]} ${element["verse"]}';
      }
    }
    Share.share('$book:$verse');
  }

  void share(String bookName, String verse, int chapter, int verseNumber) {
    Share.share('$bookName $chapter:$verseNumber $verse');
  }

  void copyText(String bookName, String verse, int chapter, int verseNumber) async {
    await Clipboard.setData(
        ClipboardData(text: '$bookName $chapter:$verseNumber $verse'));
  }

  void copyVerses(List<Map<String, dynamic>> listMap) async {
    String verse = '';
    String book = '';
    for (var element in listMap) {
      book = '${element["bookName"]} ${element["chapter"]}';
      if(element["isSelected"]) {
        verse = '$verse ${element["verseNumber"]} ${element["verse"]}';
      }
    }
    await Clipboard.setData(ClipboardData(text: '$book:$verse'));
  }

  Future<void> deleteVerse(String verse) async {
    await VersesDao().delete(verse);
    notifyListeners();
  }

  Future<void> deleteVerses(List<Map<String, dynamic>> listMap) async {
    for (var element in listMap) {
      if (element["isSelected"] == true && element["isEditing"] == true) {
        element["verseColor"] = Colors.transparent;
        element["isSelected"] = false;
        element["isEditing"] = false;
        VersesDao().delete(element["verseDefault"]);
      }
    }
    notifyListeners();
  }

  Future<void> deleteAllVerses() async {
    await VersesDao().deleteAllVerses();
    notifyListeners();
  }

  Future<void> deleteAllAnnotations() async {
    await AnnotationsDao().deleteAllAnnotations();
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
      element["isEditing"] = false;
    }
    notifyListeners();
  }

  Future<void> getAnnotations() async {
    _listAnnotations = await AnnotationsDao().findAll();
    _qtdAnnotations = _listAnnotations.length;
  }

  Future<void> deleteAnnotation(String annotationId) async {
    await AnnotationsDao().delete(annotationId);
    notifyListeners();
  }

  void refresh() async {
    _lista = await VersesDao().findAll();
    _qtdVerses = _lista.length;
    _listAnnotations = await AnnotationsDao().findAll();
    _qtdAnnotations = _listAnnotations.length;
    await BooksDao().findAll().then((value) {
      _listMap = value;
    });
    notifyListeners();
  }

  List<int> versesFound(List<int> listValues) {
    _versesFound = listValues;
    notifyListeners();

    return _versesFound;
  }

  void increaseVersesFoundCounter() {
    _versesFoundCounter++;

    notifyListeners();
  }

  void decreaseVersesFoundCounter() {
    _versesFoundCounter--;

    notifyListeners();
  }

  void resetVersesFoundCounter() {
    _versesFoundCounter = 1;

    notifyListeners();
  }

  void updateColors(List<Map<String, dynamic>> listMap, Color newColor, String bdColor) {
    for (var element in listMap) {
      if(element["isSelected"] == true) {
        element["verseColor"] = newColor;
        element["isSelected"] = false;
        if(element["isEditing"] == true) {
          VersesDao().updateColor(element["verseDefault"], bdColor);
        }else {
          VersesDao().save(VerseModel(verse: element["verseDefault"], verseColor: bdColor, book: element["bookName"], version: element["version"], chapter: element["chapter"], verseNumber: element["verseNumber"]));
        }
      }
    }
  }

  void highlightSpeechBloc(int chapter, int count) {
    if(count > 0) {
      _allVerses[chapter][count - 1]["isSelected"] = false;
    }
    _allVerses[chapter][count]["isSelected"] = true;
    notifyListeners();
  }
}
