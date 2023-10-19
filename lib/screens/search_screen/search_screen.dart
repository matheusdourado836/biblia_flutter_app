import 'package:biblia_flutter_app/data/bible_data.dart';
import 'package:biblia_flutter_app/data/search_verses_provider.dart';
import 'package:biblia_flutter_app/data/version_provider.dart';
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

  @override
  void initState() {
    versionProvider = Provider.of<VersionProvider>(context, listen: false);
    _selectedOption = 'NVI (Nova Versão Internacional)';
    _findInSelectedOption = _findInOptions[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    _searchVersesProvider = Provider.of<SearchVersesProvider>(context, listen: false);
    _versesProvider = Provider.of<VersesProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 24,
        title: TextField(
          controller: _textEditingController,
          focusNode: _focusNode,
          style: Theme.of(context).textTheme.bodyMedium,
          onSubmitted: ((value) {
            setState(() {
              _searchVersesProvider
                  .searchVerses(_textEditingController.text.trim(),
                      versionProvider.options.indexOf(_selectedOption),
                      findIn: _findInSelectedOption.toLowerCase())
                  .then((value) => listResult = value);
            });
          }),
          decoration: const InputDecoration(
            icon: Icon(Icons.search), hintText: 'Digite o versículo aqui...',
          ),

        ),
        actions: [
          ElevatedButton(
            onPressed: (() {
              final versionIndex = versionProvider.options.indexOf(_selectedOption);
              _focusNode.unfocus();
              if (_textEditingController.text != '') {
                setState(() {
                  _searchVersesProvider
                      .searchVerses(_textEditingController.text.trim(),
                      versionIndex,
                          findIn: _findInSelectedOption.toLowerCase())
                      .then((value) => listResult = value);
                });
              }
            }),
            child: const Text('ok'),
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
              collapsedHeight: 150,
              expandedHeight: 150,
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
                            onChanged: (newValue) {
                              setState(() {
                                _findInSelectedOption = newValue!;
                              });
                            },
                          )
                        ],
                      ),
                      //TODO FAZER UM SEARCH BY BOOK AQUI NESSA ROW!!!
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Buscar em:'),
                          DropdownButton(
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
                            onChanged: (newValue) {
                              setState(() {
                                _findInSelectedOption = newValue!;
                              });
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
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/not_found.png', width: double.infinity,
                              height: height * .55,),
                            const SizedBox(height: 32),
                            const Text('Nenhum versículo encontrado',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w200),
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
                                        map["bookName"] =
                                            listResult![index]['book'];
                                        map["abbrev"] =
                                            listResult![index]['abbrev'];
                                        map["bookIndex"] =
                                            listResult![index]['bookIndex'];
                                        map["chapters"] =
                                            listResult![index]['qtdChapters'];
                                        map["chapter"] =
                                            listResult![index]['chapter'];
                                        map["verseNumber"] =
                                            listResult![index]['verseNumber'];
                                      });
                                      _versesProvider.clear();
                                      _versesProvider.loadVerses(map["bookIndex"], map["bookName"],
                                          versionIndex: versionProvider.options.indexOf(versionProvider.selectedOption))
                                          .whenComplete(() =>
                                              Navigator.pushNamed(
                                                  context, 'verses_screen',
                                                  arguments: map));
                                    }),
                                    child: Card(
                                      child: Slidable(
                                        endActionPane: ActionPane(
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
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
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
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text.rich(TextSpan(
                                                    children: listResult![index]["highlightedTexts"]
                                                  )),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: listResult!.length,
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

class ListBooks extends StatelessWidget {
  const ListBooks({super.key});

  @override
  Widget build(BuildContext context) {
    final bibleData = Provider.of<SearchVersesProvider>(context);
    return SingleChildScrollView(
      child: Column(
        children: bibleData.bookToIndex().map((bookName) => Text(bookName, style: Theme.of(context).textTheme.bodyLarge,)).toList(),
      ),
    );
  }
}

