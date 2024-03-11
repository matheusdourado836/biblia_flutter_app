import 'package:biblia_flutter_app/data/bible_data.dart';
import 'package:biblia_flutter_app/data/search_verses_provider.dart';
import 'package:biblia_flutter_app/data/version_provider.dart';
import 'package:biblia_flutter_app/helpers/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../../data/verses_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final BibleData _bibleData = BibleData();
  late SearchVersesProvider _searchVersesProvider;
  late VersesProvider _versesProvider;
  late VersionProvider versionProvider;
  List<Map<String, dynamic>>? listResult;
  Map<String, dynamic> map = {};
  String _findInSelectedOption = '';
  String _selectedOption = '';
  final List<String> _findInOptions = [
    'Toda a Biblia',
    'Antigo Testamento',
    'Novo Testamento',
  ];
  String _selectedBook = '';
  final List<String> _findInBooks = [];


  @override
  void initState() {
    versionProvider = Provider.of<VersionProvider>(context, listen: false);
    _searchVersesProvider = Provider.of<SearchVersesProvider>(context, listen: false);
    _versesProvider = Provider.of<VersesProvider>(context, listen: false);
    _versesProvider.loadUserData();
    _selectedOption = 'NVI (Nova Versão Internacional)';
    _findInSelectedOption = _findInOptions[0];
    _findInBooks.add('Todos');
    _selectedBook = 'Todos';
    for(var book in _bibleData.data[0]) {
      _findInBooks.add(book["name"]);
    }
    super.initState();
  }

  void onTap() {
    _versesProvider.clear();
    _versesProvider.loadVerses(map["bookIndex"], map["bookName"],
      versionIndex: versionProvider.options.indexOf(versionProvider.selectedOption))
      .catchError((error) => alertDialog(title: 'Erro ao carregar versículo', content: 'Não foi possível carregar este versículo\nPor favor tente novamente'));
    Navigator.pushNamed(context, 'verses_screen', arguments: map);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 24,
        title: TextField(
          controller: _textEditingController,
          focusNode: _focusNode,
          style: Theme.of(context).textTheme.bodyMedium,
          onSubmitted: ((value) {
            List<dynamic> allBooks = _bibleData.data[0];
            final bookIndex = allBooks.indexWhere((element) => element["name"] == _selectedBook);
            final versionIndex = versionProvider.options.indexOf(_selectedOption);
            _focusNode.unfocus();
            if (_textEditingController.text != '') {
              setState(() {
                if(bookIndex != -1) {
                  _findInSelectedOption = _findInOptions[0];
                }
                _searchVersesProvider.searchVerses(_textEditingController.text.trim(), versionIndex, findIn: _findInSelectedOption.toLowerCase(), findInBookIndex: bookIndex).then((value) => listResult = value);
              });
            }
          }),
          decoration: const InputDecoration(icon: Icon(Icons.search), hintText: 'Digite o versículo aqui...'),

        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: (() {
                List<dynamic> allBooks = _bibleData.data[0];
                final bookIndex = allBooks.indexWhere((element) => element["name"] == _selectedBook);
                final versionIndex = versionProvider.options.indexOf(_selectedOption);
                _focusNode.unfocus();
                if (_textEditingController.text != '') {
                  setState(() {
                    if(bookIndex != -1) {
                      _findInSelectedOption = _findInOptions[0];
                    }
                    _searchVersesProvider.searchVerses(_textEditingController.text.trim(), versionIndex, findIn: _findInSelectedOption.toLowerCase(), findInBookIndex: bookIndex).then((value) => listResult = value);
                  });
                }
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onError,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              child: const Text('ok'),
            ),
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
              collapsedHeight: 168,
              expandedHeight: 168,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Versão:'),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.30,
                              height: 30,
                              child: DropdownButton(
                                underline: Container(
                                  height: 0,
                                  color: Colors.transparent,
                                ),
                                style: Theme.of(context).dropdownMenuTheme.textStyle,
                                isExpanded: true,
                                itemHeight: 80.0,
                                value: versionProvider.selectedOption,
                                items: versionProvider.options.map((option) {
                                  versionProvider.setListItem(option.split(' ')[0]);
                                  return DropdownMenuItem(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: Theme.of(context).textTheme.titleSmall,
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
                                  return versionProvider.versionsList;
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
                          DropdownButton(
                            alignment: Alignment.centerRight,
                            underline: Container(
                              height: 0,
                              color: Colors.transparent,
                            ),
                            value: _findInSelectedOption,
                            items: _findInOptions.map((option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(option, style: Theme.of(context).textTheme.bodyLarge),
                              );
                            }).toList(),
                            onChanged: (newValue) => setState(() => _findInSelectedOption = newValue!),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Livro:'),
                          DropdownButton(
                            alignment: Alignment.centerRight,
                            underline: Container(
                              height: 0,
                              color: Colors.transparent,
                            ),
                            value: _selectedBook,
                            items: _findInBooks.map((option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(option, style: Theme.of(context).textTheme.bodyLarge),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() => _selectedBook = newValue!);
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            (listResult == null)
                ? SliverToBoxAdapter(
                    child: Container(),
                  )
                : (listResult != null && listResult!.isEmpty)
                    ? SliverToBoxAdapter(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/not_found.png'),
                            const SizedBox(height: 16),
                            const Text('Nenhum versículo encontrado',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
                              textAlign: TextAlign.center)
                          ],
                        ),
                      )
                    : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Consumer<SearchVersesProvider>(
                    builder: (context, list, child) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: (() {
                            setState(() {
                              map["bookName"] = listResult![index]['book'];
                              map["abbrev"] = listResult![index]['abbrev'];
                              map["bookIndex"] = listResult![index]['bookIndex'];
                              map["chapters"] = listResult![index]['qtdChapters'];
                              map["chapter"] = listResult![index]['chapter'];
                              map["verseNumber"] = listResult![index]['verseNumber'];
                            });
                            onTap();
                          }),
                          child: Card(
                            child: Slidable(
                              endActionPane: ActionPane(
                                extentRatio: .55,
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      _searchVersesProvider.share(
                                          listResult![index]['book'],
                                          listResult![index]['verse'],
                                          listResult![index]
                                          ['chapter'],
                                          listResult![index]
                                          ['verseNumber']);
                                    },
                                    icon: Icons.share,
                                    label: 'Share',
                                    backgroundColor: Theme.of(context)
                                        .buttonTheme
                                        .colorScheme!
                                        .background,
                                  ),
                                  SlidableAction(
                                    borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                                    onPressed: (context) {
                                      _searchVersesProvider.copyText(
                                          listResult![index]['book'],
                                          listResult![index]['verse'],
                                          listResult![index]
                                          ['chapter'],
                                          listResult![index]
                                          ['verseNumber']);
                                    },
                                    icon: Icons.copy,
                                    label: 'Copiar',
                                    backgroundColor: Theme.of(context)
                                        .buttonTheme
                                        .colorScheme!
                                        .background
                                        .withOpacity(0.9),
                                  )
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${listResult![index]['book']} ${listResult![index]['chapter']}:${listResult![index]['verseNumber']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12.0),
                                      margin: const EdgeInsets.only(bottom: 4),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.background,
                                          borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: Text.rich(TextSpan(
                                          children: listResult![index]["highlightedTexts"]
                                      )),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },childCount: listResult!.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}