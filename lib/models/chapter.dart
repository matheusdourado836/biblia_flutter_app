import 'package:biblia_flutter_app/models/annotation.dart';
import 'package:flutter/material.dart';

class Chapter {
  int? chapterNumber;
  final List<Verse> verses;

  Chapter({this.chapterNumber, required this.verses});

  factory Chapter.fromJson(List<dynamic> json) {
    return Chapter(
      verses: json.map((verse) => Verse.fromJson(verse)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verses': verses,
    };
  }
}

class Verse {
  String? text;
  String? verseDefault;
  Color? verseColor;
  String? bookName;
  String? version;
  int? chapter;
  int? verseNumber;
  bool? isSelected;
  bool? isEditing;
  Annotation? annotation;

  Verse({
    this.text,
    this.verseDefault,
    this.verseColor,
    this.bookName,
    this.version,
    this.chapter,
    this.verseNumber,
    this.isSelected,
    this.isEditing,
    this.annotation,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      text: json['verse'],
      verseDefault: json['verseDefault'],
      verseColor: json['verseColor'],
      bookName: json['bookName'],
      version: json['version'],
      chapter: json['chapter'],
      verseNumber: json['verseNumber'],
      isSelected: json['isSelected'],
      isEditing: json['isEditing'],
      annotation: json['annotation'],
    );
  }

}