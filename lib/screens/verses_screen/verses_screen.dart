import 'package:biblia_flutter_app/data/saved_verses_provider.dart';
import 'package:biblia_flutter_app/screens/verses_screen/widgets/loading_verses_widget.dart';
import 'package:biblia_flutter_app/services/bible_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/verse_inherited.dart';

int initialVerse = 0;
late SavedVersesProvider savedVersesProvider;

class VersesScreen extends StatefulWidget {
  final String bookName;
  final String abbrev;
  final int chapters;
  final int chapter;
  final int verseNumber;

  const VersesScreen({Key? key, required this.chapter, required this.verseNumber, required this.bookName, required this.abbrev, required this.chapters})
      : super(key: key);

  @override
  State<VersesScreen> createState() => _VersesScreenState();
}

final BibleService service = BibleService();

class _VersesScreenState extends State<VersesScreen> {
  PageController _pageController = PageController();
  int _chapters = 0;
  int _chapter = 0;
  bool notScrolling = true;
  List<Widget> listWidgets = [];
  String verseColor = 'Colors.transparent';
  late String _selectedOption;

  final List<String> _options = [
    'NVI (Nova Versão Internacional)',
    'ACF (Almeida Corrigida Fiel)',
    'RA (Revista e Atualizada)',
    'BBE (Bible in Basic English)',
    'KJV (King James Version)',
    'APEE (La Bible de l\'Épée)',
    'RVR (Versão Espanhola Reina-Valera)'
  ];
  final List<Widget> _optinsReduced = [];

  @override
  initState() {
    _selectedOption = _options[0];
    _chapter = widget.chapter;
    _chapters = widget.chapters;
    initialVerse = widget.verseNumber;
    for (int i = 0; i < _chapters; i++) {
      listWidgets.add(LoadingVersesWidget(bookName: widget.bookName, abbrev: widget.abbrev, chapter: i + 1, verseColors: verseColor,));
    }
    _pageController = PageController(initialPage: widget.chapter - 1);
    savedVersesProvider = Provider.of<SavedVersesProvider>(context, listen: false);
    super.initState();
  }

  @override
  dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return VerseInherited(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: (() {
              savedVersesProvider.refresh();
              Navigator.pushReplacementNamed(context, 'chapter_screen', arguments: {'bookName': widget.bookName, 'abbrev': widget.abbrev, 'chapters': _chapters});
            }),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    height: 30,
                    width: width * 0.35,
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0) //
                                ),
                        border: Border.all(color: Colors.black, width: 2)),
                    child: InkWell(
                      onTap: (() {
                        Navigator.pushReplacementNamed(context, 'home');
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Center(
                          child: (widget.bookName.length < 15)
                              ? Text(widget.bookName)
                              : Text('${widget.bookName.substring(0, 11)}...'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 30,
                width: width * 0.1,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(color: Colors.black, width: 2)),
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, 'chapter_screen', arguments: {'bookName': widget.bookName, 'abbrev': widget.abbrev, 'chapters': _chapters});
                  },
                  child: Center(child: Text(_chapter.toString())),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  width: width * 0.3,
                  height: 30,
                  decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0)),
                      border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: DropdownButton(
                    isExpanded: true,
                    itemHeight: 70.0,
                    value: _selectedOption,
                    items: _options.map((option) {
                      _optinsReduced.add(
                        Center(
                          child: Text(option.split(' ')[0], style: Theme.of(context).textTheme.bodyLarge,),
                        ),
                      );
                      setState(() {
                        _optinsReduced;
                      });
                      return DropdownMenuItem(
                        value: option,
                        child: Center(child: Text(option, style: Theme.of(context).textTheme.bodyLarge,)),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedOption = newValue!;
                      });
                      savedVersesProvider.changeVersion(_selectedOption.split(' ')[0]);
                    },
                    selectedItemBuilder: (BuildContext context) {
                      return _optinsReduced;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        body: NotificationListener<ScrollEndNotification>(
          onNotification: (ScrollEndNotification notification) {
            if (notification.metrics.pixels ==
                notification.metrics.maxScrollExtent) {
              setState(() {
                notScrolling = false;
              });
            } else {
              setState(() {
                notScrolling = true;
              });
            }
            return true;
          },
          child: PageView.builder(
            controller: _pageController,
            itemCount: _chapters,
            itemBuilder: (BuildContext context, int index) {
              return listWidgets[index];
            },
            onPageChanged: (value) {
              setState(() {
                _chapter = value + 1;
                initialVerse = 1;
              });
            },
          ),
        ),
        floatingActionButton: Consumer<SavedVersesProvider>(
          builder: (context, item, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: (notScrolling && savedVersesProvider.versesSelected == false) ? 56 : 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: FloatingActionButton(
                      heroTag: 'btn1',
                      backgroundColor:
                      Theme.of(context).buttonTheme.colorScheme?.background,
                      onPressed: (() {
                        (notScrolling && savedVersesProvider.versesSelected == false)
                            ? setState(() {
                          if (_chapter > 1) {
                            _chapter--;
                            _pageController.previousPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.linear);
                          }
                        })
                            : null;
                      }),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        size: (notScrolling && savedVersesProvider.versesSelected == false) ? 26 : 0,
                        color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: 'btn2',
                    backgroundColor:
                    Theme.of(context).buttonTheme.colorScheme?.background,
                    onPressed: (() {
                      (notScrolling && savedVersesProvider.versesSelected == false)
                          ? setState(() {
                        if (_chapter < _chapters) {
                          _chapter++;
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.linear);
                        }
                      })
                          : null;
                    }),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: (notScrolling && savedVersesProvider.versesSelected == false) ? 26 : 0,
                      color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
