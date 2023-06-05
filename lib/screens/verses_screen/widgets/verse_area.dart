import 'package:biblia_flutter_app/models/annotation_model.dart';
import 'package:flutter/material.dart';
import '../../../data/bible_data_controller.dart';
import '../../../data/verses_dao.dart';

class VerseArea extends StatefulWidget {
  final int chapter;
  final int verseNumber;
  final Color verseColor;
  final String? title;
  final String verse;
  final bool verseHasAnnotation;

  const VerseArea({
    Key? key,
    required this.verseNumber,
    required this.verse,
    required this.verseColor, required this.verseHasAnnotation, required this.chapter, this.title,
  }) : super(key: key);

  @override
  State<VerseArea> createState() => _VerseAreaState();
}

class _VerseAreaState extends State<VerseArea> {
  Color verseColor = Colors.transparent;
  late AnnotationModel? annotation;

  @override
  Widget build(BuildContext context) {
    if(widget.verseHasAnnotation) {
      BibleDataController()
          .verifyAnnotationExists(widget.title!)
          .then((value) => {
            annotation = value![0]
          });
    } else {
      annotation = null;
    }
    return Container(
      color: widget.verseColor,
      padding: const EdgeInsets.all(6),
      child: Wrap(
        children: [
          Text.rich(
            TextSpan(
              text: '${widget.verseNumber.toString()}  ',
              style: (widget.verseColor != Colors.transparent)
                  ? const TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w700)
                  : Theme.of(context).textTheme.bodyLarge,
              children: <TextSpan>[
                (widget.verseColor != Colors.transparent)
                    ? TextSpan(
                        text: widget.verse,
                      )
                    : TextSpan(
                        text: widget.verse,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
              ],
            ),
          ),
          (widget.verseHasAnnotation) ? IconButton(onPressed: (() {
            Navigator.pushNamed(context, 'annotation_widget', arguments: {
              'annotation': annotation,
              'isEditing': true
            });
          }), icon: const Icon(Icons.mode_edit_outline_outlined))
            : Container()
        ],
      ),
    );
  }
}
