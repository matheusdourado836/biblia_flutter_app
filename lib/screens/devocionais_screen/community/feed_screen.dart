import 'package:biblia_flutter_app/data/devocional_provider.dart';
import 'package:biblia_flutter_app/helpers/expandable_container.dart';
import 'package:biblia_flutter_app/helpers/format_date.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/comments_section.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/create_devocional.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/frosted_container.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/post_feed_skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

bool _isPortrait = true;
double _horizontalPadding = 0;

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
    devocionalProvider.getDevocionais();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    _horizontalPadding = _isPortrait ? 0 : 24;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Posts da comunidade'),
        actions: [
          IconButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false), icon: const Icon(Icons.home))
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Consumer<DevocionalProvider>(
            builder: (context, value, _) {
              if (value.isLoading) {
                return const PostFeedSkeleton();
              }
        
              if (value.devocionais.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/nothing_yet.png',
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * .55,
                    ),
                    const Text(
                        'Nenhum post em nossa comunidade ainda...\nQue tal criar um agora?',
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
                        textAlign: TextAlign.center)
                  ],
                );
              }
        
              if (value.devocionais.isNotEmpty &&
                  value.devocionais.first.bgImagem != null) {}
        
              return ListView.builder(
                itemCount: value.devocionais.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final devocional = value.devocionais[index];
                  if (index + 1 == value.devocionais.length) {
                    return Column(
                      children: [
                        PostContainer(devocional: devocional),
                        const SizedBox(height: 100),
                      ],
                    );
                  }
                  return PostContainer(devocional: devocional);
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
            builder: (context) => const CreateDevocional())),
        tooltip: 'Adicionar um devocional',
        child: Icon(
          Icons.add,
          size: 26,
          color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
        ),
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
    setState(() {
      _liked;
    });
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
  
  Widget bgImagem({required double height}) => Container(
    height: height,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
            colorFilter: (widget.devocional.hasFrost ?? false)
                ? ColorFilter.mode(Colors.black.withOpacity(0.45), BlendMode.darken)
                : null,
            fit: BoxFit.cover, image: CachedNetworkImageProvider(widget.devocional.bgImagem!)
        )
    ),
    child: (widget.devocional.hasFrost ?? false)
        ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FrostedContainer(title: widget.devocional.titulo!),
    ) : const SizedBox(),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: _containerHeight,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: _horizontalPadding),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardTheme.color,
        boxShadow: kElevationToShadow[1]
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          print('OLHA AE EEE ${constraints.maxWidth}');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                  onTap: (() => Navigator.pushNamed(
                      context, 'devocional_selected',
                      arguments: {"devocional": widget.devocional}
                  )),
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
                      (widget.devocional.bgImagem != null && widget.devocional.bgImagem!.isNotEmpty)
                          ? bgImagem(height: constraints.maxWidth > 400 ? 400 : 200)
                          : NoBgImage(title: widget.devocional.titulo!, height: constraints.maxWidth > 400 ? 400 : 200,),
                      Align(
                          alignment: Alignment.center,
                          child: const Icon(
                            CupertinoIcons.heart_fill,
                            size: 100,
                            color: Colors.red,
                          )
                              .animate(controller: controller, value: 1)
                              .scaleXY(begin: .8, duration: 150.ms)
                              .scaleXY(begin: 1.3, delay: 150.ms)
                              .scaleXY(delay: 500.ms, end: 0)
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
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 4),
                    child: SizedBox(
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
                                barrierColor:
                                Theme.of(context).colorScheme.background,
                                backgroundColor:
                                Theme.of(context).colorScheme.background,
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
                                Text(widget.devocional.qtdComentarios!.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
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
                              Text(widget.devocional.qtdCurtidas!.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          )
                        ],
                      ),
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
