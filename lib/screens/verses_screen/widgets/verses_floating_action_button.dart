import 'dart:developer';

import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/loading_verses_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/alert_dialog.dart';

final FlutterTts _flutterTts = FlutterTts();
final versesProvider = Provider.of<VersesProvider>(navigatorKey!.currentContext!, listen: false);
bool _isSpeaking = false;
int _count = 0;
String _selectedOption = '1x';
double _speechRate = 0.5;
Map _ptVoice = {};
Map _enVoice = {};
Map _esVoice = {};

class VersesFloatingActionButton extends StatefulWidget {
  final bool notScrolling;
  final int chapter;
  final int chapters;
  final List<Map<String, dynamic>> verses;
  final PageController pageController;
  const VersesFloatingActionButton({Key? key, required this.notScrolling, required this.chapter, required this.chapters, required this.pageController, required this.verses}) : super(key: key);

  @override
  State<VersesFloatingActionButton> createState() => _VersesFloatingActionButtonState();
}

class _VersesFloatingActionButtonState extends State<VersesFloatingActionButton> {
  int _chapter = 0;
  int _chapters = 0;
  bool _resetCounter = false;

  void initTts() {
    _flutterTts.getVoices.then((value) {
      try{
        List<Map> voices = List<Map>.from(value);
        _ptVoice = voices.where((element) => element["name"].startsWith("pt")).toList().first;
        _enVoice = voices.where((element) => element["name"].startsWith("en")).toList().first;
        _esVoice = voices.where((element) => element["name"].startsWith("es")).toList().first;
        setVoice(voices.where((element) => element["name"].startsWith("pt")).toList()[0]);
      }catch(e) {
        alertDialog(content: e.toString());
      }
    });
  }

  void reset() {
    _flutterTts.stop();
    versesProvider.clearSelectedVerses(widget.verses);
    setState(() {_count = 0; _isSpeaking = false;});
  }

  void setVoice(Map voice) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userVoice = prefs.getString("voice");
    if(userVoice == null) {
      _flutterTts.setVoice({"name": "pt-BR-default", "locale": "por-default"});
      prefs.setString('voice', 'pt');
      return;
    }
    prefs.setString('voice', voice["name"].substring(0, 1));
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }

  void goToNextChapter() {
    if (_chapter < _chapters) {
      setState(() => _chapter++);
      widget.pageController.nextPage(duration: 500.ms, curve: Curves.linear);
    }
  }

  void goToPrevChapter() {
    if (_chapter > 1) {
      setState(() => _chapter--);
      widget.pageController.previousPage(duration: 500.ms, curve: Curves.linear);
    }
  }

  void initNextChapter() {
    Navigator.pop(context);
    setState(() => _isSpeaking = true);
    Future.delayed(1000.ms).whenComplete(() {
      showModalBottomSheet(context: context, isScrollControlled: true, isDismissible: false, enableDrag: false, barrierColor: Colors.transparent, builder: (context) => SpeechBottomSheet(verses: widget.verses, chapter: widget.chapter, reset: reset));
      _flutterTts.speak('${widget.verses[_count]["bookName"]}, Capítulo ${widget.verses[_count]["chapter"]}, verso, 1');
      versesProvider.highlightSpeechBloc(widget.chapter, _count);
      setState(() => _resetCounter = true);
    });

  }

  @override
  void initState() {
    _chapter = widget.chapter;
    _chapters = widget.chapters;
    initTts();
    _flutterTts.setCompletionHandler(() {
      setState(() => _count++);
      if(_resetCounter) {
        setState(() {_count = 0; _resetCounter = false;});
      }
      if(_count == widget.verses.length) {
        reset();
        goToNextChapter();
        initNextChapter();
        return;
      }
      versesProvider.highlightSpeechBloc(widget.chapter, _count);
      if(itemScrollController?.isAttached ?? false) {
        itemScrollController!.scrollTo(index: _count, duration: 500.ms);
      }
      _flutterTts.speak(widget.verses[_count]["verse"]);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: (widget.notScrolling && versesProvider.bottomSheetOpened == false)
          ? 146
          : 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _prevPageButton(),
          _nextPageButton(),
        ],
      ),
    );
  }

  Widget _nextPageButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'btn2',
          backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
          onPressed: (() {
            (widget.notScrolling && versesProvider.bottomSheetOpened == false)
                ? showModalBottomSheet(context: context, isScrollControlled: true, isDismissible: false, enableDrag: false, barrierColor: Colors.transparent, builder: (context) => SpeechBottomSheet(verses: widget.verses, chapter: widget.chapter, reset: reset))
                : null;
          }),
          child: Icon(
            CupertinoIcons.speaker_2,
            size: (widget.notScrolling && versesProvider.bottomSheetOpened == false)
                ? 22
                : 0,
            color:
            Theme.of(context).buttonTheme.colorScheme?.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'btn3',
          backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
          onPressed: (() {
            (widget.notScrolling && versesProvider.bottomSheetOpened == false)
                ? goToNextChapter()
                : null;
          }),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: (widget.notScrolling && versesProvider.bottomSheetOpened == false)
                ? 22
                : 0,
            color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _prevPageButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 28.0),
      child: FloatingActionButton(
        heroTag: 'btn1',
        backgroundColor:
        Theme.of(context).buttonTheme.colorScheme?.secondary,
        onPressed: (() {
          (widget.notScrolling && versesProvider.bottomSheetOpened == false)
              ? goToPrevChapter()
              : null;
        }),
        child: Icon(
          Icons.arrow_back_ios_rounded,
          size: (widget.notScrolling && versesProvider.bottomSheetOpened == false)
              ? 22
              : 0,
          color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
        ),
      ),
    );
  }
}


class SpeechBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> verses;
  final int chapter;
  final Function() reset;
  const SpeechBottomSheet({super.key, required this.verses, required this.chapter, required this.reset});

  @override
  State<SpeechBottomSheet> createState() => _SpeechBottomSheetState();
}

class _SpeechBottomSheetState extends State<SpeechBottomSheet> {
  int _selectedVerse = _count + 1;
  String _selectedLanguage = 'Português (BR)';

  void updateSpeechRate(String selectedOption) {
    switch (selectedOption) {
      case '0.25x':
        _speechRate = 0.15;
        break;
      case '0.5x':
        _speechRate = 0.25;
        break;
      case '1x':
        _speechRate = 0.5;
        break;
      case '1.5x':
        _speechRate = 0.75;
        break;
      case '2x':
        _speechRate = 0.95;
        break;
    }

    setState(() => _speechRate);
    _flutterTts.pause().whenComplete(()
    => _flutterTts.setSpeechRate(_speechRate).whenComplete(() {
      if(_isSpeaking) {
        _flutterTts.speak(widget.verses[_count]["verse"]);
      }
    }));
  }

  void updateSpeechLanguage(String selectedLanguage) {
    _flutterTts.pause();
    switch(selectedLanguage) {
      case 'Português (BR)':
        _flutterTts.setVoice({"name": _ptVoice["name"], "locale": _ptVoice["locale"]});
        break;
      case 'English (US)':
        _flutterTts.setVoice({"name": _enVoice["name"], "locale": _enVoice["locale"]});
        break;
      case 'Espanhol (ES)':
        _flutterTts.setVoice({"name": _esVoice["name"], "locale": _esVoice["locale"]});
    }

    if(_isSpeaking) {
      _flutterTts.speak(widget.verses[_count]["verse"]);
    }
  }

  void speakNextVerse() {
    if(_count < widget.verses.length) {
      _flutterTts.pause();
      setState(() => _count++);
      scrollTo();
      _flutterTts.speak(widget.verses[_count]["verse"]);
      setState(() => _isSpeaking = true);
    }
  }

