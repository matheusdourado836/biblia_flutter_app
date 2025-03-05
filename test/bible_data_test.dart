import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  int totalCapitulos = 1265;
  int totalDias = 365;

  List<List<int>> planoLeitura = dividirPlanoLeitura(
    totalCapitulos: totalCapitulos,
    totalDias: totalDias,
  );

  // Exibir os capítulos para cada dia
  for (int i = 0; i < planoLeitura.length; i++) {
    print("Dia ${i + 1}: ${planoLeitura[i]}");
  }

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

  // test('Testando função para separar o payload quando o livro vier com numerais', () {
  //   const payload = '2° João 2jo 62 1 1 7';
  //
  //   String bookName = (payload.split(' ')[0].contains('ª') || payload.split(' ')[0].contains('º') || payload.split(' ')[0].contains('°'))
  //       ? '${payload.split(' ')[0]} ${payload.split(' ')[1]}'
  //       : payload.split(' ')[0];
  //
  //   expect('2° João', bookName);
  // });
  //
  // test('Testando extração de versiculos de uma String', () {
  //   const passage = 'João 19:12-15';
  //   final List<int> numeros = List.generate(100, (index) => index++);
  //   final verse = passage.split(':')[1];
  //   int start = 0;
  //   int end = 0;
  //   if(verse.contains('-')) {
  //     start = int.parse(verse.split('-')[0]);
  //     end = int.parse(verse.split('-')[1]);
  //   }else {
  //     start = int.parse(verse);
  //   }
  //
  //   expect(numeros.sublist(start, end + 1), [12, 13, 14, 15]);
  //
  // });
}

List<List<int>> dividirPlanoLeitura({
  required int totalCapitulos,
  required int totalDias,
}) {
  // Quantidade base de capítulos por dia
  int capitulosPorDia = totalCapitulos ~/ totalDias;

  // Quantidade de capítulos que restam após a divisão inicial
  int capitulosRestantes = totalCapitulos % totalDias;

  // Lista para armazenar a divisão de capítulos
  List<List<int>> planoLeitura = [];

  // Variável de controle para capítulos já atribuídos
  int capituloAtual = 1;

  // Loop pelos dias
  for (int i = 0; i < totalDias; i++) {
    // Quantidade de capítulos para o dia atual
    int capitulosDia = capitulosPorDia + (capitulosRestantes > 0 ? 1 : 0);

    // Reduzir o número de capítulos restantes, se aplicável
    if (capitulosRestantes > 0) capitulosRestantes--;

    // Adicionar capítulos ao plano para o dia atual
    planoLeitura.add(
      List.generate(capitulosDia, (index) => capituloAtual + index),
    );

    // Atualizar o capítulo atual
    capituloAtual += capitulosDia;
  }

  return planoLeitura;
}
