import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:biblia_flutter_app/data/annotations_dao.dart';
import 'package:biblia_flutter_app/data/verses_dao.dart';
import 'package:biblia_flutter_app/helpers/version_to_name.dart';
import 'package:biblia_flutter_app/models/annotation.dart';
import 'package:biblia_flutter_app/models/verse.dart';
import 'package:biblia_flutter_app/services/bible_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/alert_dialog.dart';
import '../helpers/convert_colors.dart';
import 'bible_data.dart';
import 'bible_data_controller.dart';
import 'books_dao.dart';
import 'package:path_provider/path_provider.dart';

class VersesProvider extends ChangeNotifier {
  static final BibleData _bibleData = BibleData();
  static final BooksDao _booksDao = BooksDao();
  static final VersesDao _versesDao = VersesDao();
  static final AnnotationsDao _annotationsDao = AnnotationsDao();
  static final BibleService _service = BibleService();
  List<VerseModel> _listaBd = [];
  List<Annotation> _listAnnotationsDb = [];
  List<Map<String, dynamic>> _listMap = [];
  List<int> _versesFound = [];
  bool _bottomSheetOpened = false;
  int _qtdVerses = 0;
  int _qtdAnnotations = 0;
  int _versesFoundCounter = 1;
  double _fontSize = 16;
  Map<String, dynamic> _verseInfo = {};
  Map<int, dynamic> _allVerses = {};
  String currentBook = '';

  List<Map<String, dynamic>> get bibleData => _bibleData.data;

  bool get bottomSheetOpened => _bottomSheetOpened;

  List<VerseModel> get listaBd => _listaBd;

  List<Annotation> get listaAnnotationsDb => _listAnnotationsDb;

  int get qtdVerses => _qtdVerses;

  int get qtdAnnotations => _qtdAnnotations;

  int get versesFoundCounter => _versesFoundCounter;

  double get fontSize => _fontSize;

  Map<String, dynamic> get verseInfo => _verseInfo;

  List<Map<String, dynamic>> get listMap => _listMap;

  List<bool> readChapters = [];

  List<int> get versesFoundList => _versesFound;

  Map<int, dynamic>? get allVerses => _allVerses;

