import 'package:biblia_flutter_app/helpers/int_to_textAlign.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:flutter/material.dart';

class DevocionalSelected extends StatelessWidget {
  final Devocional devocional;
  const DevocionalSelected({super.key, required this.devocional});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(devocional.referencia!),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .8,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                      devocional.titulo!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 24, fontStyle: FontStyle.italic,
                      ),
                    textAlign: intToTextAlign(devocional.textAlign!),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Text(
                      devocional.texto!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 22
                      ),
                      textAlign: intToTextAlign(devocional.textAlign!),
                    )
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
