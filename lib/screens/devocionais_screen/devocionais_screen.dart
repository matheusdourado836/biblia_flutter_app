import 'dart:math';
import 'package:biblia_flutter_app/models/enums.dart';
import 'package:flutter/material.dart';

class DevocionaisScreen extends StatelessWidget {
  const DevocionaisScreen({super.key});

  static final List<Map<String, dynamic>> _plans = [
    {"label": "Bíblia em 1 ano", "route": "one_year", "code": PlanType.ONE_YEAR},
    {"label": "Bíblia toda em 3 meses", "route": "three_months", "code": PlanType.THREE_MONTHS},
    {"label": "Novo testamento em 6 meses", "route": "one_year", "code": PlanType.SIX_MONTHS},
    {"label": "Mais um que não sei", "route": "one_year", "code": PlanType.ONE_YEAR}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Devocionais'),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Jornada Espiritual'),
              const SizedBox(height: 20),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  itemCount: 10,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 50,
                      width: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 1),
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 40.0, bottom: 24.0),
                child: Text('Faça parte da nossa comunidade'),
              ),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: 10,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 300,
                      width: MediaQuery.of(context).size.width * .8,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                          color: Colors.brown,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.blue
                                ),
                              ),
                              const SizedBox(width: 15),
                              const Text('Nome da pessoa')
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white
                              ),
                              child: Text('TEXTO DO POST TEXTO DO POST TEXTO DO POST TEXTO DO POST TEXTO DO POST TEXTO DO POST TEXTO DO POST TEXTO DO POST TEXTO DO POST TEXTO DO POST '),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(onPressed: (() => Navigator.pushNamed(context, 'feed_screen')), child: const Text('Explorar')),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 40.0, bottom: 24.0),
                child: Text('Planos de leitura'),
              ),
              ListView.builder(
                itemCount: _plans.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: (() => Navigator.pushNamed(context, _plans[index]["route"], arguments: {"code": _plans[index]["code"]})),
                    child: Row(
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          margin: const EdgeInsets.fromLTRB(0, 8, 12, 8),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 1),
                            borderRadius: BorderRadius.circular(4)
                          ),
                        ),
                        Expanded(
                          child: Text(_plans[index]["label"]),
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
