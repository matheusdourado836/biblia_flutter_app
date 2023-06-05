import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black,
  cardTheme: const CardTheme(
    color: Color.fromRGBO(51, 41, 64, 1)
  ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      textStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600
      ),
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
    titleLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16
    ),
    titleMedium: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
      color: Color.fromRGBO(255, 255, 255, 0.85),
    ),
    displayLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 24
    ),
    displayMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20
    ),
    bodyMedium: TextStyle(
        fontFamily: 'Poppins',
        color: Color.fromRGBO(255, 255, 255, 0.85),
        fontSize: 16,
        fontWeight: FontWeight.w500
    ),
    bodyLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.bold
    ),
  )
);