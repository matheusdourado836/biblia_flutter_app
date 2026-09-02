import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ThematicSkeleton extends StatelessWidget {
  const ThematicSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Shimmer.fromColors(
          baseColor: Colors.grey,
          highlightColor: Colors.white,
          child: Container(color: Colors.grey)
      ),
    );
  }
}
