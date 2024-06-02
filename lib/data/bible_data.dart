import 'dart:convert';
import 'package:flutter/services.dart';

class BibleData {
  List<dynamic> _data = [];

  List<dynamic> get data => _data;

  static final BibleData _singleton = BibleData._internal();

  factory BibleData() {
    return _singleton;
  }

  BibleData._internal() {
    loadBibleData(['nvi', 'acf', 'aa', 'en_bbe', 'en_kjv', 'es_rvr', 'fr', 'el_greek']).then((value) {
      _data = value;
    });
  }

  Future<List<List<dynamic>>> loadBibleData(List<String> versions) async {
    final List<List<dynamic>> data = [];
    for (final version in versions) {
      final String response = await rootBundle.loadString('assets/json/$version.json');
      data.add(json.decode(response));
    }
    return data;
  }
}