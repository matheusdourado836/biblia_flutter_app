import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color.fromRGBO(242, 231, 191, 1),
  splashColor: const Color.fromRGBO(55,143,174, 1),
  primarySwatch: Colors.brown,
  cardTheme: const CardTheme(
    color: Colors.brown,
  ),
  highlightColor: Colors.black12,
  appBarTheme: const AppBarTheme(
    iconTheme: IconThemeData(
      color: Colors.black
    ),
    elevation: 0.5,
    backgroundColor: Color.fromRGBO(191, 170, 140, 1),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 16,),
  ),
    textTheme: TextTheme(
      titleMedium: TextStyle(
        color: Colors.yellow[400]!,
      ),
        titleLarge: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16
        ),
        bodyMedium: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.normal,
        ),
        bodyLarge: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
        )
    ),
);