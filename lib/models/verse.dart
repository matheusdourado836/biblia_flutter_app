class VerseModel {
  String verse;
  String verseColor;
  String book;
  int version;
  int chapter;
  int verseNumber;

  VerseModel({required this.verse, required this.verseColor, required this.book, required this.version, required this.chapter, required this.verseNumber});

  @override
  String toString() {
    return "verse: $verse\nverseColor: $verseColor\nbook: $book\nchapter: $version\nversion: $chapter\nverseNumber: $verseNumber";
  }
}