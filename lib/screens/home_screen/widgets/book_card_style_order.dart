import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/verses_provider.dart';
import '../../../helpers/call_chapter_page.dart';
import '../../../models/book.dart';

class BookCardStyleOrder extends StatefulWidget {
  final List<Book>? database;
  final Function bookIsRead;
  const BookCardStyleOrder({super.key, this.database, required this.bookIsRead});

  @override
  State<BookCardStyleOrder> createState() => _BookCardStyleOrderState();
}

class _BookCardStyleOrderState extends State<BookCardStyleOrder> {
  late Map<String, List<Book>> booksMap;
  @override
  void initState() {
    booksMap = ChapterPageHelpers().formatedBookMap(widget.database!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VersesProvider>(
      builder: (context, value, child) {
        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BooksSection(cards: _oldTestamentCards(value.clear, 5, 0), section: 'Pentateuco'),
                BooksSection(cards: _oldTestamentCards(value.clear, 12, 5), section: 'Livros Históricos'),
                BooksSection(cards: _oldTestamentCards(value.clear, 5, 17), section: 'Livros Poéticos'),
                BooksSection(cards: _oldTestamentCards(value.clear, 5, 22), section: 'Profetas Maiores'),
                BooksSection(cards: _oldTestamentCards(value.clear, 12, 27), section: 'Profetas Menores'),
                const SizedBox(height: 36,),
                BooksSection(cards: _newTestamentCards(value.clear, 4, 0), section: 'Evangelhos'),
                BooksSection(cards: _newTestamentCards(value.clear, 1, 4), section: 'Históricos'),
                BooksSection(cards: _newTestamentCards(value.clear, 21, 5), section: 'Cartas'),
                BooksSection(cards: _newTestamentCards(value.clear, 1, 26), section: 'Revelação'),
                const SizedBox(height: 48,),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _oldTestamentCards(Function clear, int qtdItens, int startIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: qtdItens,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 70.0,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 20.0,
          ),
          itemBuilder: (context, i) {
            return Stack(
              children: <Widget>[
                Card(
                  elevation: 1.0,
                  child: InkWell(
                    onTap: (() {
                      clear();
                      Navigator.pushNamed(context, 'chapter_screen', arguments: {
                        'bookName': booksMap["livrosVT"]![i + startIndex].name,
                        'abbrev': booksMap["livrosVT"]![i + startIndex].abbrev,
                        'bookIndex': i + startIndex,
                        'chapters': booksMap["livrosVT"]![i + startIndex].chapters,
                      }).then((value) => setState(() {}));
                    }),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          booksMap["livrosVT"]![i + startIndex].abbrev,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    child: (widget.bookIsRead(booksMap["livrosVT"]![i + startIndex].name))
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
          }),
    );
  }

  Widget _newTestamentCards(Function clear, int qtdItens, int startIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: qtdItens,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 70.0,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 20.0,
        ),
        itemBuilder: (context, i) => Stack(
          children: [
            Card(
              elevation: 1.0,
              child: InkWell(
                onTap: (() {
                  Navigator.pushNamed(context, 'chapter_screen', arguments: {
                    'bookName': booksMap["livrosNT"]![i + startIndex].name,
                    'abbrev': booksMap["livrosNT"]![i + startIndex].abbrev,
                    'bookIndex': i + startIndex + 39,
                    'chapters': booksMap["livrosNT"]![i + startIndex].chapters,
                  }).then((value) => setState(() {}));
                  clear();
                }),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      booksMap["livrosNT"]![i + startIndex].abbrev,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
                child: (widget.bookIsRead(booksMap["livrosNT"]![i + startIndex].name))
                    ? Icon(
                  Icons.check_circle,
                  color:
                  Theme.of(context).buttonTheme.colorScheme?.secondary,
                )
                    : null),
          ],
        ),
      ),
    );
  }
}

class BooksSection extends StatelessWidget {
  final String section;
  final Widget cards;
  const BooksSection({super.key, required this.cards, required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            '$section:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        cards,
      ],
    );
  }
}

