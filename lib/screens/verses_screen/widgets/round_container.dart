import 'package:flutter/material.dart';

class RoundContainer extends StatelessWidget {
  final Color color;

  const RoundContainer({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double width = 35;
    const double height = 35;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(
            Radius.circular(100),
          ),
          border: Border.all(color: Colors.black, width: 1.5)
      ),
    );
  }
}
