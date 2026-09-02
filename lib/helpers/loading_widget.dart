import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Color? bgColor;
  final Color? txtColor;
  const LoadingWidget({super.key, this.bgColor, this.txtColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(color: bgColor),
          ),
          Text('Carregando', style: TextStyle(color: txtColor))
        ],
      ),
    );
  }
}