  Future<void> loadUserData() async {
    _listaBd = [];
    _listAnnotationsDb = [];
    final BibleDataController bibleDataController = BibleDataController();
    await Future.wait([
      _versesDao.findAll().then((verses) => _listaBd = verses),
      bibleDataController.getAllAnnotations().then((annotations) => _listAnnotationsDb = annotations)
    ]);
    return;
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

  Map<int, dynamic> loadVerses(int bookIndex, String bookName, {String versionName = 'nvi', bool forMultiVersion = false}) {
    final Map<int, dynamic> allVerses = {};
    final versionNameFormatted = versionToName(versionName);
    int versionIndex = _bibleData.data.indexWhere((bible) => bible["version"] == versionNameFormatted);

    if (versionIndex == -1) {
      // Versão ainda não decodificada (carregamento sob demanda): mostra a
      // versão de referência e refaz a carga assim que a correta ficar pronta.
      versionIndex = 0;
      _bibleData.ensureVersionLoaded(versionNameFormatted).then((_) {
        if (_bibleData.isLoaded(versionNameFormatted)) {
          loadVerses(bookIndex, bookName,
              versionName: versionName, forMultiVersion: forMultiVersion);
        }
      });
    }

    final bibleData = _bibleData.data[versionIndex];
    final List<dynamic> chapters = bibleData["text"][bookIndex]['chapters'];

    if(!forMultiVersion) {
      _allVerses.clear(); // limpar dados anteriores
    }
    for (int chapter = 0; chapter < chapters.length; chapter++) {
      List<dynamic> versesByChapter = chapters[chapter];
      final List<dynamic> versesByChapterDefault = _bibleData.data[0]["text"][bookIndex]['chapters'][chapter];

      // Corrigir se o último versículo for uma anotação especial.
      // A cópia evita alterar a estrutura compartilhada de BibleData, que
      // antes crescia a cada chamada.
      final lastVerse = versesByChapter.last;
      if (lastVerse is String && (lastVerse.startsWith('[') || lastVerse.startsWith(' ['))) {
        final parts = lastVerse.split(']')[0].split('-');
        final initialVerse = int.parse(parts[0].replaceAll('[', ''));
        final finalVerse = int.parse(parts[1]);
        final difference = finalVerse - initialVerse;
        versesByChapter = List<dynamic>.from(versesByChapter);
        for (var i = 0; i < difference; i++) {
          versesByChapter.add('');
        }
      }

      final List<Map<String, dynamic>> versesMap = [];
      for (var i = 0; i < versesByChapterDefault.length; i++) {
        try{
          final verseText = versesByChapter[i];
          final defaultVerseText = versesByChapterDefault[i];

          // Cor e versão com base no banco de dados
          final foundDb = _listaBd.where((verse) => verse.verse == defaultVerseText);

          final verseColor = foundDb.isNotEmpty
              ? ConvertColors().convertColors(foundDb.first.verseColor)
              : Colors.transparent;

          final annotationFound = _listAnnotationsDb.where(
                (annotation) =>
            annotation.book == bookName && annotation.chapter == chapter + 1 && annotation.verseEnd == i + 1,
          );

          versesMap.add({
            "bookName": bookName,
            "chapter": chapter + 1,
            "verseNumber": i + 1,
            "verse": verseText,
            "verseDefault": defaultVerseText,
            "verseColor": verseColor,
            "version": versionNameFormatted,
            "isSelected": false,
            "isEditing": false,
            "annotation": annotationFound.firstOrNull
          });
        }catch(e) {
          debugPrint('Falha ao montar o capítulo $chapter de $bookName ($versionNameFormatted): $e');
        }
      }

      if(forMultiVersion) {
        allVerses[chapter + 1] = versesMap;
      }else {
        _allVerses[chapter + 1] = versesMap;
      }
    }

    if(forMultiVersion) {
      return allVerses;
    }
    notifyListeners();
    return _allVerses;
  }

  void clear() {
    _allVerses = {};
    notifyListeners();
  }

  void clearRandomVerse() {
    _verseInfo = {};
    notifyListeners();
  }

  Future<void> getImage() async {
    await _service.getRandomImage().then((value) => _verseInfo["url"] = value);
  }

  Future<File?> getOnlyImage() async {
    final Dio dio = Dio();
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final image = await _service.getOnlyImage();
    String fileName = image.split('/').last.split('.')[0];
    await dio.download(image.trim(), '${appDocDir.path}/$fileName');
    
    return await getDownloadedFile(fileName);
  }

  Future<File> getDownloadedFile(String fileName) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String filePath = '${appDocDir.path}/$fileName';
  
  File file = File(filePath);
  if (file.existsSync()) {
    return file;
  } else {
    throw Exception('File not found: $fileName');
  }
}

