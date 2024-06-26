import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/helpers/call_chapter_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/book.dart';

class BookCard extends StatefulWidget {
  final List<Book>? database;
  final Function bookIsRead;

  const BookCard({
    super.key,
    required this.database,
    required this.bookIsRead,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  late Map<String, List<Book>> booksMap;
  @override
  void initState() {
    booksMap = ChapterPageHelpers().formatedBookMap(widget.database!);
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
                const SizedBox(height: 60),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Novo Testamento:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                _newTestamentCards(value.clear),
                const SizedBox(height: 80),
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
          maxCrossAxisExtent: (screenSize > 500 && screenOrientation == Orientation.portrait) ? 100 : 90.0,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 1/1
        ),
        itemBuilder: (context, i) {
          String abbrevRaw = booksMap["livrosVT"]![i].abbrev;
          String abbrev = (abbrevRaw.length > 2 && abbrevRaw.length < 4) ? '${abbrevRaw.split('')[0]}${abbrevRaw.split('')[1].toUpperCase()}${abbrevRaw.substring(2)}' : '${abbrevRaw.split('')[0].toUpperCase()}${abbrevRaw.substring(1)}';
          return Stack(
            children: <Widget>[
              Card(
                elevation: 1.0,
                child: InkWell(
                  onTap: (() {
                    clear();
                    Navigator.pushNamed(context, 'chapter_screen', arguments: {
                      'bookName': booksMap["livrosVT"]![i].name,
                      'abbrev': abbrev,
                      'bookIndex': i,
                      'chapters': booksMap["livrosVT"]![i].chapters,
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
                  child: (widget.bookIsRead(booksMap["livrosVT"]![i].name))
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
        maxCrossAxisExtent: (screenSize > 500 && screenOrientation == Orientation.portrait) ? 100 : 90.0,
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
                  clear();
                  Navigator.pushNamed(context, 'chapter_screen', arguments: {
                    'bookName': booksMap["livrosNT"]![i].name,
                    'abbrev': abbrev,
                    'bookIndex': i + 39,
                    'chapters': booksMap["livrosNT"]![i].chapters,
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
