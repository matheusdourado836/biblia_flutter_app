import 'package:biblia_flutter_app/data/saved_verses_provider.dart';
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
    return Consumer<SavedVersesProvider>(
        builder: (context, value, child) {
          return Container(
            height: MediaQuery.of(context).size.height,
            color: Theme.of(context).primaryColor,
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
                      Navigator.pushNamed(context, 'chapter_screen', arguments: {'bookName': widget.listBooks[index].name, 'abbrev': widget.listBooks[index].abbrev, 'chapters': widget.listBooks[index].chapters});
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
  }
}
