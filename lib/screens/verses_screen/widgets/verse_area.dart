import 'package:flutter/material.dart';
import '../../../data/verses_dao.dart';

class VerseArea extends StatefulWidget {
  final int verseNumber;
  final Color verseColor;
  final String verse;

  const VerseArea({
    Key? key,
    required this.verseNumber,
    required this.verse,
    required this.verseColor,
  }) : super(key: key);

  @override
  State<VerseArea> createState() => _VerseAreaState();
}

class _VerseAreaState extends State<VerseArea> {
  Color verseColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.verseColor,
      child: Wrap(
        children: [
          Text.rich(
            TextSpan(
              text: '${widget.verseNumber.toString()}  ',
              style: (widget.verseColor != Colors.transparent)
                  ? const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)
                  : Theme.of(context).textTheme.bodyLarge,
              children: <TextSpan>[
                (widget.verseColor != Colors.transparent)
                    ? TextSpan(
                        text: widget.verse,
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.normal))
                    : TextSpan(
                        text: widget.verse,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  updateColors(bool isSelected) {
    if (isSelected == true) {
      VersesDao().find(widget.verse).then((value) => {
            if (value.isNotEmpty) {convertColors(value[0].verseColor)}
          });
    }
  }

  convertColors(String color) {
    switch (color) {
      case 'Colors.blue[200]!':
        setState(() {
          verseColor = Colors.blue[200]!;
        });
        break;
      case 'Colors.transparent':
        setState(() {
          verseColor = Colors.transparent;
        });
        break;
      case 'Colors.yellow[200]!':
        setState(() {
          verseColor = Colors.yellow[200]!;
        });
        break;
      case 'Colors.brown[200]!':
        setState(() {
          verseColor = Colors.brown[200]!;
        });
        break;
      case 'Colors.red[200]!':
        setState(() {
          verseColor = Colors.red[200]!;
        });
        break;
      case 'Colors.orange[300]!':
        setState(() {
          verseColor = Colors.orange[300]!;
        });
        break;
      case 'Colors.green[200]!':
        setState(() {
          verseColor = Colors.green[200]!;
        });
        break;
      case 'Colors.pink[200]!':
        setState(() {
          verseColor = Colors.pink[200]!;
        });
        break;
      case 'Colors.cyan[200]!':
        setState(() {
          verseColor = Colors.cyan[200]!;
        });
        break;
    }
  }
}
