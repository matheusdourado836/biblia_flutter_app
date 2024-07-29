import 'dart:convert';
import 'dart:io';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/verses_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/plans_provider.dart';
import '../../../helpers/alert_dialog.dart';
import '../../../helpers/plan_type_to_days.dart';
import '../../../models/enums.dart';
import '../../chapter_screen/chapter_screen.dart';

final FlutterTts _flutterTts = FlutterTts();
final versesProvider = Provider.of<VersesProvider>(navigatorKey!.currentContext!, listen: false);
bool _isSpeaking = false;
int _count = 0;
String _selectedOption = '1x';
double _speechRate = 0.5;
List<Map<dynamic, dynamic>> _voices = [];
Map<dynamic, dynamic> _selectedLanguage = {};

class VersesFloatingActionButton extends StatefulWidget {
  final bool notScrolling;
  final String bookName;
  final int chapter;
  final int chapters;
  final List<Map<String, dynamic>> verses;
  final PageController pageController;
  final bool? readingPlan;
  const VersesFloatingActionButton({super.key, required this.notScrolling, required this.chapter, required this.chapters, required this.pageController, required this.verses, this.readingPlan, required this.bookName});

  @override
  State<VersesFloatingActionButton> createState() => _VersesFloatingActionButtonState();
}

class _VersesFloatingActionButtonState extends State<VersesFloatingActionButton> {
  int _chapter = 0;
  int _chapters = 0;
  bool _resetCounter = false;
  PlansProvider? _planProvider;

  void initTts() {
    _flutterTts.setLanguage("pt-BR");
    _flutterTts.getVoices.then((value) {
      final name = Platform.isAndroid ? "name" : "locale";
      List<Map> voices = List<Map>.from(value);
      if(voices.isNotEmpty) {
        final ptVoices = voices.where((element) => element[name].toLowerCase().startsWith("pt-br")).toList();
        _voices = [];
        for(var i = 0; i < ptVoices.length; i++) {
          _voices.add({"voice": "Português (BR) ${i + 1}", "value": ptVoices[i]});
        }

        final enVoice = voices.where((element) => element[name].toLowerCase().startsWith("en")).toList().first;
        final esVoice = voices.where((element) => element[name].toLowerCase().startsWith("es")).toList()[1];
        final frVoice = voices.where((element) => element[name].toLowerCase().startsWith("fr")).toList().first;
        _voices.add({"voice": "English (US)", "value": enVoice});
        _voices.add({"voice": "Español (ES)", "value": esVoice});
        _voices.add({"voice": "Français (FR)", "value": frVoice});
        setState(() => _voices);
        getVoice();
      }
    }).onError((e, stackTrace) {
      alertDialog(title: 'Erro', content: 'Não foi possível carregar as vozes\n${e.toString()}');
    });
  }

  void reset() {
    Platform.isAndroid ? _flutterTts.stop() : _flutterTts.pause();
    versesProvider.clearSelectedVerses(widget.verses);
    setState(() {_count = 0; _isSpeaking = false;});
  }

