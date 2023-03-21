import 'package:biblia_flutter_app/helpers/go_to_verse_screen.dart';
import 'package:flutter/material.dart';

class ChapterCard extends StatelessWidget {
  final int chapters;
  final String bookName;
  final String abbrev;
  const ChapterCard({Key? key, required this.chapters, required this.bookName, required this.abbrev}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            GoToVerseScreen().goToVersePage(bookName, abbrev, chapters, i + 1, 1);
          }),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text((i + 1).toString(), style: Theme.of(context).textTheme.titleMedium,),
            ),
          ),
        ),
      ),
    );
  }
}
