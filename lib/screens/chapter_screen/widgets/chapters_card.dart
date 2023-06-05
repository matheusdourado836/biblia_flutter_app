import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChapterCard extends StatelessWidget {
  final int chapters;
  final int bookIndex;
  final String bookName;
  final String abbrev;
  const ChapterCard(
      {Key? key,
      required this.chapters,
      required this.bookName,
      required this.abbrev,
      required this.bookIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final versesProvider = Provider.of<VersesProvider>(context, listen: false);
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: chapters,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 70.0,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 20.0,
      ),
      itemBuilder: (context, i) => Card(
        child: InkWell(
          onTap: (() {
            versesProvider.openBottomSheet(false);
            Navigator.pushReplacementNamed(context, 'verses_screen',
                arguments: {
                  'bookName': bookName,
                  "abbrev": abbrev,
                  "bookIndex": bookIndex,
                  "chapters": chapters,
                  "chapter": i + 1,
                  "verseNumber": 1,
                });
          }),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                (i + 1).toString(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