  Future<void> setVoice(Map voice) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    prefs.setString('voice', jsonEncode(voice));
    setState(() => _selectedLanguage = voice);
    await _flutterTts.setVoice({"name": voice["value"]["name"], "locale": voice["value"]["locale"]});
    return;
  }

  void getVoice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userVoice = prefs.getString("voice");
    if(userVoice == null) {
      await prefs.setString('voice', jsonEncode(_voices[0]));
    }
    userVoice = prefs.getString('voice')!;
    final selectedVoice = json.decode(userVoice);
    _flutterTts.setVoice({"name": selectedVoice["value"]["name"], "locale": selectedVoice["value"]["locale"]});
    setState(() => _selectedLanguage = selectedVoice as Map<dynamic, dynamic>);
  }

  void goToNextChapter() {
    if (_chapter < _chapters) {
      if(widget.readingPlan == null) {
        if(!isChapterRead) {
          chaptersProvider.saveChapter(widget.bookName, _chapter.toString());
        }
        setState(() => isChapterRead = true);
      }else {
        final currentPlan = PlanType.fromCode(dailyRead!.progressId!);
        dailyRead!.completed = 1;
        _planProvider!.markChapter(dailyRead!.chapter!, read: dailyRead!.completed!, progressId: dailyRead!.progressId!, update: true);
        _planProvider!.checkIfCompletedDailyRead(planId: dailyRead!.progressId!, qtdChapterRequired: planTypeToChapters(planType: currentPlan, lastDay: isLastDay ? true : null));
      }
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
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          barrierColor: Colors.transparent,
          builder: (context) => SpeechBottomSheet(
            verses: widget.verses,
            chapter: widget.chapter,
            reset: reset,
            setVoice: (voice) => setVoice(voice),
          )
      );
      _flutterTts.speak('${widget.verses[_count]["bookName"]}, Capítulo ${widget.verses[_count]["chapter"]}, verso, 1');
      versesProvider.highlightSpeechBloc(widget.chapter, _count);
      setState(() => _resetCounter = true);
    });

  }

  @override
  void initState() {
    _chapter = widget.chapter;
    _chapters = widget.chapters;
    if(widget.readingPlan != null) {
      _planProvider = Provider.of<PlansProvider>(context, listen: false);
    }
    initTts();
    _flutterTts.setCompletionHandler(() {
      setState(() => _count++);
      if(_resetCounter) {
        setState(() {_count = 0; _resetCounter = false;});
      }
      if(_count == widget.verses.length) {
        if(_chapter == _chapters) {
          Navigator.pop(context);
          reset();
          return;
        }
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
            if(widget.notScrolling && versesProvider.bottomSheetOpened == false) {
              if(_voices.isEmpty) {
                alertDialog(title: 'Erro', content: 'Não é possível ouvir os versículos em áudio no momento.\nTente novamente mais tarde.');
                return;
              }
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: false,
                  enableDrag: false,
                  barrierColor: Colors.transparent,
                  builder: (context) => SpeechBottomSheet(
                    verses: widget.verses,
                    chapter: widget.chapter,
                    reset: reset,
                    setVoice: (voice) => setVoice(voice),
                  ),
              );
            }
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
  final Function(Map voice) setVoice;
  const SpeechBottomSheet({super.key, required this.verses, required this.chapter, required this.reset, required this.setVoice});

  @override
  State<SpeechBottomSheet> createState() => _SpeechBottomSheetState();
}

class _SpeechBottomSheetState extends State<SpeechBottomSheet> {
  int _selectedVerse = _count + 1;
  Map<dynamic, dynamic> _language = {};

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
    _flutterTts.pause().whenComplete(() => _flutterTts.setSpeechRate(_speechRate).whenComplete(() {
      if(_isSpeaking) {
        _flutterTts.speak(widget.verses[_count]["verse"]);
      }
    }));
  }

  void updateSpeechLanguage(String selectedLanguage) {
    _flutterTts.pause();
    final language = _voices.firstWhere((element) => element["voice"] == selectedLanguage);
    widget.setVoice(language).whenComplete(() {
      if(_isSpeaking) {
        _flutterTts.speak(widget.verses[_count]["verse"]);
      }
    });
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
    if(_voices.where((language) => language["voice"] == _selectedLanguage["voice"]).isEmpty) {
      _language = _voices[0];
    }else {
      _language = _voices.firstWhere((language) => language["voice"] == _selectedLanguage["voice"]);
    }
    if(_count < 0) {
      setState(() => _count = 0);
    }
    _flutterTts.setSpeechRate(_speechRate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25))
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0),
                child: Row(
                  children: [
                    Center(
                      child: DropdownButton<String>(
                        underline: Container(
                          height: 1,
                          color: Colors.black,
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
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                                  //_count = 0;
                                  _isSpeaking = false;
                                });
                                versesProvider.clearSelectedVerses(widget.verses);
                                Platform.isAndroid ? _flutterTts.stop() : _flutterTts.pause();
                              }),
                              icon: const Icon(CupertinoIcons.stop_fill, size: 32)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1.5),
              Padding(
                padding: (Platform.isAndroid) ? const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0) : const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Idioma:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        DropdownButton<Map<dynamic, dynamic>>(
                          underline: Container(
                            height: 0,
                            color: Colors.transparent,
                          ),
                          value: _language,
                          style: Theme.of(context).dropdownMenuTheme.textStyle,
                          iconEnabledColor: Colors.white,
                          onChanged: (Map<dynamic, dynamic>? newValue) {
                            setState(() {
                              _selectedLanguage = newValue!;
                              _language = _selectedLanguage;
                            });
                            updateSpeechLanguage(_selectedLanguage["voice"]);
                          },
                          items: _voices
                              .map((Map<dynamic, dynamic> value) {
                            return DropdownMenuItem<Map<dynamic, dynamic>>(
                              value: value,
                              child: Text(value["voice"], style: Theme.of(context).textTheme.titleSmall),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: -5,
          right: 10,
          child: IconButton(
              alignment: Alignment.centerRight,
              onPressed: (() {
                widget.reset();
                Navigator.pop(context);
              }),
              icon: const Icon(Icons.close, size: 32, color: Colors.white,)
          ),
        )
      ],
    );
  }
}
