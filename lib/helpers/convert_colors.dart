import 'package:biblia_flutter_app/themes/theme_colors.dart';
import 'package:flutter/material.dart';

class ConvertColors {
  Color? convertColors(String color) {
    Color newColor = Colors.transparent;
    if (color == 'Colors.transparent') {
      newColor = Colors.transparent;
    } else if (color == ThemeColors.colorString2) {
      newColor = ThemeColors.color2;
    } else if (color == ThemeColors.colorString3) {
      newColor = ThemeColors.color3;
    } else if (color == ThemeColors.colorString4) {
      newColor = ThemeColors.color4;
    } else if (color == ThemeColors.colorString5) {
      newColor = ThemeColors.color5;
    } else if (color == ThemeColors.colorString6) {
      newColor = ThemeColors.color6;
    } else if (color == ThemeColors.colorString7) {
      newColor = ThemeColors.color7;
    } else if (color == ThemeColors.colorString8) {
      newColor = ThemeColors.color8;
    } else if (color == ThemeColors.colorString1) {
      newColor = ThemeColors.color1;
    }

    return newColor;
  }

  String convertColorsToText(String color) {
    String newColor = '';
    if (color == ThemeColors.colorString2) {
      newColor = 'azul';
    } else if (color == ThemeColors.colorString3) {
      newColor = 'amarelo';
    } else if (color == ThemeColors.colorString4) {
      newColor = 'marrom';
    } else if (color == ThemeColors.colorString5) {
      newColor = 'vermelho';
    } else if (color == ThemeColors.colorString6) {
      newColor = 'laranja';
    } else if (color == ThemeColors.colorString7) {
      newColor = 'verde';
    } else if (color == ThemeColors.colorString8) {
      newColor = 'rosa';
    } else if (color == ThemeColors.colorString1) {
      newColor = 'ciano';
    }

    return newColor;
  }
}