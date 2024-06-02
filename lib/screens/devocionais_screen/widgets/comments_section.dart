import 'package:biblia_flutter_app/data/devocional_provider.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/community/feed_screen.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/comments_skeleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CommentsSection extends StatefulWidget {
  final String devocionalId;
  const CommentsSection({super.key, required this.devocionalId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Widget _loading() => const SizedBox(
        height: 25,
        width: 25,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      );

  @override
  void initState() {
    final devocionalProvider =
        Provider.of<DevocionalProvider>(context, listen: false);
    devocionalProvider.getComments(devocionalId: widget.devocionalId);
    super.initState();
  }

  @override
  dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Column(
        children: [
          const Text(
            'Comentários',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Consumer<DevocionalProvider>(
              builder: (context, value, _) {
                if (value.isLoading) {
                  return const CommentsSkeleton();
                }

                if (value.comments.isEmpty) {
                  return const Center(
                    child: Text('Nenhum comentário ainda...'),
                  );
                }

                return ListView.builder(
                  itemCount: value.comments.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final comentario = value.comments[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const NoBgUser(),
                              const SizedBox(width: 12),
                              Expanded(child: UserRow(comment: comentario))
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                color: Theme.of(context).colorScheme.primary),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            alignment: AlignmentDirectional.center,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      cursorColor: Colors.white,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'o nome é obrigatório'
                          : null,
                      decoration: const InputDecoration(
                        hintText: 'Seu nome...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      hintText: 'Adicionar um comentário...',
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 12),
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                          onPressed: (() {
                            if (_formKey.currentState!.validate() &&
                                _commentController.text.isNotEmpty) {
                              setState(() => _isLoading = true);
                              final devocionalProvider =
                                  Provider.of<DevocionalProvider>(context,
                                      listen: false);
                              final comment = Comentario(
                                  id: const Uuid().v4(),
                                  name: _nameController.text,
                                  comment: _commentController.text,
                                  qtdCurtidas: 0);
                              devocionalProvider
                                  .postComment(
                                      devocionalId: widget.devocionalId,
                                      comentario: comment)
                                  .whenComplete(() {
                                _nameController.clear();
                                _commentController.clear();
                                setState(() => _isLoading = false);
                                FocusScope.of(context).unfocus();
                              });
                            }
                          }),
                          icon: (_isLoading)
                              ? _loading()
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                )),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1, color: Colors.grey, strokeAlign: 10),
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class UserRow extends StatefulWidget {
  final Comentario comment;
  const UserRow({super.key, required this.comment});

  @override
  State<UserRow> createState() => _UserRowState();
}

class _UserRowState extends State<UserRow> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.comment.name!,
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: (() => setState(() => _liked = !_liked)),
                  //splashColor: Colors.redAccent,
                  radius: 40,
                  borderRadius: BorderRadius.circular(50),
                  child: (_liked)
                      ? const Icon(CupertinoIcons.heart_fill,
                          color: Colors.red, size: 18)
                      : const Icon(CupertinoIcons.heart, size: 20)),
            )
          ],
        ),
        const SizedBox(height: 4),
        Text(widget.comment.comment!, style: const TextStyle(fontSize: 12))
      ],
    );
  }
}
