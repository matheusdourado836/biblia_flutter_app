import 'package:biblia_flutter_app/data/bible_data.dart';
import 'package:biblia_flutter_app/data/theme_provider.dart';
import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'verse_dialog.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.text,
    required this.isFromUser,
    required this.timestamp
  });

  final String text;
  final bool isFromUser;
  final int? timestamp;

  Widget _buildFormattedText(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final darkMode = !themeProvider.isOn;
    final List<InlineSpan> children = [];
    final RegExp regExp = RegExp(r'\*\s*\*\*(.*?)\*\*');

    int start = 0;

    regExp.allMatches(text).forEach((match) {
      final String plainText = text.substring(start, match.start);
      final String boldText = match.group(1)!;
      children.add(TextSpan(text: plainText));
      children.add(TextSpan(
        text: '\n$boldText'.trimRight(),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ));
      start = match.end;
    });

    if (start < text.length) {
      children.add(TextSpan(text: text.substring(start)));
    }

    return Text.rich(
      textWidthBasis: TextWidthBasis.longestLine,
      TextSpan(
        style: TextStyle(
          fontFamily: 'Poppins',
          color: isFromUser ? Colors.white : (darkMode) ? const Color.fromRGBO(255, 255, 255, 0.85) : Colors.black,
          fontSize: 16,
          height: 1.4
        ),
        children: children,
      ),
    );
  }

  Widget _timestampWidget(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final darkMode = !themeProvider.isOn;
    return Text(
      DateTime.fromMillisecondsSinceEpoch(timestamp ?? 0).formattedShort(),
      style: TextStyle(
        fontSize: 10,
        color: isFromUser ? Colors.white70 : (darkMode) ? Colors.white70 : Colors.black54,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final RegExp passageRegExp = RegExp(r'~(.*?)~');
    final passageMatches = passageRegExp
        .allMatches(text)
        .expand((match) => match.group(1)!.split(';'))
        .map((e) => e.trim())
        .map((passage) {
          if (!RegExp(r'\d+:\d+').hasMatch(passage)) {
            final parts = passage.split(RegExp(r'\s+'));
            if (parts.length > 1 && RegExp(r'^\d+$').hasMatch(parts.last)) {
              parts.last += ':1';
              return parts.join(' ');
            }
          }
          return passage;
        })
        .where((passage) => RegExp(r'\d+:\d+').hasMatch(passage))
        .toSet()
        .toList();
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth >= 500 ? 600 : 300),
            decoration: BoxDecoration(
              color: isFromUser
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildFormattedText(context),
                _timestampWidget(context)
              ],
            ),
          ),
          if (passageMatches.isNotEmpty)
            Container(
              width: constraints.maxWidth,
              height: 50,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: passageMatches.length,
                itemBuilder: (context, idx) {
                  final passage = passageMatches[idx];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final List<dynamic> list = BibleData().data[0]["text"];
                        String bookName = (passage.split(' ')[0].contains('ª') || passage.split(' ')[0].contains('º') || passage.split(' ')[0].contains('°') || RegExp(r'^\d+$').hasMatch(passage.split(' ')[0]))
                            ? '${passage.split(' ')[0]} ${passage.split(' ')[1]}'
                            : passage.split(' ')[0];
                        int chapter = (passage.split(' ')[0].contains('ª') || passage.split(' ')[0].contains('º') || passage.split(' ')[0].contains('°') || RegExp(r'^\d+$').hasMatch(passage.split(' ')[0]))
                            ? int.parse(passage.split(' ')[2].split(':')[0])
                            : int.parse(passage.split(' ')[1].split(':')[0]);
                        String verse = passage.split(':')[1];
                        int start = 0;
                        int end = 0;
                        if(verse.contains('-')) {
                          start = int.parse(verse.split('-')[0]);
                          end = int.parse(verse.split('-')[1]);
                        }else {
                          start = int.parse(verse);
                          end = start;
                        }
                        final bookInfo = list.where((element) => element['name'] == bookName).toList();
                        final sublist = bookInfo[0]["chapters"][chapter - 1].sublist(start - 1, end);
                        showDialog(
                            context: context,
                            useRootNavigator: false,
                            builder: (BuildContext context) {
                              return VerseDialog(
                                width: constraints.maxWidth * .6,
                                height: constraints.maxWidth >= 500 ? 350 : 200,
                                bookName: bookName,
                                chapter: chapter,
                                verse: (end == start) ? '$start' : '$start-$end',
                                verses: sublist.toList(),
                              );
                            });
                      },
                      child: Text(passage),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    });
  }
}
