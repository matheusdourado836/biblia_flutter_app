import 'package:biblia_flutter_app/data/verses_dao.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/verse_model.dart';

class VerseInherited extends InheritedWidget {
  const VerseInherited({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  final bool isSelected = false;

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

  void share(BuildContext context, List<Map<String, dynamic>> listMap, String bookName) {
    String verse = '';
    String book = '';
    for (var element in listMap) {
      book = '${element["bookName"]} ${element["chapter"]}';
      if(element["isSelected"]) {
        verse = '$verse ${element["index"] + 1} ${element["verse"]}';
      }
    }
    Share.share('$book:$verse');
  }

  void copyText(BuildContext context, List<Map<String, dynamic>> listMap) async {
    String verse = '';
    String book = '';
    for (var element in listMap) {
      book = '${element["bookName"]} ${element["chapter"]}';
      if(element["isSelected"]) {
        verse = '$verse ${element["index"] + 1} ${element["verse"]}';
      }
    }
    await Clipboard.setData(
        ClipboardData(text: '$book:$verse'))
        .then(
          (value) => {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(milliseconds: 1000),
            content: Text('Texto copiado para área de transferência'),
          ),
        ),
      },
    );
  }

  static VerseInherited of(BuildContext context) {
    final VerseInherited? result = context.dependOnInheritedWidgetOfExactType<VerseInherited>();
    assert(result != null, 'No VerseInherited found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(VerseInherited oldWidget) {
    return oldWidget.isSelected != isSelected;
  }
}
