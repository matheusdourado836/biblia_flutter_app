import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black,
  cardTheme: const CardTheme(
    color: Color.fromRGBO(51, 41, 64, 1)
  ),
  highlightColor: const Color.fromRGBO(89, 89, 89, 1.0),
  appBarTheme: const AppBarTheme(
    elevation: 0.5,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,),
  ),
  textTheme: const TextTheme(
    titleMedium: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 0.85),
      fontWeight: FontWeight.bold
    ),
    titleLarge: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16
    ),
    bodyMedium: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.85),
        fontSize: 20,
        fontWeight: FontWeight.normal,
    ),
    bodyLarge: TextStyle(
      //fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.bold
    ),
  )
);