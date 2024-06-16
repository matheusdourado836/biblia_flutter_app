import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color.fromRGBO(242, 231, 191, 1),
  splashColor: Colors.transparent,
  primarySwatch: Colors.brown,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: Colors.brown,
    onPrimary: Colors.yellow[400]!,
    secondary: const Color.fromRGBO(191, 170, 140, 1),
    onSecondary: Colors.black,
    tertiary: const Color.fromRGBO(242, 231, 191, 1),
    error: Colors.red,
    onError: Colors.white,
    background: Colors.white,
    onBackground: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black),
  cardTheme: const CardTheme(
    color: Colors.brown,
  ),
  dropdownMenuTheme: const DropdownMenuThemeData(
    textStyle: TextStyle(
        color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
  ),
  highlightColor: Colors.black12,
  appBarTheme: const AppBarTheme(
    iconTheme: IconThemeData(color: Colors.black),
    elevation: 0.5,
    backgroundColor: Color.fromRGBO(191, 170, 140, 1),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: Colors.black)),
  listTileTheme: const ListTileThemeData(iconColor: Colors.brown),
  textTheme: TextTheme(
      titleLarge: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      titleMedium: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
        color: Colors.yellow[400]!,
      ),
      displayLarge: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
      displayMedium: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      bodyMedium: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500),
      bodyLarge: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      )),
);
