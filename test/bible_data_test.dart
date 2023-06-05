import 'package:biblia_flutter_app/screens/verses_screen/verses_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('verses should load before page loads', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: VersesScreen(
        chapter: 1,
        verseNumber: 1,
        bookName: 'Gênesis',
        abbrev: 'Gn',
        chapters: 31,
        bookIndex: 1,
      ),
    ));
    final finder = find.text('No princípio criou Deus os céus e a terra');
    expect(finder, findsOneWidget);
  });
}