  Future<Map<String, dynamic>> getRandomVerse() async {
    await _service.getRandomVerse()
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
          return <dynamic>{};
      },
      test: (error) => error is TimeoutException,
    ).catchError(
      (error) {
        var innerError = error as HttpException;
        alertDialog(
          title: 'Erro ${innerError.message}',
          content: 'O servidor demorou pra responder. Tente novamente mais tarde.'
        );

        return <dynamic>{};
      },
      test: (error) => error is HttpException,
    );

    return _verseInfo;
  }

  Future<List<Map<String, dynamic>>> getAllBooks() async {
    final List<Map<String, dynamic>> allBooks = [];
    for (var i = 0; i < _bibleData.data[0]["text"].length; i++) {
      allBooks.add({
        'bookName': _bibleData.data[0]["text"][i]["name"],
        'abbrev': _bibleData.data[0]["text"][i]["abbrev"],
        'bookIndex': i,
        'chapters': _bibleData.data[0]["text"][i]["chapters"].length
      });
    }

    return allBooks;
  }

  Future<void> shareImageAndText(GlobalKey globalKey) async {
    try {
      final boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 4.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        bytesToXFile(pngBytes).then((image) => SharePlus.instance.share(ShareParams(files: image)));
      }
    } catch (e) {
      alertDialog(
        content: 'Não foi possível compartilhar o versículo! Se o erro persistir, envie um feedback de erro.\nErro: $e'
      );
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

  void shareVerses(List<Map<String, dynamic>> listMap, String bookName, int chapter) {
    int startIndex = listMap.first["verseNumber"];
    int? endIndex = listMap.length > 1 ? listMap.last["verseNumber"] : null;

    String book = endIndex != null
        ? '$bookName $chapter:$startIndex-$endIndex'
        : '$bookName $chapter:$startIndex';

    String verses = listMap.map((v) => '${v["verseNumber"]} ${v["verse"]}').join(' ');

    SharePlus.instance.share(ShareParams(text: '$book "$verses"'));
  }

  void share(
    String bookName,
    String verse,
    int chapter,
    int verseNumber
  ) => SharePlus.instance.share(
        ShareParams(text: '$bookName $chapter:$verseNumber "$verse"'),
      );

  Future<void> copyText(String bookName, String verse, int chapter, int verseNumber) => Clipboard.setData(
    ClipboardData(text: '$bookName $chapter:$verseNumber "$verse')
  );

  void copyVerses(List<Map<String, dynamic>> listMap, String bookname, int chapter) {
    int startIndex = listMap.first["verseNumber"];
    int? endIndex = listMap.length > 1 ? listMap.last["verseNumber"] : null;

    String book = endIndex == null
        ? '$bookname $chapter:$startIndex'
        : '$bookname $chapter:$startIndex-$endIndex';

    String verses = listMap.map((v) => '${v["verseNumber"]} ${v["verse"]}').join(' ');

    Clipboard.setData(ClipboardData(text: '$book "$verses"'));
  }

  Future<void> deleteVerse(String verse) async {
    await _versesDao.delete(verse);
    notifyListeners();
  }

  Future<void> deleteVerses(List<Map<String, dynamic>> listMap) async {
    for (var element in listMap) {
      if (element["isSelected"] == true && element["isEditing"] == true) {
        element["verseColor"] = Colors.transparent;
        element["isSelected"] = false;
        element["isEditing"] = false;
        await _versesDao.delete(element["verseDefault"]);
      }
    }
    await loadUserData();
    notifyListeners();
  }

  Future<void> deleteAllVerses() async {
    await _versesDao.deleteAllVerses();
    notifyListeners();
  }

  Future<void> deleteAllAnnotations() async {
    await _annotationsDao.deleteAllAnnotations();
    notifyListeners();
  }

  void clearSelectedVerses(List<Map<String, dynamic>> listMap) {
    for (var element in listMap) {
      element["isSelected"] = false;
      element["isEditing"] = false;
    }
    notifyListeners();
  }

  Future<void> getAnnotations() async {
    _listAnnotationsDb = await _annotationsDao.findAll();
    _qtdAnnotations = _listAnnotationsDb.length;
  }

  Future<int> saveAnnotation({required Annotation annotation}) async => await _annotationsDao.save(annotation);

  Future<int> updateAnnotation({
    required String annotationId,
    required String content,
    required String style
  }) async => await _annotationsDao.updateAnnotation(annotationId, content, style);

  Future<void> deleteAnnotation(String annotationId) async {
    await _annotationsDao.delete(annotationId);
    notifyListeners();
  }

  Future<void> getReadChapters({required String bookName, required int qtdChapters}) async {
    readChapters = [];
    List<dynamic> chaptersList = [];
    final booksRead = await _booksDao.findByChapter(bookName, qtdChapters);
    if(booksRead['chapters'] is String) {
      final String chaptersString = booksRead['chapters'];
      // Corrige a string, colocando aspas nos números das chaves
      String correctedChapters = chaptersString.replaceAllMapped(
          RegExp(r'(\d+):'), (match) => '"${match[1]}":'
      );

      // Converte a string JSON corrigida para uma lista
      chaptersList = jsonDecode(correctedChapters);
    }else {
      chaptersList = booksRead['chapters'];
    }

    readChapters = chaptersList.map((chapter) => chapter.values.first as bool).toList();
    notifyListeners();
    return;
  }

  void refresh() async {
    _listaBd = await _versesDao.findAll();
    _qtdVerses = _listaBd.length;
    getAnnotations();
    _listMap = await _booksDao.findAll();
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
      element["verseColor"] = newColor;
      element["isSelected"] = false;
      if(element["isEditing"] == true) {
        _versesDao.updateColor(element["verseDefault"], bdColor);
      }else {
        _versesDao.save(VerseModel(verse: element["verseDefault"], verseColor: bdColor, book: element["bookName"], version: element["version"], chapter: element["chapter"], verseNumber: element["verseNumber"]));
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
