import 'package:biblia_flutter_app/data/saved_verses_provider.dart';
import 'package:biblia_flutter_app/helpers/call_chapter_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/book.dart';

class ListBooks extends StatefulWidget {
  final List<Book>? database;
  final Function bookIsRead;

  const ListBooks({
    Key? key,
    required this.database,
    required this.bookIsRead,
  }) : super(key: key);

  @override
  State<ListBooks> createState() => _ListBooksState();
}

class _ListBooksState extends State<ListBooks> {
  @override
  Widget build(BuildContext context) {
    Map<String, List<Book>> booksMap =
        ChapterPageHelpers().formatedBookMap(widget.database!);

    setState(() {
      widget.database;
    });
    return Consumer<SavedVersesProvider>(
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
                GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 39,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 70.0,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 20.0,
                    ),
                    itemBuilder: (context, i) {
                      return Stack(
                        children: <Widget>[
                          Card(
                            elevation: 1.0,
                            child: InkWell(
                              onTap: (() {
                                Navigator.pushNamed(context, 'chapter_screen',
                                    arguments: {
                                      'bookName': booksMap["livrosVT"]![i].name,
                                      'abbrev': booksMap["livrosVT"]![i].abbrev,
                                      'chapters': booksMap["livrosVT"]![i].chapters,
                                    }).then((value) => setState(() {}));
                              }),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    booksMap["livrosVT"]![i].abbrev,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              child:
                              (widget.bookIsRead(booksMap["livrosVT"]![i].name))
                                  ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context)
                                    .buttonTheme
                                    .colorScheme
                                    ?.background,
                              )
                                  : null),
                        ],
                      );
                    }),
                const SizedBox(
                  height: 60,
                ),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Novo Testamento:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 27,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 70.0,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 20.0,
                  ),
                  itemBuilder: (context, i) => Stack(
                    children: [
                      Card(
                        elevation: 1.0,
                        child: InkWell(
                          onTap: (() {
                            Navigator.pushNamed(context, 'chapter_screen',
                                arguments: {
                                  'bookName': booksMap["livrosNT"]![i].name,
                                  'abbrev': booksMap["livrosNT"]![i].abbrev,
                                  'chapters': booksMap["livrosNT"]![i].chapters,
                                }).then((value) => setState(() {}));
                          }),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                booksMap["livrosNT"]![i].abbrev,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          child: (widget.bookIsRead(booksMap["livrosNT"]![i].name))
                              ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context)
                                .buttonTheme
                                .colorScheme
                                ?.background,
                          )
                              : null),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 80,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
