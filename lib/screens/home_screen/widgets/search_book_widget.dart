import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/book.dart';

class SearchBookWidget extends StatelessWidget {
  final List<Book> books;
  const SearchBookWidget({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: books.length,
      itemBuilder: (context, index) {
        final screenOrientation = MediaQuery.of(context).orientation;
        final screenSize = MediaQuery.of(context).size.width;
        final bool condition1 = screenSize > 500 && screenOrientation == Orientation.portrait;
        final bool condition2 = screenSize > 500 && screenOrientation == Orientation.landscape;
        final bookName = books[index].name;
        final abbrevRaw = books[index].abbrev;
        final abbrev = (abbrevRaw.length > 2 && abbrevRaw.length < 4) ? '${abbrevRaw.split('')[0]}${abbrevRaw.split('')[1].toUpperCase()}${abbrevRaw.substring(2)}' : '${abbrevRaw.split('')[0].toUpperCase()}${abbrevRaw.substring(1)}';
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 8, top: 16),
          child: InkWell(
            onTap: (() {
              final versesProvider = Provider.of<VersesProvider>(context, listen: false);
              versesProvider.clear();
              Navigator.pushNamed(context, 'chapter_screen', arguments: {'bookName': bookName, 'abbrev': abbrev, 'bookIndex': index, 'chapters': books[index].chapters,});
            }),
            child: Row(
              children: [
                Container(
                  width: (condition1 || condition2) ? 80 : 55,
                  height: (condition1 || condition2) ? 80 : 55,
                  decoration: BoxDecoration(
                    color: (index < 39) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(100),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    abbrev,
                    style: (index < 39) ? Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 18) : Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(bookName, style: const TextStyle(fontSize: 18),),
                ),
              ],
            ),
          ),
        );
      });
  }
}
