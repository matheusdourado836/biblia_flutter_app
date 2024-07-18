import 'package:biblia_flutter_app/models/plan.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class InitPlanWidget extends StatelessWidget {
  final Plan plan;
  final Function() onPressed;
  const InitPlanWidget({super.key, required this.plan, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(plan.bgSelectedImgPath),
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5), BlendMode.darken
            ),
            opacity: 0.8,
          fit: BoxFit.cover
        )
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          children: [
            SafeArea(
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(onPressed: (() => Navigator.pop(context)), icon: const Icon(Icons.close, color: Colors.white, size: 28,)),
              ),
            ),
            Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: 550,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(plan.label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),),
                          const SizedBox(height: 40),
                          Text(plan.description.replaceAll('\\n', '\n'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, height: 1.7),),
                        ],
                      ),
                    ),
                  ),
                )
            ),
            SafeArea(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      fixedSize: const Size(550, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: onPressed, child: const Text('Iniciar plano')
              ),
            )
          ],
        ),
      ),
    );
  }
}