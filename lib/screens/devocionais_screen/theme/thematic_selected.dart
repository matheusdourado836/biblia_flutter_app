import 'package:biblia_flutter_app/data/theme_provider.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:biblia_flutter_app/themes/theme_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

late ThemeProvider _themeProvider;

class ThematicSelected extends StatelessWidget {
  final ThematicDevocional devocional;
  const ThematicSelected({super.key, required this.devocional});

  @override
  Widget build(BuildContext context) {
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return MediaQuery.of(context).orientation == Orientation.landscape
      ? LandScapeWidget(devocional: devocional)
      : Scaffold(
      appBar: null,
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: devocional.bgImagem!,
                height: MediaQuery.of(context).size.height * .53,
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.darken,
                color: Colors.black.withOpacity(0.7),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(devocional.referencia ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 20),
                    Text(devocional.passagem ?? '', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white))
                  ],
                ),
              ),
              Positioned(
                right: 20,
                top: 35,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              )
            ],
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * .52,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(45), topRight: Radius.circular(45))
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(devocional.titulo!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Text(devocional.texto!.replaceAll('\\n', '\n\n'), textAlign: TextAlign.justify, style: ThemeColors().verseColor(_themeProvider.isOn).copyWith(height: 1.8)
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class LandScapeWidget extends StatelessWidget {
  final ThematicDevocional devocional;
  const LandScapeWidget({super.key, required this.devocional});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(devocional.titulo!, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text(devocional.texto!.replaceAll('\\n', '\n\n'), textAlign: TextAlign.justify, style: ThemeColors().verseColor(_themeProvider.isOn).copyWith(height: 1.8)
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
