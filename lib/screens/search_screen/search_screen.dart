import 'package:biblia_flutter_app/data/search_verses_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  late SearchVersesProvider _searchVersesProvider;
  List<Map<String, dynamic>>? listResult;
  Map<String, dynamic> map = {};
  String _selectedOption = '';
  final List<String> _options = [
    'NVI',
    'ACF',
  ];

  @override
  void initState() {
    _selectedOption = _options[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _searchVersesProvider = Provider.of<SearchVersesProvider>(context, listen: false);
    _searchVersesProvider.loadBibleData(version: _selectedOption.toLowerCase());
    return Scaffold(
        appBar: AppBar(
          leadingWidth: 24,
          title: TextField(
            controller: _textEditingController,
            onSubmitted: ((value) {
              setState(() {
                _searchVersesProvider.searchVerses(
                    _textEditingController.text.trim(),
                    _selectedOption.toLowerCase()).then((value) => listResult = value);
              });
            }),
            decoration: const InputDecoration(
                icon: Icon(Icons.search),
                hintText: 'Digite o versículo aqui...'),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: DropdownButton(
                value: _selectedOption,
                items: _options.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option, style: Theme.of(context).textTheme.bodyLarge,),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedOption = newValue!;
                  });
                },
              ),
            ),
            ElevatedButton(
                onPressed: (() {
                  setState(() {
                    _searchVersesProvider.searchVerses(
                        _textEditingController.text.trim(),
                        _selectedOption.toLowerCase()).then((value) => listResult = value);
                  });
                }),
                child: const Text('ok'),
            ),
          ],
        ),
        body: Container(
          color: Theme.of(context).primaryColor,
          child: Consumer<SearchVersesProvider>(
            builder: (context, list, child) {
              if (listResult != null && listResult!.isNotEmpty) {
                return ListView.builder(
                    itemCount: listResult!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: (() {
                            setState(() {
                              map["bookName"] = listResult![index]['book'];
                              map["abbrev"] = listResult![index]['abbrev'];
                              map["chapters"] =
                              listResult![index]['qtdChapters'];
                              map["chapter"] =
                              listResult![index]['chapter'];
                              map["verseNumber"] =
                              listResult![index]['verseNumber'];
                            });
                            Navigator.pushNamed(
                                context, 'verses_screen', arguments: map);
                          }),
                          child: Card(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Text(
                                        '${listResult![index]['book']} ${listResult![index]['chapter']}:${listResult![index]['verseNumber']}',
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .titleLarge,),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .surface,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          '${listResult![index]['verse']}',
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .bodyLarge),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              } else if (listResult != null && listResult!.isEmpty) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Image(
                        image: AssetImage('assets/images/nothing_yet.png')),
                    SizedBox(height: 32),
                    Text('Nenhum Versículo Encontrado...',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w200),
                        textAlign: TextAlign.center)
                  ],
                );
              } else {
                return Container();
              }
            },),
        )
    );
  }
}
