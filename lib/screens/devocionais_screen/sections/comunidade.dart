import 'package:biblia_flutter_app/screens/devocionais_screen/community/widgets/no_bg_placeholders.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/post_feed_skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:provider/provider.dart';
import 'package:biblia_flutter_app/data/devocional_provider.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/devocionais_tutorial.dart';

class Comunidade extends StatefulWidget {
  const Comunidade({super.key});

  @override
  State<Comunidade> createState() => _ComunidadeState();
}

class _ComunidadeState extends State<Comunidade> {
  late Widget imageProvider;
  List<Devocional>? _devocionais = [];

  @override
  void initState() {
    final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => devocionalProvider.getDevocionais(limit: 5).whenComplete(() => _devocionais = devocionalProvider.devocionais));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 40.0, bottom: 24.0, left: 16.0),
          child: Text('Faça parte da nossa comunidade'),
        ),
        Container(
          key: communityKey,
          height: 320,
          color: Theme.of(context).cardTheme.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Consumer<DevocionalProvider>(
                  builder: (context, value, _) {
                    if(value.isLoading) {
                      return const PostFeedSkeleton();
                    }

                    if(_devocionais == null) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Não foi possível carregar os devocionais', style: TextStyle(color: Colors.white),),
                          IconButton(
                              onPressed: () => value.getDevocionais(limit: 5).whenComplete(() => _devocionais = value.devocionais),
                              icon: const Icon(Icons.refresh, color: Colors.white,)
                          )
                        ],
                      );
                    }

                    return CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        viewportFraction: 1,
                        enlargeCenterPage: true,
                        enlargeFactor: .5
                      ),
                      items: _devocionais!.map((devocional) {
                        return Container(
                          width: 650,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  (devocional.bgImagemUser != null && devocional.bgImagemUser!.isNotEmpty)
                                      ? Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: CachedNetworkImageProvider(
                                              devocional.bgImagemUser!,
                                            )
                                        )
                                    ),
                                  )
                                      : const NoBgUser(),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(devocional.nomeAutor!, maxLines: 1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white
                                  ),
                                  child: Text(devocional.plainText!, maxLines: 4, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black),)
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: (() => Navigator.pushNamed(context, 'feed_screen')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Explorar'),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
