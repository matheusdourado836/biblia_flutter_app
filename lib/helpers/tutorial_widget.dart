import 'package:flutter/material.dart';

class TutorialWidget extends StatefulWidget {
  final String text;
  final String skip;
  final String next;
  final void Function()? onSkip;
  final void Function()? onNext;
  const TutorialWidget({super.key, required this.text, required this.skip, required this.next, this.onSkip, this.onNext});

  @override
  State<TutorialWidget> createState() => _TutorialWidgetState();
}

class _TutorialWidgetState extends State<TutorialWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.text, style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: widget.onSkip, child: Text(widget.skip, style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 18))),
              const SizedBox(width: 16),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: widget.onNext,
                  child: Text(widget.next)
              )
            ],
          )
        ],
      ),
    );
  }
}
