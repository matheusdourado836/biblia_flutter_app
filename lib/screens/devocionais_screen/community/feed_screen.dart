import 'package:biblia_flutter_app/data/devocional_provider.dart';
import 'package:biblia_flutter_app/data/user_provider.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/create_devocional.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/post_feed_skeleton.dart';
import 'package:biblia_flutter_app/services/bible_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../data/theme_provider.dart';
import '../../../helpers/tutorial_widget.dart';
import 'widgets/post_container.dart';


class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with TickerProviderStateMixin{
  late final userProvider = Provider.of<UserProvider>(context, listen: false);
  late final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
  final GlobalKey postKey = GlobalKey();
  int _selectedPage = 0;
  TutorialCoachMark? _coachMark;
  List<TargetFocus> _targets = [];
  bool _hasInternetConnection = false;
  bool _isPortrait = true;

  void showTutorial() {
    final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
    if(!devocionalProvider.tutorials.contains('tutorial 5') && MediaQuery.of(context).orientation == Orientation.portrait) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      initTargets();
      _coachMark = TutorialCoachMark(
        onClickTarget: (target) {
          Navigator.pushNamed(
              context, 'devocional_selected',
              arguments: {"devocional": devocionalProvider.devocionais!.first}
          );
          devocionalProvider.markTutorial(5);
        },
          onSkip: () {
            devocionalProvider.markTutorial(5);
            return true;
          },
          onFinish: () => devocionalProvider.markTutorial(5),
          colorShadow: (themeProvider.isOn) ? Colors.black : Theme.of(context).canvasColor,
          targets: _targets,
          hideSkip: true
      )..show(context: context);
    }
  }

  void initTargets() {
    _targets = [
      TargetFocus(
          identify: 'post-key',
          keyTarget: postKey,
          shape: ShapeLightFocus.RRect,
          contents: [
            TargetContent(
                align: ContentAlign.bottom,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                builder: (context, c) {
                  return TutorialWidget(
                      text: 'Clique no devocional para ler o texto completo ou clique 2 vezes para curtir',
                      skip: '',
                      next: 'Fechar',
                      onNext: () => c.next(),
                      onSkip: () => c.skip()
                  );
                }
            ),
          ]
      ),
    ];
  }

  Future<void> checkInternetConnection() async {
    _hasInternetConnection = await BibleService().checkInternetConnectivity();
    setState(() => _hasInternetConnection);
    return;
  }

  @override
  void initState() {
    checkInternetConnection();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      devocionalProvider.getDevocionais().whenComplete(() {
        if(devocionalProvider.devocionais?.isNotEmpty ?? false) {
          showTutorial();
        }
      });
    });
    super.initState();
  }

  Widget buildIconButton(IconData icon, String description, int index, Function() onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: _selectedPage == index
                  ? const Color(0xffffffff)
                  : const Color(0x75ffffff),
            ),
            const SizedBox(height: 4),
            Text(description, style: TextStyle(
                fontSize: 10,
                fontWeight: _selectedPage == index
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: _selectedPage == index
                    ? const Color(0xffffffff)
                    : const Color(0x75ffffff)
            ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _coachMark?.finish();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Posts da comunidade'),
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
        body: SafeArea(
          child: RefreshIndicator.adaptive(
            onRefresh: () => devocionalProvider.getDevocionais(),
            child: Column(
              children: [
                Consumer<DevocionalProvider>(
                  builder: (context, value, _) {
                    if (value.isLoading) {
                      return const Expanded(child: PostFeedSkeleton());
                    }

                    if(value.devocionais == null) {
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Não foi possível carregar os devocionais', textAlign: TextAlign.center,),
                            IconButton(
                              onPressed: () {
                                value.getDevocionais();
                                checkInternetConnection();
                              },
                              icon: const Icon(Icons.refresh)
                            )
                          ],
                        ),
                      );
                    }

                    if (value.devocionais!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            Image.asset(
                             'assets/images/nothing_yet.png',
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * .45,
                            ),
                            Text(
                              'Nenhum post em nossa comunidade ainda...\nQue tal criar um agora?',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
                              textAlign: TextAlign.center
                            ),
                          ],
                        ),
                      );
                    }

                    final devocionaisLength = value.devocionais!.length;

                    return Expanded(
                      child: ListView.builder(
                        itemCount: devocionaisLength,
                        itemBuilder: (context, index) {
                          final devocional = value.devocionais![index];
                          return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                PostContainer(
                                  key: index == 0 ? postKey : null,
                                  devocional: devocional
                                ),
                                if(index + 1 == devocionaisLength)
                                  const SizedBox(height: 100)
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildIconButton(Icons.search, 'Explorar', 0, () {
                  if(_selectedPage != 0) {
                    devocionalProvider.getDevocionais();
                  }
                  setState(() => _selectedPage = 0);
                }),
                buildIconButton(Icons.home, 'Início', 1, () => Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false)),
                if(userProvider.currentUser != null)
                  buildIconButton(CupertinoIcons.profile_circled, 'Meus posts', 2, () {
                    Navigator.pushNamed(context, 'owner_profile_screen');
                  }),
              ],
            ),
          ),
        ),
        floatingActionButton: (_hasInternetConnection)
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
              onPressed: () {
                final authProvider = Provider.of<UserProvider>(context, listen: false);
                if(authProvider.currentUser == null) {
                  Navigator.pushNamed(context, 'login_screen');
                  return;
                }
                showModalBottomSheet(
                    context: context,
                    constraints: BoxConstraints(
                        maxWidth: (_isPortrait) ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * .75
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    barrierColor: Theme.of(context).colorScheme.surface,
                    elevation: 0,
                    useSafeArea: true,
                    showDragHandle: true,
                    isScrollControlled: true,
                    builder: (context) => const CreateDevocional()
                );
              },
              tooltip: 'Adicionar um devocional',
              child: Icon(
                Icons.add,
                size: 26,
                color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
              ),
            )
        : null,
      ),
    );
  }
}
