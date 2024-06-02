import 'package:flutter/material.dart';

TextAlign intToTextAlign(int value) {
  if(value == 0) {
    return TextAlign.start;
  }else if(value == 1) {
    return TextAlign.center;
  }else {
    return TextAlign.end;
  }
}