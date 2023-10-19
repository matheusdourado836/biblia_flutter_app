import 'package:biblia_flutter_app/data/chapters_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/book.dart';

class BookList extends StatefulWidget {
  final List<Book> listBooks;
  final Function bookIsRead;

  const BookList({Key? key, required this.listBooks, required this.bookIsRead}) : super(key: key);

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  @override
  Widget build(BuildContext context) {
    String abbrev = '';
    String bookName = '';
    return Consumer<ChaptersProvider>(
      builder: (context, chapterValue, _) {
        chapterValue.getOrderStyle();
        return Consumer<VersesProvider>(
            builder: (context, value, child) {
              if(chapterValue.orderStyle == 1) {
                return ChronologicalOrder(
                    listBooks: widget.listBooks,
                    bookIsRead: widget.bookIsRead,
                    clear: value.clear
                );
              }else if(chapterValue.orderStyle == 2) {
                return ByTheme(listBooks: widget.listBooks, bookIsRead: widget.bookIsRead, clear: value.clear);
              }
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.listBooks.length,
                  itemBuilder: (BuildContext context, int index) {
                    bookName = widget.listBooks[index].name;
                    abbrev = widget.listBooks[index].abbrev;
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: InkWell(
                        onTap: (() {
                          value.clear();
                          Navigator.pushNamed(context, 'chapter_screen', arguments: {'bookName': widget.listBooks[index].name, 'abbrev': widget.listBooks[index].abbrev, 'bookIndex': index, 'chapters': widget.listBooks[index].chapters,});
                        }),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: (index < 39) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.background,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(100),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  abbrev,
                                  style: (index < 39) ? Theme.of(context).textTheme.titleLarge : Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(bookName, style: const TextStyle(fontSize: 18),),
                            ),
                            const Spacer(),
                            SizedBox(
                              child: (widget.bookIsRead(bookName)) ? const Icon(Icons.check_rounded) : null,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            });
      },
    );
  }
}

class ChronologicalOrder extends StatefulWidget {
  final List<Book> listBooks;
  final Function bookIsRead;
  final Function clear;
  const ChronologicalOrder({super.key, required this.listBooks, required this.bookIsRead, required this.clear});

  @override
  State<ChronologicalOrder> createState() => _ChronologicalOrderState();
}

class _ChronologicalOrderState extends State<ChronologicalOrder> {
  List<Book> listBooks = [];

  @override
  void initState() {
    final indexArray = [
      0, 17, 1, 2, 3, 4, 5, 6, 7, 8, 9, 18, 10, 12, 19, 21, 20, 11, 13, 30, 28, 31, 29, 27, 32, 22, 33, 35, 23, 24, 34, 26, 25, 14, 
      16, 15, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65
    ];
    List<Book> mappedList = indexArray.map((index) => widget.listBooks[index]).toList();
    setState(() {
      listBooks = mappedList;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String abbrev = '';
    String bookName = '';
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Theme.of(context).primaryColor,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: listBooks.length,
        itemBuilder: (BuildContext context, int index) {
          bookName = listBooks[index].name;
          abbrev = listBooks[index].abbrev;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: (() {
                widget.clear();
                Navigator.pushNamed(context, 'chapter_screen', arguments: {'bookName': listBooks[index].name, 'abbrev': listBooks[index].abbrev, 'bookIndex': widget.listBooks.indexOf(listBooks[index]), 'chapters': listBooks[index].chapters,});
              }),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: (index < 39) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.background,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(100),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        abbrev,
                        style: (index < 39) ? Theme.of(context).textTheme.titleLarge : Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(bookName, style: const TextStyle(fontSize: 18),),
                  ),
                  const Spacer(),
                  SizedBox(
                    child: (widget.bookIsRead(bookName)) ? const Icon(Icons.check_rounded) : null,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ByTheme extends StatelessWidget {
  final List<Book> listBooks;
  final Function bookIsRead;
  final Function clear;
  const ByTheme({super.key, required this.listBooks, required this.bookIsRead, required this.clear});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            child: Text('Velho Testamento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
          ),
        ),
        const BookSection(section: 'Pentateuco'),
        BookItens(listBooks: listBooks, qtdBooks: 5, bookIndex: 0, clear: clear, bookIsRead: bookIsRead),
        const BookSection(section: 'Livros Históricos'),
        BookItens(listBooks: listBooks, qtdBooks: 12, bookIndex: 5, clear: clear, bookIsRead: bookIsRead),
        const BookSection(section: 'Livros Poéticos'),
        BookItens(listBooks: listBooks, qtdBooks: 5, bookIndex: 17, clear: clear, bookIsRead: bookIsRead),
        const BookSection(section: 'Profetas Maiores'),
        BookItens(listBooks: listBooks, qtdBooks: 5, bookIndex: 22, clear: clear, bookIsRead: bookIsRead),
        const BookSection(section: 'Profetas Menores'),
        BookItens(listBooks: listBooks, qtdBooks: 12, bookIndex: 27, clear: clear, bookIsRead: bookIsRead),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            child: Text('Novo Testamento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
          ),
        ),
        const BookSection(section: 'Evangelhos'),
        BookItens(listBooks: listBooks, qtdBooks: 4, bookIndex: 39, clear: clear, bookIsRead: bookIsRead),
        const BookSection(section: 'Históricos'),
        BookItens(listBooks: listBooks, qtdBooks: 1, bookIndex: 43, clear: clear, bookIsRead: bookIsRead),
        const BookSection(section: 'Cartas'),
        BookItens(listBooks: listBooks, qtdBooks: 21, bookIndex: 44, clear: clear, bookIsRead: bookIsRead),
        const BookSection(section: 'Revelação'),
        BookItens(listBooks: listBooks, qtdBooks: 1, bookIndex: 65, clear: clear, bookIsRead: bookIsRead),
      ],
    );
  }
}

class BookSection extends StatelessWidget {
  final String section;
  const BookSection({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(section, style: Theme.of(context).textTheme.bodyLarge,),
      ),
    );
  }
}


class BookItens extends StatelessWidget {
  final List<Book> listBooks;
  final int qtdBooks;
  final int bookIndex;
  final Function clear;
  final Function bookIsRead;
  const BookItens({super.key, required this.listBooks, required this.qtdBooks, required this.clear, required this.bookIsRead, required this.bookIndex});

  @override
  Widget build(BuildContext context) {
    String abbrev = '';
    String bookName = '';
    return SliverList.builder(itemCount: qtdBooks, itemBuilder: (context, index) {
      bookName = listBooks[index + bookIndex].name;
      abbrev = listBooks[index + bookIndex].abbrev;
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: InkWell(
          onTap: (() {
            clear();
            Navigator.pushNamed(context, 'chapter_screen', arguments: {'bookName': listBooks[index + bookIndex].name, 'abbrev': listBooks[index + bookIndex].abbrev, 'bookIndex': index + bookIndex, 'chapters': listBooks[index + bookIndex].chapters,});
          }),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (bookIndex < 29) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(100),
                  ),
                ),
                child: Center(
                  child: Text(
                    abbrev,
                    style: (bookIndex < 29) ? Theme.of(context).textTheme.titleLarge : Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(bookName, style: const TextStyle(fontSize: 18),),
              ),
              const Spacer(),
              SizedBox(
                child: (bookIsRead(bookName)) ? const Icon(Icons.check_rounded) : null,
              )
            ],
          ),
        ),
      );
    });
  }
}


