import 'package:biblia_flutter_app/screens/verses_screen/verses_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Testando se da pra trocar a cor da palavra do verso encontrado', () {
    const verse = 'No princípio terra criou Deus os céus e criou a terra';
    const query = 'terra';

    if(verse.contains(query)) {
      final List<String> testeComCifrao = verse.replaceAll(query, '\$').split('\$');
      List<TextSpan> verseFormated = [];
      for(var i = 0; i < testeComCifrao.length; i++) {
        if(testeComCifrao[i].isEmpty ) {
          verseFormated.add(const TextSpan(
                          text: query,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold, color: Colors.red
                          ),
                        ),
          );
        }else {
          verseFormated.add(TextSpan(
            text: testeComCifrao[i],
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),
          );
          if( i < testeComCifrao.length - 1 && !(i + 1 == testeComCifrao.length - 1 && testeComCifrao[i + 1].isEmpty)) {
            verseFormated.add(const TextSpan(
              text: query,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold, color: Colors.red
              ),
            ),
            );
          }
        }
      }
      expect(testeComCifrao[2 + 1], equals(isEmpty));
    }

  });

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
