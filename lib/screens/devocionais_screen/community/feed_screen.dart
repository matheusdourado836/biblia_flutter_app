import 'package:biblia_flutter_app/data/devocional_provider.dart';
import 'package:biblia_flutter_app/helpers/expandable_container.dart';
import 'package:biblia_flutter_app/helpers/format_data.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/community/tab_item.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/comments_section.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/create_devocional.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/frosted_container.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/post_feed_skeleton.dart';
import 'package:biblia_flutter_app/services/bible_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../data/theme_provider.dart';
import '../../../helpers/tutorial_widget.dart';

bool _isPortrait = true;
double _horizontalPadding = 0;

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with TickerProviderStateMixin{
  late final TabController _tabController = TabController(length: 3, vsync: this);
  final GlobalKey postKey = GlobalKey();
  late final DevocionalProvider devocionalProvider;
  int _selectedPage = 0;
  List<Devocional> _approvedDevocionais = [];
  List<Devocional> _pendingDevocionais = [];
  List<Devocional> _rejectedDevocionais = [];
  List<List<Devocional>> _userDevocionais = [];
  TutorialCoachMark? _coachMark;
  List<TargetFocus> _targets = [];
  bool _hasInternetConnection = false;

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
          onFinish: () {
            devocionalProvider.markTutorial(5);
          },
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
                      onNext: (() => c.next()),
                      onSkip: (() => c.skip())
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
    devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      devocionalProvider.getDevocionais().whenComplete(() {
        if(devocionalProvider.devocionais?.isNotEmpty ?? false) {
          showTutorial();
        }
      });
    });
    _userDevocionais = [_approvedDevocionais, _pendingDevocionais, _rejectedDevocionais];
    super.initState();
  }

  Widget buildIconButton(IconData icon, String description, int index, Function() onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
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
    _horizontalPadding = _isPortrait ? 0 : 24;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: (_selectedPage == 0) ? const Text('Posts da comunidade') : const Text('Seus posts'),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          child: RefreshIndicator.adaptive(
            onRefresh: () => _selectedPage == 0 ? devocionalProvider.getDevocionais() : devocionalProvider.getUserDevocionais(),
            child: Column(
              children: [
                (_selectedPage == 0)
                  ? const SizedBox()
                  : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.fromLTRB(12, 20, 12, 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.primary
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorWeight: 3,
                      dividerColor: Colors.transparent,
                      unselectedLabelColor: Theme.of(context).colorScheme.tertiary,
                      labelColor: Colors.white,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                      indicatorColor: Theme.of(context).colorScheme.secondary,
                      onTap: (index) {
                        setState(() {});
                      },
                      tabs: [
                        TabItem(title: 'Aprovados', count: _approvedDevocionais.length),
                        TabItem(title: 'Pendentes', count: _pendingDevocionais.length),
                        TabItem(title: 'Rejeitados', count: _rejectedDevocionais.length),
                      ]
                    ),
                  ),
                ),
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
                                _selectedPage == 2
                                ? 'Você não fez nenhum post ainda...\nQue tal criar um agora?'
                                : 'Nenhum post em nossa comunidade ainda...\nQue tal criar um agora?',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
                                textAlign: TextAlign.center
                            ),
                          ],
                        ),
                      );
                    }

                    return Expanded(
                      child: ListView.builder(
                        itemCount: (_selectedPage == 0) ? value.devocionais!.length : _userDevocionais[_tabController.index].length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final devocional = (_selectedPage == 0) ? value.devocionais![index] : _userDevocionais[_tabController.index][index];
                          return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                _infoRow(devocional),
                                PostContainer(
                                  key: index == 0 ? postKey : null,
                                  devocional: devocional
                                ),
                                if(index + 1 == value.devocionais!.length)
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
          //height: 85,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
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
              buildIconButton(CupertinoIcons.profile_circled, 'Meus posts', 2, () {
                if(_selectedPage != 2) {
                  devocionalProvider.getUserDevocionais().whenComplete(() {
                    setState(() {
                      _approvedDevocionais = devocionalProvider.devocionais?.where((devocional) => devocional.status == 0).toList() ?? [];
                      _pendingDevocionais = devocionalProvider.devocionais?.where((devocional) => devocional.status == 1).toList() ?? [];
                      _rejectedDevocionais = devocionalProvider.devocionais?.where((devocional) => devocional.status == 2).toList() ?? [];
                      _userDevocionais = [_approvedDevocionais, _pendingDevocionais, _rejectedDevocionais];
                    });
                  });
                }
                setState(() => _selectedPage = 2);
              }),
            ],
          ),
        ),
        floatingActionButton: (_hasInternetConnection)
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
              onPressed: (() => showModalBottomSheet(
                  context: context,
                  constraints: BoxConstraints(
                      maxWidth: (_isPortrait) ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * .75
                  ),
                  backgroundColor: Theme.of(context).colorScheme.background,
                  barrierColor: Theme.of(context).colorScheme.background,
                  elevation: 0,
                  useSafeArea: true,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (context) => const CreateDevocional()
              )),
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

  Widget _infoRow(Devocional devocional) {
    if(_selectedPage == 0) {
      return const SizedBox();
    }
    return Row(
      children: [
        const Text('Visualizações: '),
        Text(formatInfoQuantity(devocional.qtdViews!)),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Público'),
              Transform.scale(
                scale: .70,
                child: Switch(value: devocional.public!, onChanged: (newValue) {
                  devocional.public = newValue;
                  devocionalProvider.updateUserData(devocional.id!, {"public": devocional.public});
                  setState(() {});
                }),
              )
            ],
          ),
        )
      ],
    );
  }
}

