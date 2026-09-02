import 'package:biblia_flutter_app/screens/devocionais_screen/devocionais_tutorial.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/sections/comunidade.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/sections/jornada_espiritual.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/sections/planos_de_leitura.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:provider/provider.dart';
import '../../data/user_provider.dart';



class DevocionaisScreen extends StatefulWidget {
  const DevocionaisScreen({super.key});

  @override
  State<DevocionaisScreen> createState() => _DevocionaisScreenState();
}

class _DevocionaisScreenState extends State<DevocionaisScreen> {
  late final userProvider = Provider.of<UserProvider>(context, listen: false);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    if(userProvider.currentUser == null) userProvider.getLoggedUser().whenComplete(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Devocionais'),
        actions: [
          IconButton(
              onPressed: () {
                if(userProvider.currentUser == null) {
                  Navigator.pushNamed(context, 'login_screen');
                }else {
                  Navigator.pushNamed(context, 'user_config_screen');
                }
              },
              icon: const Icon(CupertinoIcons.person_crop_circle)
          )
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                JornadaEspiritual(scrollController: _scrollController,),
                const Comunidade(),
                const PlanosDeLeitura()
              ],
            ),
          ),
          ValueListenableBuilder(valueListenable: removeTutorialBackground, builder: (context, value, _) {
            if(!value) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              );
            }else {
              return const SizedBox();
            }
          })
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
        onPressed: () => Navigator.pushNamed(context, 'reading_groups_screen'),
        tooltip: 'Leitura em grupo',
        child: Icon(
          Icons.group,
          size: 26,
          color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
        ),
      ),
    );
  }
}
