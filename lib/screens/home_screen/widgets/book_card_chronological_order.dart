import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/verses_provider.dart';
import '../../../helpers/call_chapter_page.dart';
import '../../../models/book.dart';

class BookCardChronologicalOrder extends StatefulWidget {
  final List<Book>? database;
  final Function bookIsRead;
  const BookCardChronologicalOrder({super.key, this.database, required this.bookIsRead});

  @override
  State<BookCardChronologicalOrder> createState() => _BookCardChronologicalOrderState();
}

class _BookCardChronologicalOrderState extends State<BookCardChronologicalOrder> {
  late Map<String, List<Book>> booksMap;
  Map<String, List<Book>> orderedList = {};
  @override
  void initState() {
    booksMap = ChapterPageHelpers().formatedBookMap(widget.database!);
    List<int> indexArray = [
      0, 17, 1, 2, 3, 4, 5, 6, 7, 8, 9, 18, 10, 12, 19, 21, 20, 11, 13, 30, 28, 31, 29,
      27, 32, 22, 33, 35, 23, 24, 34, 26, 25, 14, 16, 15, 36, 37, 38
    ];
    List<Book> mappedList = indexArray.map((index) => booksMap['livrosVT']![index]).toList();
    setState(() {
      orderedList['livrosVT'] = mappedList;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      widget.database;
    });
    return Consumer<VersesProvider>(
      builder: (context, value, child) {
        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Velho Testamento:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                _oldTestamentCards(value.clear),
                const SizedBox(height: 60,),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Novo Testamento:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                _newTestamentCards(value.clear),
                const SizedBox(height: 80,),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _oldTestamentCards(Function clear) {
    final screenOrientation = MediaQuery.of(context).orientation;
    final screenSize = MediaQuery.of(context).size.width;
    return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 39,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: (screenSize > 500 && screenOrientation == Orientation.portrait) ? 100 : 80.0,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 1/1
        ),
        itemBuilder: (context, i) {
          String abbrevRaw = orderedList["livrosVT"]![i].abbrev;
          String abbrev = (abbrevRaw.length > 2 && abbrevRaw.length < 4) ? '${abbrevRaw.split('')[0]}${abbrevRaw.split('')[1].toUpperCase()}${abbrevRaw.substring(2)}' : '${abbrevRaw.split('')[0].toUpperCase()}${abbrevRaw.substring(1)}';
          return Stack(
            children: <Widget>[
              Card(
                elevation: 1.0,
                child: InkWell(
                  onTap: (() {
                    clear();
                    Navigator.pushNamed(context, 'chapter_screen', arguments: {
                      'bookName': orderedList["livrosVT"]![i].name,
                      'abbrev': abbrev,
                      'bookIndex': booksMap["livrosVT"]!.indexOf(orderedList["livrosVT"]![i]),
                      'chapters': orderedList["livrosVT"]![i].chapters,
                    }).then((value) => setState(() {}));
                  }),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        abbrev,
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                  child: (widget.bookIsRead(orderedList["livrosVT"]![i].name))
                      ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context)
                        .buttonTheme
                        .colorScheme
                        ?.secondary,
                  )
                      : null),
            ],
          );
        });
  }

  Widget _newTestamentCards(Function clear) {
    final screenOrientation = MediaQuery.of(context).orientation;
    final screenSize = MediaQuery.of(context).size.width;
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: 27,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: (screenSize > 500 && screenOrientation == Orientation.portrait) ? 100 : 80.0,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 1/1
      ),
      itemBuilder: (context, i) {
        String abbrevRaw = booksMap["livrosNT"]![i].abbrev;
        String abbrev = (abbrevRaw.length > 2 && abbrevRaw.length < 4) ? '${abbrevRaw.split('')[0]}${abbrevRaw.split('')[1].toUpperCase()}${abbrevRaw.substring(2)}' : '${abbrevRaw.split('')[0].toUpperCase()}${abbrevRaw.substring(1)}';
        return Stack(
          children: [
            Card(
              elevation: 1.0,
              child: InkWell(
                onTap: (() {
                  Navigator.pushNamed(context, 'chapter_screen', arguments: {
                    'bookName': booksMap["livrosNT"]![i].name,
                    'abbrev': abbrev,
                    'bookIndex': i + 39,
                    'chapters': booksMap["livrosNT"]![i].chapters,
                  }).then((value) => setState(() {}));
                  clear();
                }),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      abbrev,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
                child: (widget.bookIsRead(booksMap["livrosNT"]![i].name))
                    ? Icon(
                  Icons.check_circle,
                  color:
                  Theme.of(context).buttonTheme.colorScheme?.secondary,
                )
                    : null),
          ],
        );
      },
    );
  }
}
