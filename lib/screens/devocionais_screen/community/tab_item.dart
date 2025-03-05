import 'package:flutter/material.dart';

class TabItem extends StatelessWidget {
  final String title;
  final int count;
  const TabItem({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Badge.count(
        count: count,
        offset: const Offset(20, 3),
        child: Text(title),
      ),
    );
  }
}
