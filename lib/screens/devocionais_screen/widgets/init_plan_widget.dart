import 'package:biblia_flutter_app/models/enums.dart';
import 'package:flutter/material.dart';

final Map<int, dynamic> _planTexts =
  {
    PlanType.ONE_YEAR.code: 'Você deseja aprofundar seu conhecimento e fortalecer sua fé? Junte-se a nós no Plano de Leitura da Bíblia em 1 Ano! '
        'Este plano é perfeito para quem quer explorar as Escrituras de forma consistente e reflexiva, dedicando apenas alguns minutos por dia.\n\n'
        'Dividimos a Bíblia em leituras diárias acessíveis. '
        'Cada dia traz novas lições e inspirações, proporcionando uma jornada espiritual contínua e significativa ao longo do ano.\n\n'
        'Comece hoje mesmo e transforme seu ${DateTime.now().year} com a Palavra de Deus!\n\n'
        'Reserve um momento diário para essa leitura e descubra as maravilhas que a Bíblia tem a oferecer. '
        'Participe dessa jornada e permita que a Palavra ilumine seu caminho todos os dias.',

    PlanType.THREE_MONTHS.code: 'Você deseja aprofundar sua intimidade com Deus e mergulhar ainda mais na riqueza das Escrituras? '
        'Apresentamos um plano de leitura da Bíblia em 3 meses, especialmente pensado para cristãos maduros que buscam uma conexão mais profunda com o Senhor.\n'
        'Este plano exigente, porém extremamente gratificante, guia você através de aproximadamente 13 capítulos diários. '
        'A cada dia, você será desafiado e inspirado, fortalecendo sua fé e ampliando seu entendimento das Escrituras.\n\n'
        'Reserve um tempo diário dedicado a essa leitura e permita que a Palavra de Deus penetre profundamente em seu coração. '
        'Este é um compromisso significativo, mas a recompensa será uma relação mais íntima e pessoal com Deus.'
        'Vamos juntos explorar e celebrar a beleza e a profundidade da Palavra de Deus!'
  };

class InitPlanWidget extends StatelessWidget {
  final PlanType planType;
  final Function() onPressed;
  const InitPlanWidget({super.key, required this.planType, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final key = _planTexts.keys.firstWhere((element) => element == planType.code);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_planTexts[key], textAlign: TextAlign.center),
          const Spacer(),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  fixedSize: Size(MediaQuery.of(context).size.width * .85, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: onPressed, child: const Text('Iniciar plano')
          )
        ],
      ),
    );
  }
}