import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'books_dao.dart';

class ChaptersProvider extends ChangeNotifier {
  List<bool> _readChapters = [];
  int _orderStyle = 0;

  int get orderStyle => _orderStyle;

  List<bool> get readChapters => _readChapters;

  void setChaptersRead(String bookName, int chapters) async {
    for(var i = 0; i < chapters; i++) {
      _readChapters.add(false);
    }
    await BooksDao().findByChapter(bookName).then((value) => {
      _readChapters = [],
      for(var i = 0; i < value['chapters'].length; i++) {
        if(value['chapters'][i][(i + 1).toString()] == true) {
          _readChapters.add(true)
        }else {
          _readChapters.add(false)
        }
      },
    });

    notifyListeners();
  }

  void saveChapter(String bookName, String chapter) {
    final index = int.parse(chapter) - 1;
    readChapters[index] = true;
    BooksDao().saveChapter(bookName, chapter);
    notifyListeners();
  }

  void deleteChapter(String bookName, String chapter) {
    final index = int.parse(chapter) - 1;
    readChapters[index] = false;
    BooksDao().deleteChapter(bookName, chapter);
    notifyListeners();
  }

  void addAllChapters(String bookName, int chapters) async {
    await BooksDao().save(bookName, chapters, 1);
    await BooksDao().findByChapter(bookName).then((value) => {
      _readChapters = [],
      for(var i = 0; i < value['chapters'].length; i++) {
        _readChapters.add(true)
      },
    });

    notifyListeners();
  }

  void removeAllChapters(String bookName, int chapters) async {
    await BooksDao().delete(bookName);
    await BooksDao().findByChapter(bookName).then((value) => {
      _readChapters = [],
      for(var i = 0; i < value['chapters'].length; i++) {
        _readChapters.add(false)
      },
    });

    notifyListeners();
  }

  void setOrderStyle(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if(value.startsWith('por')) {
      await prefs.setInt('orderStyle', 2);
      _orderStyle = 2;
    }else if(value == 'Padrão') {
      await prefs.setInt('orderStyle', 0);
      _orderStyle = 0;
    }else {
      await prefs.setInt('orderStyle', 1);
      _orderStyle = 1;
    }

    notifyListeners();
  }

  void getOrderStyle() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _orderStyle = prefs.getInt('orderStyle') ?? 0;

  }
}