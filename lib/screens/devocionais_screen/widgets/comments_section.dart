import 'package:biblia_flutter_app/data/devocional_provider.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/community/feed_screen.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/comments_skeleton.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/report_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentsSection extends StatefulWidget {
  final String devocionalId;
  const CommentsSection({super.key, required this.devocionalId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  late DevocionalProvider _devocionalProvider;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Widget _loading() => const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
  );

  @override
  void initState() {
    _devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
    _devocionalProvider.getComments(devocionalId: widget.devocionalId);
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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          const Text(
            'Comentários',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(
            child: Consumer<DevocionalProvider>(
              builder: (context, value, _) {
                if (value.isLoading) {
                  return const CommentsSkeleton();
                }

                if (value.comments.isEmpty) {
                  return const Center(
                    child: Text('Nenhum comentário ainda...\ninicie a conversa', textAlign: TextAlign.center,),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const NoBgUser(),
                              const SizedBox(width: 8),
                              Expanded(child: UserRow(comment: comentario, devocionalId: widget.devocionalId,))
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: Theme.of(context).cardTheme.color
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Form(
              key: _formKey,
              child: Row(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const NoBgUser(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 150,
                          //height: 64,
                          child: TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            cursorColor: Colors.white,
                            validator: (value) => value?.isEmpty ?? true
                                ? 'o nome é obrigatório'
                                : null,
                            decoration: InputDecoration(
                              hintText: 'Seu nome...',
                              hintStyle: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 12),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.background)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.background)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _commentController,
                                validator: (value) => value?.isEmpty ?? true
                                    ? 'o comentário é obrigatório'
                                    : null,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  hintText: 'Adicionar um comentário...',
                                  hintStyle: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 12),
                                  fillColor: Colors.white,
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.background)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.background)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            InkWell(
                              onTap: (() {
                                if (_formKey.currentState!.validate() && _commentController.text.isNotEmpty) {
                                  setState(() => _isLoading = true);
                                  final comment = Comentario(
                                    name: _nameController.text,
                                    comment: _commentController.text,
                                    createdAt: DateTime.now().toIso8601String(),
                                  );
                                  _devocionalProvider.postComment(devocionalId: widget.devocionalId, comentario: comment).whenComplete(() {
                                    _nameController.clear();
                                    _commentController.clear();
                                    setState(() => _isLoading = false);
                                    FocusScope.of(context).unfocus();
                                  });
                                }
                              }),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(50)
                                ),
                                padding: const EdgeInsets.all(12),
                                alignment: Alignment.center,
                                child: (_isLoading)
                                    ? _loading()
                                    : const Icon(
                                  Icons.send,
                                  size: 20,
                                  //color: Colors.black,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
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
  final String devocionalId;
  const UserRow({super.key, required this.comment, required this.devocionalId});

  @override
  State<UserRow> createState() => _UserRowState();
}

class _UserRowState extends State<UserRow> {
  String timeAgo(String isoDate) {
    final DateTime date = DateTime.parse(isoDate);
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'agora';
    } else if (difference.inMinutes < 60) {
      return 'há ${difference.inMinutes} ${difference.inMinutes > 1 ? 'minutos' : 'minuto'}';
    } else if (difference.inHours < 24) {
      return 'há ${difference.inHours} ${difference.inHours > 1 ? 'horas' : 'hora'}';
    } else if (difference.inDays == 1) {
      return 'ontem';
    } else if (difference.inDays < 7) {
      return 'há ${difference.inDays} dias';
    } else if (difference.inDays < 30) {
      final int weeks = (difference.inDays / 7).floor();
      return 'há $weeks ${weeks > 1 ? 'semanas' : 'semana'}';
    } else if (difference.inDays < 365) {
      final int months = (difference.inDays / 30).floor();
      return 'há $months ${months > 1 ? 'meses' : 'mês'}';
    } else {
      final int years = (difference.inDays / 365).floor();
      return 'há $years ${years > 1 ? 'anos' : 'ano'}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(widget.comment.name!, maxLines: 1, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.circle, size: 4, color: Color.fromRGBO(167, 165, 165, 1),)
                  ),
                  Text(timeAgo(widget.comment.createdAt!), style: const TextStyle(fontSize: 8, color: Color.fromRGBO(167, 167, 167, 1)),)
                ],
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: (() => showDialog(
                      context: context,
                      builder: (context) => ReportDialog(devocionalId: widget.devocionalId, comentario: widget.comment)
                  ).then((res) {
                    if(res == 1) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          elevation: 4,
                          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          content: const Text('  Denúncia enviada com sucesso!', style: TextStyle(color: Colors.white),)
                        )
                      );
                    }
                  })),
                  splashColor: Colors.redAccent,
                  radius: 40,
                  borderRadius: BorderRadius.circular(50),
                  child: const Icon(Icons.report_outlined, size: 24)
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 32.0),
          child: Text(widget.comment.comment!, textAlign: TextAlign.justify, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
