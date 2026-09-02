import 'chapter.dart';

class BookFull {
  int? bookIndex;
  String? name;
  String? abbrev;
  List<Chapter>? chapters;
  int? chapter;
  int? verseNumber;

  BookFull({
    this.bookIndex,
    this.name,
    this.abbrev,
    this.chapters,
    this.chapter,
    this.verseNumber
  });

  factory BookFull.fromMap(Map<String, dynamic> map) {
    return BookFull(
      name: map["name"],
      abbrev: map["abbrev"],
      chapters: (map['chapters'] as List)
          .map((chapter) => Chapter.fromJson(chapter))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'abbrev': abbrev,
      'chapters': chapters?.map((chapter) => chapter.toJson()).toList(),
      'bookIndex': bookIndex,
      'chapter': chapter,
      'verseNumber': verseNumber
    };
  }
}

class Book {
  String name;
  String abbrev;
  String testament;
  int chapters;

  Book(
      {required this.abbrev,
      required this.name,
      required this.testament,
      required this.chapters});

  Book.fromMap(Map<String, dynamic> map)
      : abbrev = map["abbrev"]["pt"],
        name = map["name"],
        testament = map["testament"],
        chapters = map["chapters"];

  Map<String, dynamic> toMap(List<String> books) {
    return {
      "abbrev": abbrev,
      "name": name,
      "testament": testament,
      "chapters": chapters
    };
  }

  @override
  String toString() {
    return "name: $name\nabbrev: $abbrev\ntestament: $testament\nchapters: $chapters";
  }
}
