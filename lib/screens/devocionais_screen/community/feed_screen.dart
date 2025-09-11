import 'package:biblia_flutter_app/data/devocional_provider.dart';
import 'package:biblia_flutter_app/data/user_provider.dart';
import 'package:biblia_flutter_app/helpers/expandable_container.dart';
import 'package:biblia_flutter_app/helpers/format_data.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:biblia_flutter_app/models/user.dart';
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

double _horizontalPadding = 0;

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
    _horizontalPadding = _isPortrait ? 0 : 24;
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
    devocionalProvider.updateDevocionalData(widget.devocional.id!, {"qtdCurtidas": widget.devocional.qtdCurtidas});
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
                      ? ColorFilter.mode(Colors.black.withValues(alpha: 0.45), BlendMode.darken)
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
                  onTap: () {
                    devocionalProvider.countView(widget.devocional.id!, widget.devocional.ownerId!);
                    Navigator.pushNamed(
                        context, 'devocional_selected',
                        arguments: {"devocional": widget.devocional}
                    );
                  },
                  onDoubleTap: () {
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
                  },
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
                              .fadeOut(delay: 500.ms)
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
                  InkWell(
                    onTap: () {
                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                      if(widget.devocional.ownerId == userProvider.currentUser?.id) {
                        Navigator.pushNamed(context, 'owner_profile_screen', arguments: {"devocionalId": widget.devocional.ownerId});
                      }else {
                        Navigator.pushNamed(context, 'profile_screen', arguments: {"devocionalId": widget.devocional.ownerId});
                      }
                    },
                    child: Row(
                      children: [
                        if (widget.devocional.bgImagemUser?.isNotEmpty ?? false)
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(widget.devocional.bgImagemUser!,)
                                )
                            ),
                          ) else const NoBgUser(),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth * .5,
                              child: (widget.devocional.nomeAutor! != 'BibleWise')
                                ? Text(
                                  widget.devocional.nomeAutor!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(color: Colors.white, fontSize: 12)
                                )
                                : Row(
                                  children: [
                                    Text(
                                        widget.devocional.nomeAutor!,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          color: Colors.lightBlue,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        )
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(Icons.verified, color: Colors.blue, size: 14,)
                                  ],
                                )
                            ),
                            const SizedBox(height: 8),
                            Text(todayDate, style: const TextStyle(color: Colors.white, fontSize: 10))
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => showModalBottomSheet(
                              context: context,
                              showDragHandle: true,
                              isScrollControlled: true,
                              useSafeArea: true,
                              elevation: 0,
                              barrierColor: Theme.of(context).colorScheme.surface,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              builder: (context) => CommentsSection(
                                devocionalId: widget.devocional.id!,
                                ownerName: widget.devocional.nomeAutor!,
                              )
                          ),
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
          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.45), BlendMode.darken),
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

class DeletePostDialog extends StatefulWidget {
  final String devocionalId;
  final MyUser currentUser;
  final Function() refresh;
  const DeletePostDialog({super.key, required this.refresh, required this.currentUser, required this.devocionalId});

  @override
  State<DeletePostDialog> createState() => _DeletePostDialogState();
}

class _DeletePostDialogState extends State<DeletePostDialog> {
  bool _isLoading = false;
  Widget _loading() => SizedBox(
    height: 25,
    width: 25,
    child: CircularProgressIndicator(
      color: Theme.of(context).colorScheme.primary,
      strokeWidth: 2,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exlcuir post?'),
      actions: [
        TextButton(
            onPressed: () {
              final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
              setState(() => _isLoading = true);
              devocionalProvider.deletePost(widget.devocionalId).whenComplete(() {
                devocionalProvider.getUserDevocionais().whenComplete(() {
                  setState(() => _isLoading = false);
                  widget.refresh();
                  Navigator.pop(context);
                });
              });
            },
            child: (_isLoading) ? _loading() : const Text('Sim')
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Não')),
      ],
    );
  }
}

