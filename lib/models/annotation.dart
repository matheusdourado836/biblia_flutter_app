class Annotation {
  String annotationId;
  String title;
  String content;
  String book;
  int chapter;
  int verseStart;
  int? verseEnd;
  String? style;

  Annotation({required this.annotationId, required this.title, required this.content, required this.book, required this.chapter, required this.verseStart, this.verseEnd, this.style});

  @override
  String toString() {
    return "title: $title\ncontent: $content\nbook: $book\nchapter: $chapter\nverseStart: $verseStart\nverseEnd: $verseEnd";
  }
}