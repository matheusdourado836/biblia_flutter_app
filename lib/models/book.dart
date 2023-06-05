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