  void speakPrevVerse() {
    if(_count > 0) {
      _flutterTts.pause();
      versesProvider.clearSelectedVerses(widget.verses);
      setState(() => _count--);
      scrollTo();
      _flutterTts.speak(widget.verses[_count]["verse"]);
      setState(() => _isSpeaking = true);
    }
  }

  void scrollTo() {
    if(itemScrollController?.isAttached ?? false) {
      itemScrollController!.scrollTo(index: _count, duration: 500.ms);
    }
    versesProvider.highlightSpeechBloc(widget.chapter, _count);
  }

  @override
  void initState() {
    if(_count < 0) {
      setState(() => _count = 0);
    }
    _flutterTts.setSpeechRate(_speechRate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25))
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Center(
                      child: DropdownButton<String>(
                        underline: Container(
                          height: 0,
                          color: Colors.transparent,
                        ),
                        value: _selectedOption,
                        style: Theme.of(context).dropdownMenuTheme.textStyle,
                        iconEnabledColor: Colors.white,
                        onChanged: (String? newValue) {
                          setState(() => _selectedOption = newValue!);
                          updateSpeechRate(_selectedOption);
                        },
                        items: <String>['0.25x', '0.5x', '1x', '1.5x', '2x']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                      ),
                    ),
                ),
                IconButton(onPressed: (() => speakPrevVerse()), icon: const Icon(Icons.skip_previous, size: 40)),
                IconButton(
                    onPressed: (() {
                      versesProvider.clearSelectedVerses(widget.verses);
                      scrollTo();
                      setState(() => _isSpeaking = !_isSpeaking);
                      (!_isSpeaking) ? _flutterTts.pause() : _flutterTts.speak(widget.verses[_count]["verse"]);
                    }),
                    icon: Icon((_isSpeaking) ? CupertinoIcons.pause :  CupertinoIcons.play_fill, size: 40,)
                ),
                IconButton(onPressed: (() => speakNextVerse()), icon: const Icon(Icons.skip_next, size: 40)),
                IconButton(
                    onPressed: (() {
                      setState(() {
                        _count = 0;
                        _isSpeaking = false;
                      });
                      versesProvider.clearSelectedVerses(widget.verses);
                      _flutterTts.stop();
                    }),
                    icon: const Icon(CupertinoIcons.stop_fill)
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    onPressed: (() {
                      widget.reset();
                      Navigator.pop(context);
                    }),
                    icon: const Icon(Icons.close)
                  )
                ),
              ],
            ),
            const Divider(thickness: 1.5),
            Row(
              children: [
                const Text('Ouvir o versículo:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                DropdownButton<int>(
                    underline: Container(
                      height: 0,
                      color: Colors.transparent,
                    ),
                    menuMaxHeight: 400,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    value: _selectedVerse,
                    style: Theme.of(context).dropdownMenuTheme.textStyle,
                    iconEnabledColor: Colors.white,
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedVerse = newValue!;
                        _count = _selectedVerse - 1;
                      });
                      if(_isSpeaking){
                        versesProvider.clearSelectedVerses(widget.verses);
                        scrollTo();
                        _flutterTts.speak(widget.verses[_count]["verse"]);
                      }
                    },
                    items: List.generate(widget.verses.length, (index) => DropdownMenuItem(value: index + 1, child: Center(child: Text('${index + 1}'))))
                ),
              ],
            ),
            Row(
              children: [
                const Text('Idioma:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  underline: Container(
                    height: 0,
                    color: Colors.transparent,
                  ),
                  value: _selectedLanguage,
                  style: Theme.of(context).dropdownMenuTheme.textStyle,
                  iconEnabledColor: Colors.white,
                  onChanged: (String? newValue) {
                    setState(() => _selectedLanguage = newValue!);
                    updateSpeechLanguage(_selectedLanguage);
                  },
                  items: <String>['English (US)', 'Português (BR)', 'Português (PT)', 'Espanhol (ES)']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: Theme.of(context).textTheme.titleSmall),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
