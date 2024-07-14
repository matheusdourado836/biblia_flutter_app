import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // test('Testando se da pra trocar a cor da palavra do verso encontrado', () {
  //   const verse = 'No princípio terra criou Deus os céus e criou a terra';
  //   const query = 'terra';
  //
  //   if(verse.contains(query)) {
  //     final List<String> testeComCifrao = verse.replaceAll(query, '\$').split('\$');
  //     List<TextSpan> verseFormated = [];
  //     for(var i = 0; i < testeComCifrao.length; i++) {
  //       if(testeComCifrao[i].isEmpty ) {
  //         verseFormated.add(const TextSpan(
  //                         text: query,
  //                         style: TextStyle(
  //                             fontFamily: 'Poppins',
  //                             fontSize: 16,
  //                             fontWeight: FontWeight.bold, color: Colors.red
  //                         ),
  //                       ),
  //         );
  //       }else {
  //         verseFormated.add(TextSpan(
  //           text: testeComCifrao[i],
  //           style: const TextStyle(
  //               fontFamily: 'Poppins',
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold
  //             ),
  //           ),
  //         );
  //         if( i < testeComCifrao.length - 1 && !(i + 1 == testeComCifrao.length - 1 && testeComCifrao[i + 1].isEmpty)) {
  //           verseFormated.add(const TextSpan(
  //             text: query,
  //             style: TextStyle(
  //                 fontFamily: 'Poppins',
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.bold, color: Colors.red
  //             ),
  //           ),
  //           );
  //         }
  //       }
  //     }
  //     expect(testeComCifrao[2 + 1], equals(isEmpty));
  //   }
  //
  // });

  test('Testando função para separar o payload quando o livro vier com numerais', () {
    const payload = '2° João 2jo 62 1 1 7';

    String bookName = (payload.split(' ')[0].contains('ª') || payload.split(' ')[0].contains('º') || payload.split(' ')[0].contains('°'))
        ? '${payload.split(' ')[0]} ${payload.split(' ')[1]}'
        : payload.split(' ')[0];

    expect('2° João', bookName);
  });

  test('Testando extração de versiculos de uma String', () {
    const passage = 'João 19:12-15';
    final List<int> numeros = List.generate(100, (index) => index++);
    final verse = passage.split(':')[1];
    int start = 0;
    int end = 0;
    if(verse.contains('-')) {
      start = int.parse(verse.split('-')[0]);
      end = int.parse(verse.split('-')[1]);
    }else {
      start = int.parse(verse);
    }

    expect(numeros.sublist(start, end + 1), [12, 13, 14, 15]);

  });
}
