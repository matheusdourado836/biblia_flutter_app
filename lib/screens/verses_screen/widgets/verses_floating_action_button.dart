import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VersesFloatingActionButton extends StatefulWidget {
  final bool notScrolling;
  final int chapter;
  final int chapters;
  final PageController pageController;
  const VersesFloatingActionButton({Key? key, required this.notScrolling, required this.chapter, required this.chapters, required this.pageController}) : super(key: key);

  @override
  State<VersesFloatingActionButton> createState() => _VersesFloatingActionButtonState();
}

class _VersesFloatingActionButtonState extends State<VersesFloatingActionButton> {
  final versesProvider = Provider.of<VersesProvider>(navigatorKey!.currentContext!, listen: false);
  int _chapter = 0;
  int _chapters = 0;
  @override
  void initState() {
    _chapter = widget.chapter;
    _chapters = widget.chapters;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height:
      (widget.notScrolling && versesProvider.versesSelected == false)
          ? 56
          : 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _prevPageButton(),
          _nextPageButton(),
        ],
      ),
    );
  }

  Widget _nextPageButton() {
    return FloatingActionButton(
      heroTag: 'btn2',
      backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
      onPressed: (() {
        (widget.notScrolling &&
            versesProvider.versesSelected == false)
            ? setState(() {
          if (_chapter < _chapters) {
            _chapter++;
            widget.pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.linear);
          }
        })
            : null;
      }),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        size: (widget.notScrolling &&
            versesProvider.versesSelected == false)
            ? 22
            : 0,
        color:
        Theme.of(context).buttonTheme.colorScheme?.onSurface,
      ),
    );
  }

  Widget _prevPageButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 28.0),
      child: FloatingActionButton(
        heroTag: 'btn1',
        backgroundColor:
        Theme.of(context).buttonTheme.colorScheme?.secondary,
        onPressed: (() {
          (widget.notScrolling &&
              versesProvider.versesSelected == false)
              ? setState(() {
            if (_chapter > 1) {
              _chapter--;
              widget.pageController.previousPage(
                  duration:
                  const Duration(milliseconds: 500),
                  curve: Curves.linear);
            }
          })
              : null;
        }),
        child: Icon(
          Icons.arrow_back_ios_rounded,
          size: (widget.notScrolling &&
              versesProvider.versesSelected == false)
              ? 22
              : 0,
          color: Theme.of(context)
              .buttonTheme
              .colorScheme
              ?.onSurface,
        ),
      ),
    );
  }
}
