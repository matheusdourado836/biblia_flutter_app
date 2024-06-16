import 'package:biblia_flutter_app/data/devocional_provider.dart';
import 'package:biblia_flutter_app/helpers/expandable_container.dart';
import 'package:biblia_flutter_app/helpers/format_date.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/comments_section.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/create_devocional.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/post_feed_skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Posts da comunidade'),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Consumer<DevocionalProvider>(
          builder: (context, value, _) {
            if(value.isLoading) {
              return const PostFeedSkeleton();
            }

            if(value.devocionais.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/nothing_yet.png',
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * .55,
                  ),
                  const Text('Nenhum post em nossa comunidade ainda...\nQue tal criar um agora?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200), textAlign: TextAlign.center)
                ],
              );
            }

            if(value.devocionais.isNotEmpty && value.devocionais.first.bgImagem != null) {
              
            }

            return ListView.builder(
              itemCount: value.devocionais.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final devocional = value.devocionais[index];
                if(index + 1 == value.devocionais.length) {
                  return Column(
                    children: [
                      PostContainer(devocional: devocional),
                      const SizedBox(height: 100,),
                    ],
                  );
                }
                return PostContainer(devocional: devocional);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
        onPressed: (() => showModalBottomSheet(
            context: context,
            backgroundColor: Theme.of(context).colorScheme.background,
            barrierColor: Theme.of(context).colorScheme.background,
            elevation: 0,
            useSafeArea: true,
            showDragHandle: true,
            isScrollControlled: true,
            builder: (context) => const CreateDevocional()
        )
        ),
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

class _PostContainerState extends State<PostContainer> with SingleTickerProviderStateMixin{
  late AnimationController controller;
  bool _liked = false;
  String todayDate = '';
  String _userId = '';
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId')!;
    _liked = await devocionalProvider.checkIfPostIsLiked(userId: _userId, postId: widget.devocional.id!);
    setState(() {
      _liked;
      _userId;
    });
  }

  void likePost() {
    (_liked)
        ? widget.devocional.qtdCurtidas = widget.devocional.qtdCurtidas! + 1
        : widget.devocional.qtdCurtidas = widget.devocional.qtdCurtidas! - 1;
    devocionalProvider.updateUserData(widget.devocional.id!, {"qtdCurtidas": widget.devocional.qtdCurtidas});
    devocionalProvider.likePost(userId: _userId, postId: widget.devocional.id!, like: _liked);
  }

  Widget iconInfo({required Widget icon, required String text}) => Row(
    children: [
      Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
      const SizedBox(width: 10),
      icon,
    ],
  );
  
  Widget heartIcon({required IconData icon, required Color color}) => Icon(icon, color: color, size: 20,);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).cardTheme.color,
          boxShadow: kElevationToShadow[1]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: InkWell(
              onTap: (() => Navigator.pushNamed(context, 'devocional_selected', arguments: {"devocional": widget.devocional})),
              onDoubleTap: (() {
                setState(() => _liked = true);
                devocionalProvider.checkIfPostIsLiked(userId: _userId, postId: widget.devocional.id!).then((res) {
                  if(!res) {
                    likePost();
                    setState(() {});
                  }
                });
                controller.forward(from: 0);
              }),
              child: Stack(
                children: [
                  (widget.devocional.bgImagem != null && widget.devocional.bgImagem!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: widget.devocional.bgImagem!,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator())
                        )
                      : NoBgImage(title: widget.devocional.titulo!),
                  Align(
                    alignment: Alignment.center,
                    child: const Icon(CupertinoIcons.heart_fill, size: 100, color: Colors.red,)
                        .animate(controller: controller, value: 1)
                        .scaleXY(begin: .8, duration: 150.ms)
                        .scaleXY(begin: 1.3, delay: 150.ms)
                        .scaleXY(delay: 500.ms, end: 0)
                  )
                ],
              )
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: ExpandableContainer(
              header: widget.devocional.titulo!,
              expandedText: widget.devocional.texto!,
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
                            image: CachedNetworkImageProvider(
                              widget.devocional.bgImagemUser!,
                            )
                        )
                    ),
                  )
                  : const NoBgUser(),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.devocional.nomeAutor!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text('Em $todayDate', style: const TextStyle(color: Colors.white, fontSize: 10))
                    ],
                  )
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
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
                            builder: (context) => CommentsSection(devocionalId: widget.devocional.id!))
                        ),
                        child: iconInfo(text: widget.devocional.qtdComentarios!.toString(), icon: const Icon(Icons.chat_bubble, color: Colors.white, size: 16,)),
                      ),
                      const SizedBox(width: 12),
                      iconInfo(
                        text: widget.devocional.qtdCurtidas!.toString(),
                        icon: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: (() {
                              setState(() => _liked = !_liked);
                              likePost();
                            }),
                            radius: 40,
                            borderRadius: BorderRadius.circular(50),
                            child: heartIcon(icon: (_liked) ? CupertinoIcons.heart_fill : CupertinoIcons.heart, color: (_liked) ? Colors.red : Colors.white)
                                .animate(target: _liked ? 0 : 1)
                                .scaleXY(begin: .8, duration: 100.ms)
                                .scaleXY(begin: 1.3, delay: 100.ms)
                          ),
                        )
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}


class NoBgImage extends StatelessWidget {
  final String title;
  const NoBgImage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 56.0, horizontal: 20),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white54
        ),
        child: Text('"$title"', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))
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
