import 'package:biblia_flutter_app/data/search_verses_provider.dart';
import 'package:biblia_flutter_app/data/version_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../../data/verses_provider.dart';
import '../../helpers/version_to_name.dart';
import '../../helpers/progress_dialog.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late SearchVersesProvider _searchVersesProvider;
  late VersesProvider _versesProvider;
  late VersionProvider versionProvider;
  List<Map<String, dynamic>>? listResult;
  Map<String, dynamic> map = {};
  final ValueNotifier<String> _findInSelectedOption = ValueNotifier('');
  String _selectedOption = '';
  final List<String> _findInOptions = [
    'Toda a Biblia',
    'Antigo Testamento',
    'Novo Testamento',
  ];
  final ValueNotifier<String> _selectedBook = ValueNotifier('');
  final ValueNotifier<List<String>> _findInBooks = ValueNotifier([]);
  final List<String> _OTBooks = [];
  final List<String> _NTBooks = [];
  List<String> _allBooks = [];
  final ValueNotifier<bool> _preciseSearch = ValueNotifier(false);

  @override
  void initState() {
    versionProvider = Provider.of<VersionProvider>(context, listen: false);
    _searchVersesProvider = Provider.of<SearchVersesProvider>(context, listen: false);
    _versesProvider = Provider.of<VersesProvider>(context, listen: false);
    _versesProvider.loadUserData();
    _selectedOption = versionProvider.selectedOption;
    _findInSelectedOption.value = _findInOptions[0];
    _findInBooks.value.add('Todos');
    _allBooks.add('Todos');
    _OTBooks.add('Todos');
    _NTBooks.add('Todos');
    _selectedBook.value = 'Todos';
    for (var book in _versesProvider.bibleData[0]["text"]) {
      _findInBooks.value.add(book["name"]);
    }
    _allBooks = _findInBooks.value;
    _OTBooks.addAll(_allBooks.sublist(1, 40));
    _NTBooks.addAll(_allBooks.sublist(40, 67));
    super.initState();
  }

  void onTap() {
    _versesProvider.clear();
    _versesProvider.loadVerses(map["bookIndex"], map["bookName"], versionName: _selectedOption.toLowerCase().split(' ')[0]);
    Navigator.pushNamed(context, 'verses_screen', arguments: map);
  }

  Future<void> doSearch() async {
    if (_textEditingController.text != '') {
      List<dynamic> allBooks = _versesProvider.bibleData[0]["text"];
      final bookIndex = allBooks.indexWhere((element) => element["name"] == _selectedBook);
      final versionIndex = versionProvider.options.indexOf(_selectedOption);
      _focusNode.unfocus();
      setState(() {
        if (bookIndex != -1) {
          _findInSelectedOption.value = _findInOptions[0];
        }
        listResult = _searchVersesProvider.searchVerses(
            _textEditingController.text.trim(), versionIndex,
            findIn: _findInSelectedOption.value.toLowerCase(),
            findInBookIndex: bookIndex,
            preciseSearch: _preciseSearch.value
        );
      });
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    versionProvider.changeSelectedOption = _selectedOption;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pesquisar versículos'),
        actions: [
          IconButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              showDragHandle: true,
              useSafeArea: true,
              builder: (context) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Versão:'),
                          SizedBox(
                            width: 100,
                            height: 30,
                            child: Consumer<VersionProvider>(
                              builder: (context, value, _) {
                                return DropdownButton(
                                  underline: Container(
                                    height: 0,
                                    color: Colors.transparent,
                                  ),
                                  style: Theme.of(context).dropdownMenuTheme.textStyle,
                                  isExpanded: true,
                                  itemHeight: 120.0,
                                  value: versionProvider.selectedOption,
                                  items: versionProvider.options.where((v) => v != 'Multi versão').map((option) {
                                    if(value.getDownloadedVersion(versionToName(option))) {
                                      return DropdownMenuItem(
                                        value: option,
                                        child: InkWell(
                                          onTap: () => showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) => ProgressDialog(versionName: versionToName(option), versionNameRaw: option.split(' ')[0])
                                          ).whenComplete(() {
                                            value.loadBibleData().whenComplete(() {
                                              Navigator.pop(context);
                                              setState(() {});
                                            });
                                          }),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  option,
                                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 12, color: Theme.of(context).textTheme.titleSmall!.color!.withValues(alpha: .5)),
                                                ),
                                              ),
                                              const Icon(Icons.download, size: 16,)
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return DropdownMenuItem(
                                      value: option,
                                      child: Text(
                                        option,
                                        style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 12),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedOption = newValue!;
                                      versionProvider.changeVersion(newValue.toString());
                                    });
                                  },
                                  selectedItemBuilder: (BuildContext context) {
                                    return value.options.where((v) => v != 'Multi versão').map(
                                      (v) => Center(
                                        child: Text(v.toUpperCase().split(' ')[0]),
                                      )
                                    ).toList();
                                  },
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Buscar em:'),
                        ValueListenableBuilder(
                          valueListenable: _findInSelectedOption,
                          builder: (context, value, _) => DropdownButton(
                            alignment: Alignment.centerRight,
                            underline: Container(
                              height: 0,
                              color: Colors.transparent,
                            ),
                            value: _findInSelectedOption.value,
                            items: _findInOptions.map((option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(
                                    option,
                                    style: Theme.of(context).textTheme.bodyLarge
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              _findInSelectedOption.value = newValue!;
                              _selectedBook.value = 'Todos';
                              if(newValue == 'Antigo Testamento') {
                                _findInBooks.value = _OTBooks;
                              }else if(newValue == 'Novo Testamento') {
                                _findInBooks.value = _NTBooks;
                              }else {
                                _findInBooks.value = _allBooks;
                              }
                            },
                          )
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Livro:'),
                        ValueListenableBuilder(
                          valueListenable: _findInBooks,
                          builder: (context, val, _) => ValueListenableBuilder(
                            valueListenable: _selectedBook,
                            builder: (context, value, _) => DropdownButton(
                              alignment: Alignment.centerRight,
                              underline: Container(
                                height: 0,
                                color: Colors.transparent,
                              ),
                              value: _selectedBook.value,
                              items: _findInBooks.value.map((option) {
                                return DropdownMenuItem(
                                  value: option,
                                  child: Text(
                                      option,
                                      style: Theme.of(context).textTheme.bodyLarge
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) => _selectedBook.value = newValue!,
                            )
                          )
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Busca precisa'),
                            const SizedBox(width: 4),
                            Tooltip(
                              message: 'A busca precisa retorna versos que contenham exatamente a palavra que você está pesquisando.'
                                  '\nEx. a pesquisa "amor" não retornará um verso que contenha "amorreus".',
                              showDuration: const Duration(seconds: 10),
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onSurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              triggerMode: TooltipTriggerMode.tap,
                              child: const Icon(Icons.help_outline, size: 20, color: Colors.grey),
                            ),
                          ],
                        ),
                        ValueListenableBuilder(
                          valueListenable: _preciseSearch,
                          builder: (context, value, _) => Switch(
                            value: value,
                            onChanged: (newValue) =>  _preciseSearch.value = !_preciseSearch.value
                          )
                        )
                      ],
                    ),
                  ],
                ),
              )
            ),
            icon: const Icon(Icons.settings)
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Theme.of(context).primaryColor,
              automaticallyImplyLeading: false,
              pinned: true,
              collapsedHeight: 110,
              expandedHeight: 110,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textEditingController,
                              focusNode: _focusNode,
                              style: Theme.of(context).textTheme.bodyMedium,
                              onSubmitted: (value) => doSearch(),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                hintText: 'Digite o versículo aqui...',
                                hintStyle: const TextStyle(color: Colors.grey),
                                suffixIcon: IconButton(
                                  onPressed: () => _textEditingController.clear(),
                                  icon: const Icon(Icons.close)
                                ),
                                filled: true,
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 0, color: Theme.of(context).colorScheme.onSurface), borderRadius: const BorderRadius.all(Radius.circular(10))),
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0, color: Theme.of(context).colorScheme.onSurface, strokeAlign: 10), borderRadius: const BorderRadius.all(Radius.circular(10))),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () => doSearch(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onError,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16)
                            ),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if(listResult?.isNotEmpty ?? false)
                        Text(
                          '${listResult!.length} Resultados',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                    ],
                  ),
                ),
              ),
            ),
            if(listResult != null)
              if(listResult!.isEmpty)
                SliverToBoxAdapter(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/not_found.png'),
                      const SizedBox(height: 16),
                      const Text('Nenhum versículo encontrado',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
                        textAlign: TextAlign.center
                      )
                    ],
                  ),
                )
                else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final l = listResult![index];
                      final bookname = l['book'];
                      final abbrev = l['abbrev'];
                      final verse = l['verse'];
                      final bookIndex = l['bookIndex'];
                      final qtdChapters = l['qtdChapters'];
                      final chapter = l['chapter'];
                      final verseNumber = l['verseNumber'];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              map["bookName"] = bookname;
                              map["abbrev"] = abbrev;
                              map["bookIndex"] = bookIndex;
                              map["chapters"] = qtdChapters;
                              map["chapter"] = chapter;
                              map["verseNumber"] = verseNumber;
                            });
                            onTap();
                          },
                          child: Card(
                            child: Slidable(
                              endActionPane: ActionPane(
                                extentRatio: .55,
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      _searchVersesProvider.share(
                                        bookname,
                                        verse,
                                        chapter,
                                        verseNumber,
                                      );
                                    },
                                    icon: Icons.share,
                                    label: 'Share',
                                    backgroundColor: Theme.of(context)
                                        .buttonTheme
                                        .colorScheme!
                                        .surface,
                                  ),
                                  SlidableAction(
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                    onPressed: (context) {
                                      _searchVersesProvider.copyText(
                                        bookname,
                                        verse,
                                        chapter,
                                        verseNumber,
                                      );
                                    },
                                    icon: Icons.copy,
                                    label: 'Copiar',
                                    backgroundColor: Theme.of(context)
                                        .buttonTheme
                                        .colorScheme!
                                        .surface
                                        .withValues(alpha: 0.9),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 16.0,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '$bookname $chapter:$verseNumber',
                                          style: Theme.of(context).textTheme.titleLarge,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12.0),
                                      margin: const EdgeInsets.only(bottom: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text.rich(
                                        TextSpan(children: l["highlightedTexts"]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: listResult!.length,
                  ),
                )
          ],
        ),
      ),
    );
  }
}
