import 'package:biblia_flutter_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/verses_provider.dart';

class ThemeColors {
  static Color color1 = Colors.cyan[200]!;
  static Color color2 = Colors.blue[200]!;
  static Color color3 = Colors.amber[200]!;
  static Color color4 = Colors.brown[200]!;
  static Color color5 = Colors.red[200]!;
  static Color color6 = Colors.orange[300]!;
  static Color color7 = Colors.green[200]!;
  static Color color8 = Colors.pink[200]!;

  static String colorString1 = 'Colors.cyan[200]!';
  static String colorString2 = 'Colors.blue[200]!';
  static String colorString3 = 'Colors.amber[200]!';
  static String colorString4 = 'Colors.brown[200]!';
  static String colorString5 = 'Colors.red[200]!';
  static String colorString6 = 'Colors.orange[300]!';
  static String colorString7 = 'Colors.green[200]!';
  static String colorString8 = 'Colors.pink[200]!';

  final fontSize = Provider.of<VersesProvider>(navigatorKey!.currentContext!, listen: false).fontSize;

  TextStyle verseColor(bool isLightMode) {
    if(isLightMode) {
      return TextStyle(
          fontFamily: 'Poppins',
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: FontWeight.w500
      );
    }

    return TextStyle(
        fontFamily: 'Poppins',
        color: const Color.fromRGBO(255, 255, 255, 0.85),
        fontSize: fontSize,
        fontWeight: FontWeight.w500
    );
  }

  TextStyle coloredVerse(bool isLightMode) {
    if(isLightMode) {
      return TextStyle(
          fontFamily: 'Poppins',
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: FontWeight.bold
      );
    }

    return TextStyle(
        fontFamily: 'Poppins',
        color: const Color.fromRGBO(255, 255, 255, 0.85),
        fontSize: fontSize,
        fontWeight: FontWeight.bold
    );
  }

  TextStyle verseNumberColor(bool isLightMode)  {
    if(isLightMode) {
      return TextStyle(
          fontFamily: 'Poppins',
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: FontWeight.bold
      );
    }

    return TextStyle(
        fontFamily: 'Poppins',
        color: const Color.fromRGBO(255, 255, 255, 0.85),
        fontSize: fontSize,
        fontWeight: FontWeight.bold
    );
  }
}