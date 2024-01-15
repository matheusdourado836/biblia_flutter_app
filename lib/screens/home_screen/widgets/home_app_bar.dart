import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../helpers/alert_dialog.dart';
import '../../../services/bible_service.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({Key? key}) : super(key: key);

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeAppBarState extends State<HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    final versesProvider = Provider.of<VersesProvider>(context, listen: false);
    return AppBar(
      centerTitle: true,
      title: const Text('BibleWise'),
      actions: [
        IconButton(
          onPressed: () {
            versesProvider.clear();
            BibleService().checkInternetConnectivity().then((value) => {
                  if (value) {
                    Navigator.pushNamed(context, 'random_verse_screen')
                  }
                  else {
                      alertDialog(content: 'Você precisa estar conectado a internet para receber um versiculo aleatório')
                  }
                });
          },
          tooltip: 'Versículo Aleatório',
          icon: const Icon(Icons.help_outline_rounded),
        ),
      ],
    );
  }
}