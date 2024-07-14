import 'package:flutter/material.dart';

class TabItem extends StatelessWidget {
  final String title;
  final int count;
  const TabItem({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12),),
          count > 0
            ? Container(
            width: 25,
            height: 25,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(50)
            ),
            child: Text(
              count > 100 ? '100+' : count.toString(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 10
              ),
            ),
          )
           : const SizedBox()
        ],
      ),
    );
  }
}
