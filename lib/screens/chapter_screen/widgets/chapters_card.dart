import 'package:biblia_flutter_app/data/chapters_provider.dart';
import 'package:biblia_flutter_app/screens/chapter_screen/chapter_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChapterCard extends StatefulWidget {
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
  State<ChapterCard> createState() => _ChapterCardState();
}

class _ChapterCardState extends State<ChapterCard> {
  @override
  void initState() {
    final chaptersProvider = Provider.of<ChaptersProvider>(context, listen: false);
    chaptersProvider.setChaptersRead(widget.bookName, widget.chapters);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ChaptersProvider>(builder: (context, value, _) {
      return GridView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.chapters,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 80.0,
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 1/1
          ),
          itemBuilder: (context, i) {
            return Stack(
              children: [
                Card(
                  child: InkWell(
                    onTap: (() {
                      versesProvider.openBottomSheet(false);
                      Navigator.pushReplacementNamed(context, 'verses_screen',
                          arguments: {
                            'bookName': widget.bookName,
                            "abbrev": widget.abbrev,
                            "bookIndex": widget.bookIndex,
                            "chapters": widget.chapters,
                            "chapter": i + 1,
                            "verseNumber": 1,
                          });
                    }),
                    child: Center(
                      child: Text(
                        (i + 1).toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    child: (value.readChapters[i])
                        ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context)
                          .buttonTheme
                          .colorScheme
                          ?.background,)
                        : null),
              ],
            );
          }
      );
    },);
  }
}
