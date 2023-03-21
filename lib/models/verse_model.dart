class VerseModel {
  String verse;
  String verseColor;
  String book;
  int chapter;
  int verseNumber;

  VerseModel({required this.verse, required this.verseColor, required this.book, required this.chapter, required this.verseNumber});

  @override
  String toString() {
    return "verse: $verse\nverseColor: $verseColor\nbook: $book\nchapter: $chapter\nverseNumber: $verseNumber";
  }
}