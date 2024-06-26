import 'package:biblia_flutter_app/models/enums.dart';
import 'package:flutter/material.dart';

final Map<int, dynamic> _planTexts = {
    PlanType.ONE_YEAR.code: {
      "label": "A Bíblia em 1 ano",
      "text": 'Aprofunde seu conhecimento e fortaleça sua fé com o Plano de Leitura da Bíblia em 1 Ano.\n\n'
          'Dedique alguns minutos diários para explorar as Escrituras com leituras acessíveis que oferecem lições e inspirações contínuas.\n\n'
          'Comece hoje e transforme seu ano com a Palavra de Deus, reservando um momento diário para descobrir as maravilhas da Bíblia.',
      "bgPath": 'assets/images/one_year.jpg'
    },

    PlanType.TWO_MONTHS_NEW.code: {
      "label": "Novo Testamento em 2 meses",
      "text": 'Apresentamos um plano de leitura do Novo Testamento em 2 meses, perfeito para quem busca uma compreensão mais profunda dos ensinamentos de Jesus e dos apóstolos.\n\n'
          'Com leituras diárias acessíveis de aproximadamente 4 capítulos, você explorará a vida e os ensinamentos de Cristo, a formação da igreja primitiva e as cartas apostólicas.\n\n'
          'Conhecer o Novo Testamento é essencial para compreender a mensagem de salvação e viver uma fé mais plena. Reserve um tempo diário para essa jornada espiritual e permita que o Novo Testamento transforme sua vida.\n\n'
          'Comece hoje e renove sua fé com a riqueza das Escrituras!',
      "bgPath": 'assets/images/new.jpg'
    },

    PlanType.THREE_MONTHS.code: {
      "label": "A Bíblia em 3 meses",
      "text": 'Aprofunde sua intimidade com Deus e mergulhe na riqueza das Escrituras com nosso plano de leitura da Bíblia em 3 meses.\n\n'
          'Pensado para cristãos maduros, ele guia você por aproximadamente 13 capítulos diários, desafiando e inspirando a cada dia.\n\n'
          'Reserve um tempo diário para essa leitura e fortaleça sua fé, ampliando seu entendimento e cultivando uma relação mais íntima com Deus.\n'
          'Vamos juntos celebrar a beleza da Palavra de Deus!',
      "bgPath": 'assets/images/new.jpg'
    },

    PlanType.SIX_MONTHS_OLD.code: {
      "label": "Velho testamento em 6 meses",
      "text": 'Apresentamos um plano de leitura do Antigo Testamento em 6 meses, ideal para quem busca uma compreensão mais profunda da Palavra de Deus.\n\n'
          'Com leituras diárias acessíveis de aproximadamente 5 capítulos, você descobrirá a história do povo de Israel, as profecias e os ensinamentos que formam a base da fé cristã.\n\n'
          'Conhecer o Antigo Testamento ajuda a entender melhor o Novo Testamento e a história da salvação.',
      "bgPath": 'assets/images/three_old_bg.jpg'
    }
};

class InitPlanWidget extends StatelessWidget {
  final PlanType planType;
  final Function() onPressed;
  const InitPlanWidget({super.key, required this.planType, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final key = _planTexts.keys.firstWhere((element) => element == planType.code);
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_planTexts[key]["bgPath"]),
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5), BlendMode.darken
            ),
            opacity: 0.8,
          fit: BoxFit.cover
        )
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(onPressed: (() => Navigator.pop(context)), icon: const Icon(Icons.close, color: Colors.white, size: 28,)),
              ),
            ),
            Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_planTexts[key]["label"], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),),
                      const SizedBox(height: 40),
                      Text(_planTexts[key]["text"], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white),),
                    ],
                  ),
                )
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    fixedSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: onPressed, child: const Text('Iniciar plano')
            )
          ],
        ),
      ),
    );
  }
}