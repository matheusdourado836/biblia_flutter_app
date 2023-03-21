import 'package:flutter/material.dart';

class RoundContainer extends StatefulWidget {
  final Color color;

  const RoundContainer({Key? key, required this.color}) : super(key: key);

  @override
  State<RoundContainer> createState() => _RoundContainerState();
}

class _RoundContainerState extends State<RoundContainer> {
  @override
  Widget build(BuildContext context) {
    const double width = 35;
    const double height = 35;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: const BorderRadius.all(
          Radius.circular(100),
        ),
      ),
    );
  }
}

