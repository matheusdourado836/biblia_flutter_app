import 'package:biblia_flutter_app/data/chapters_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/data/version_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChapterCard extends StatelessWidget {
  final int chapters;
  final int bookIndex;
  final String bookName;
  final String abbrev;
  const ChapterCard({
    super.key,
    required this.chapters,
    required this.bookName,
    required this.abbrev,
    required this.bookIndex,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenOrientation = MediaQuery.of(context).orientation;
    return Consumer<ChaptersProvider>(builder: (context, value, _) {
      return GridView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(8.0),
        itemCount: chapters,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: (screenWidth > 500 && screenOrientation == Orientation.portrait) ? 100 : 90.0,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 1/1
        ),
        itemBuilder: (context, i) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadiusDirectional.circular(8)
                ),
                child: InkWell(
                  onTap: () {
                    final versionProvider = Provider.of<VersionProvider>(context, listen: false);
                    final versesProvider = Provider.of<VersesProvider>(context, listen: false);
                    versesProvider.readChapters = value.readChapters;
                    versesProvider.openBottomSheet(false);
                    versesProvider.loadVerses(bookIndex, bookName, versionName: versionProvider.selectedOption.toLowerCase().split(' ')[0]);
                    Navigator.pushNamed(
                      context,
                      'verses_screen',
                      arguments: {
                        'bookName': bookName,
                        "abbrev": abbrev,
                        "bookIndex": bookIndex,
                        "chapters": chapters,
                        "chapter": i + 1,
                        "verseNumber": 1,
                      }
                    );
                  },
                  child: Center(
                    child: Text(
                      (i + 1).toString(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
              if(value.readChapters.length == chapters && value.readChapters[i])
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).buttonTheme.colorScheme?.secondary
                )
            ],
          );
        }
      );
    },
    );
  }
}