class PostContainer extends StatefulWidget {
  final Devocional devocional;
  const PostContainer({super.key, required this.devocional});

  @override
  State<PostContainer> createState() => _PostContainerState();
}

class _PostContainerState extends State<PostContainer> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool _liked = false;
  String todayDate = '';
  late DevocionalProvider devocionalProvider;

  @override
  void initState() {
    controller = AnimationController(vsync: this);
    controller.stop();
    devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
    checkIfPostIsLiked();
    todayDate = formattedDate(dateString: widget.devocional.createdAt!);
    super.initState();
  }

  void checkIfPostIsLiked() async {
    _liked = await devocionalProvider.checkIfPostIsLiked(postId: widget.devocional.id!);
    if(mounted) {
      setState(() {
        _liked;
      });
    }
  }

  void likePost() {
    (_liked)
        ? widget.devocional.qtdCurtidas = widget.devocional.qtdCurtidas! + 1
        : widget.devocional.qtdCurtidas = widget.devocional.qtdCurtidas! - 1;
    devocionalProvider.updateUserData(widget.devocional.id!, {"qtdCurtidas": widget.devocional.qtdCurtidas});
    devocionalProvider.likePost(postId: widget.devocional.id!, like: _liked);
  }

  Widget iconInfo({required Widget icon, required String text}) => Column(
    children: [
      icon,
      const SizedBox(height: 4),
      Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
    ],
  );

  Widget heartIcon({required IconData icon, required Color color}) => Icon(
        icon,
        color: color,
        size: 21,
  );

  Widget bgImagem({required double height, required BoxConstraints constraints}) {
    if(widget.devocional.bgImagem == null || widget.devocional.bgImagem!.isEmpty) {
      return NoBgImage(title: widget.devocional.titulo!, height: constraints.maxWidth > 400 ? 400 : 250,);
    }
    return CachedNetworkImage(
      imageUrl: widget.devocional.bgImagem!,
      imageBuilder: (context, image) {
        return Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                  colorFilter: (widget.devocional.hasFrost ?? false)
                      ? ColorFilter.mode(Colors.black.withOpacity(0.45), BlendMode.darken)
                      : null,
                  fit: BoxFit.cover, image: image
              )
          ),
          child: (widget.devocional.hasFrost ?? false)
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FrostedContainer(title: widget.devocional.titulo!),
          ) : const SizedBox(),
        );
      },
      placeholder: (context, url) {
        return const CircularProgressIndicator();
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _horizontalPadding),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardTheme.color,
        boxShadow: kElevationToShadow[1]
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                  onTap: (() {
                    devocionalProvider.countView(widget.devocional.id!, widget.devocional.ownerId!);
                    Navigator.pushNamed(
                        context, 'devocional_selected',
                        arguments: {"devocional": widget.devocional}
                    );
                  }),
                  onDoubleTap: (() {
                    setState(() => _liked = true);
                    devocionalProvider
                        .checkIfPostIsLiked(postId: widget.devocional.id!)
                        .then((res) {
                      if (!res) {
                        likePost();
                        setState(() {});
                      }
                    });
                    controller.forward(from: 0);
                  }),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      bgImagem(height: constraints.maxWidth > 400 ? 400 : 250, constraints: constraints),
                      Align(
                          alignment: Alignment.center,
                          child: Icon(
                            CupertinoIcons.heart_fill,
                            size: 122,
                            color: Colors.red,
                            shadows: kElevationToShadow[4],
                          )
                              .animate(controller: controller, value: 1)
                              .scaleXY(begin: .8, duration: 180.ms)
                              .scaleXY(begin: 1.2, delay: 180.ms)
                              .scaleXY(begin: 1.2, duration: 180.ms)
                              .scaleXY(begin: .8, delay: 360.ms)
                              // .moveY(delay: 650.ms, duration: 800.ms, begin: 0, end: -500)
                              // .shake(duration: 500.ms)
                              .fadeOut(delay: 500.ms)
                              //.scaleXY(delay: 1000.ms, end: 0)
                      )
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ExpandableContainer(
                  header: widget.devocional.titulo!,
                  expandedText: widget.devocional.plainText!,
                  devocional: widget.devocional,
                  verCompleto: true,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      (widget.devocional.bgImagemUser != null && widget.devocional.bgImagemUser!.isNotEmpty)
                          ? Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(widget.devocional.bgImagemUser!,)
                            )
                        ),
                      )
                          : const NoBgUser(),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: constraints.maxWidth * .5,
                              child: Text(widget.devocional.nomeAutor!, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(color: Colors.white, fontSize: 12))
                          ),
                          const SizedBox(height: 8),
                          Text('Em $todayDate', style: const TextStyle(color: Colors.white, fontSize: 10))
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: (() => showModalBottomSheet(
                              context: context,
                              showDragHandle: true,
                              isScrollControlled: true,
                              useSafeArea: true,
                              elevation: 0,
                              barrierColor: Theme.of(context).colorScheme.background,
                              backgroundColor: Theme.of(context).colorScheme.background,
                              builder: (context) => CommentsSection(
                                  devocionalId: widget.devocional.id!))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.chat_bubble,
                                color: Colors.white,
                                size: 20,
                              ),
                              Text(formatInfoQuantity(widget.devocional.qtdComentarios!), style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                  onTap: (() {
                                    setState(() => _liked = !_liked);
                                    likePost();
                                  }),
                                  radius: 40,
                                  borderRadius: BorderRadius.circular(50),
                                  child: heartIcon(
                                      icon: (_liked)
                                          ? CupertinoIcons.heart_fill
                                          : CupertinoIcons.heart,
                                      color: (_liked)
                                          ? Colors.red
                                          : Colors.white)
                                      .animate(target: _liked ? 0 : 1)
                                      .scaleXY(begin: .8, duration: 100.ms)
                                      .scaleXY(begin: 1.3, delay: 100.ms)),
                            ),
                            Text(formatInfoQuantity(widget.devocional.qtdCurtidas!), style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          );
        }
      ),
    );
  }
}

class NoBgImage extends StatelessWidget {
  final String title;
  final double height;
  const NoBgImage({super.key, required this.title, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.45), BlendMode.darken),
          image: const AssetImage('assets/images/santidade.png'),
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: FrostedContainer(title: title),
      ),
    );
  }
}

class NoBgUser extends StatelessWidget {
  const NoBgUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.grey,
      ),
      child: const Icon(Icons.person, size: 26),
    );
  }
}
