class Chapter {
  int verseNumber;
  String verse;

  Chapter({required this.verseNumber, required this.verse});

  Chapter.fromMap(Map<String, dynamic> map)
        :verseNumber = map["number"],
        verse = map["text"];

  Map<String, dynamic> toMap() {
    return {"number": verseNumber, "text": verse};
  }

  @override
  String toString() {
    return "verseNumber: $verseNumber\nverse: $verse";
  }
}