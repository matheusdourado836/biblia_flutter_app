import 'package:biblia_flutter_app/data/devocional_provider.dart';
import 'package:biblia_flutter_app/data/user_provider.dart';
import 'package:biblia_flutter_app/helpers/expandable_container.dart';
import 'package:biblia_flutter_app/helpers/format_data.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/comments_section.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/frosted_container.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'no_bg_placeholders.dart';

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
      setState(() {});
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
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).orientation == Orientation.portrait ? 0 : 24,
      ),
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
