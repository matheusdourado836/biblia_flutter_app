import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/loading_verses_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final TextEditingController textEditingController = TextEditingController();
List<Map<String, dynamic>> listVerses = [];

class SearchingVerse extends StatefulWidget {
  final Function() function;
  final int chapter;
  const SearchingVerse({Key? key, required this.function, required this.chapter}) : super(key: key);

  @override
  State<SearchingVerse> createState() => _SearchingVerseState();
}

class _SearchingVerseState extends State<SearchingVerse> {
  late VersesProvider _versesProvider;

  @override
  void initState() {
    _versesProvider = Provider.of<VersesProvider>(context, listen: false);
    super.initState();
  }

  void _textEditingControllerListener(String text) {
    List<int> contador = [];
    if(text.isEmpty) {
      _versesProvider.versesFound([]);
      _versesProvider.resetVersesFoundCounter();
      setState(() {
        listVerses = [];
      });
    }else {
      setState(() {
        listVerses = (_versesProvider.allVerses[widget.chapter])
            .toList()
            .where((element) =>
                element["verse"].toString().toLowerCase().contains(text.toLowerCase().trim()))
            .toList();
      });
    }

    for(var verse in listVerses) {
      contador.add(verse["verseNumber"] - 1);
      _versesProvider.versesFound(contador);
      itemScrollController.jumpTo(index: _versesProvider.versesFoundList[0]);
      _versesProvider.resetVersesFoundCounter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .7,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: textEditingController,
              style: const TextStyle(color: Colors.black),
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Pesquisar na página',
              ),
              onChanged: (value) {
                _textEditingControllerListener(value);
              },
            ),
          ),
         Consumer<VersesProvider>(
           builder: (context, value, _) {
             return  SizedBox(
               width: 50,
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Expanded(
                     child: IconButton(padding: const EdgeInsets.only(bottom: 0), onPressed: (() {
                       if(_versesProvider.versesFoundCounter < _versesProvider.versesFoundList.length) {
                         _versesProvider.increaseVersesFoundCounter();
                         itemScrollController.jumpTo(index: _versesProvider.versesFoundList[_versesProvider.versesFoundCounter - 1]);
                       }
                     }), icon: const Icon(Icons.arrow_drop_up), iconSize: 28,),
                   ),
                   Text(
                     '${_versesProvider.versesFoundCounter} de ${listVerses.length}',
                     style: const TextStyle(fontSize: 12, color: Colors.black),
                   ),
                   Expanded(
                     child: IconButton(padding: const EdgeInsets.only(bottom: 10), onPressed: (() {
                       if(_versesProvider.versesFoundCounter > 1) {
                         _versesProvider.decreaseVersesFoundCounter();
                         itemScrollController.jumpTo(index: _versesProvider.versesFoundList[_versesProvider.versesFoundCounter - 1]);
                       }
                     }), icon: const Icon(Icons.arrow_drop_down), iconSize: 28),
                   ),
                 ],
               ),
             );
           },
         ),
          SizedBox(
            width: 35,
              child: IconButton(
                  onPressed: widget.function,
                  icon: const Icon(Icons.close)))
        ],
      )
    );
  }
}
