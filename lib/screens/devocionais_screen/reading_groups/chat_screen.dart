import 'package:biblia_flutter_app/data/ai_helper.dart';
import 'package:biblia_flutter_app/data/user_provider.dart';
import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:biblia_flutter_app/models/user.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/theme_provider.dart';
import '../../../models/group.dart';
import '../../../models/message.dart';

class ChatScreen extends StatefulWidget {
  final Group group;
  final List<MyUser> participantes;
  const ChatScreen({super.key, required this.group, required this.participantes});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final UserProvider _groupsProvider = Provider.of<UserProvider>(context, listen: false);
  GlobalKey<FlutterMentionsState> key = GlobalKey<FlutterMentionsState>();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final _chat = AiHelper.chat;
  late final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  bool darkMode = false;

  @override
  void initState() {
    if(themeProvider.themeMode == null) {
      themeProvider.getThemeMode().whenComplete(() {
        darkMode = !themeProvider.isOn;
        setState(() {});
      });
    }else {
      darkMode = !themeProvider.isOn;
    }
    super.initState();
  }

  Widget _senderContainer(Message message) => Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            bottomLeft: Radius.circular(25),
            topRight: Radius.circular(0),
            bottomRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildFormattedText(message.text, Colors.white),
            const SizedBox(width: 12),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            )
          ],
        ),
      ),
    );

  Widget _receiverContainer(Message message, BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(message.senderId.isEmpty && message.senderName == 'Éden')
          InkWell(
            onTap: () => showDialog(
              context: context,
              builder: (context) => Dialog(
                child: InteractiveViewer(
                  child: Image.asset('assets/images/eden.jpeg'),
                ),
              ),
            ).whenComplete(() => _focusNode.unfocus()),
            child: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/eden.jpeg'),
            ),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: const EdgeInsets.symmetric(vertical: 12),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  bottomLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.senderName,
                    style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _buildFormattedText(
                          message.text,
                          darkMode ? Colors.white : Colors.black
                        ),
                      ),
                      Text(
                        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormattedText(String text, Color textColor) {
    final List<InlineSpan> children = [];
    // Expressões regulares para estilos
    final RegExp boldRegExp = RegExp(r'\*\s*\*\*(.*?)\*\*'); // Bold
    final RegExp mentionRegExp = RegExp(r'@\w+'); // Menção, como "@MetaAi"

    int start = 0;

    // Combinações para ambas as expressões regulares
    final matches = [
      ...boldRegExp.allMatches(text),
      ...mentionRegExp.allMatches(text.removerAcentos()),
    ]..sort((a, b) => a.start.compareTo(b.start)); // Ordenar as matches por posição

    for (final match in matches) {
      // Texto normal antes do match
      if (start < match.start) {
        children.add(TextSpan(text: text.substring(start, match.start)));
      }

      // Verificar o tipo de match
      if (boldRegExp.hasMatch(match.group(0)!)) {
        // Texto em negrito
        final String boldText = match.group(1)!;
        children.add(TextSpan(
          text: '\n$boldText'.trimRight(),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ));
      } else if (mentionRegExp.hasMatch(match.group(0)!)) {
        // Texto de menção
        final String mentionText = match.group(0)!;
        children.add(TextSpan(
          text: mentionText,
          style: TextStyle(
            color: darkMode ? Colors.deepPurple : Colors.blueAccent,
            fontWeight: FontWeight.bold
          ),
        ));
      }

      start = match.end; // Atualizar o início para o próximo trecho
    }

    // Adicionar o texto restante após o último match
    if (start < text.length) {
      children.add(TextSpan(text: text.substring(start)));
    }

    return Text.rich(
      textWidthBasis: TextWidthBasis.longestLine,
      overflow: TextOverflow.visible,
      TextSpan(
        style: TextStyle(
          fontFamily: 'Poppins',
          color: textColor,
          fontSize: 16,
          height: 1.4,
          overflow: TextOverflow.clip
        ),
        children: children,
      ),
    );
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    ),
    );
  }

  Widget groupMessageList(String groupId, BoxConstraints constraints) {
    return StreamBuilder<List<Message>>(
      stream: _groupsProvider.getGroupMessages(groupId),
      builder: (context, snapshot) {
        if(snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if(snapshot.data?.isEmpty ?? true) {
          return const Center(
            child: Text.rich(
              TextSpan(
                text: 'Nenhum mensagem ainda...\n',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
                children: [
                  TextSpan(
                    text: 'inicie a conversa',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black54,
                      fontSize: 16
                    )
                  )
                ]
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        final messages = snapshot.data!;
        if(snapshot.data!.where((m) => !(m.hasSeen?.contains(_groupsProvider.currentUser!.id!) ?? true)).isNotEmpty) {
          _groupsProvider.markMessagesAsRead(groupId: widget.group.id!);
        }

        return TextSelectionTheme(
          data: const TextSelectionThemeData(
            selectionColor: Colors.grey,
            selectionHandleColor: Colors.black,
          ),
          child: SelectionArea(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final message = messages[index];
                final messageDate = DateFormat('yyyy-MM-dd').format(message.timestamp);
                String? dayLabel;

                // Determina o rótulo do dia
                if (index == messages.length - 1 ||
                    DateFormat('yyyy-MM-dd').format(messages[index + 1].timestamp) != messageDate) {
                  final today = DateTime.now();
                  if (messageDate == DateFormat('yyyy-MM-dd').format(today)) {
                    dayLabel = 'Hoje';
                  } else if (messageDate == DateFormat('yyyy-MM-dd').format(today.subtract(const Duration(days: 1)))) {
                    dayLabel = 'Ontem';
                  } else {
                    dayLabel = DateFormat('dd/MM/yyyy').format(message.timestamp);
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dayLabel != null)
                      Center(
                        child: Chip(
                          label: Text(
                            dayLabel,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                      ),
                    if(message.senderId == _groupsProvider.currentUser!.id!)
                      _senderContainer(message)
                    else
                      _receiverContainer(message, constraints),
                  ],
                );
              },
            )
          )
        );
      },
    );
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Algo deu errado'),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }

  Future<void> _sendAiChatMessage(String message) async {
    String text = '';
    String defaultPrompt = 'se apresente para os usuários';
    try {
      final response = await _chat.sendMessage(
          Content.text(message.replaceAll('@Eden', ''))
      );
      text = response.text ?? defaultPrompt;
      final messageAi = Message(
          senderId: '',
          senderName: 'Éden',
          text: text.isEmpty ? defaultPrompt : text,
          hasSeen: [_groupsProvider.currentUser!.id!],
          timestamp: DateTime.now()
      );
      _groupsProvider.sendGroupMessage(widget.group.id!, messageAi);

    } catch (e) {
      _showError(e.toString());
    }
  }

  Widget groupMessageInput(String groupId) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: FlutterMentions(
          key: key,
          focusNode: _focusNode,
          suggestionPosition: SuggestionPosition.Top,
          maxLines: 5,
          minLines: 1,
          style: const TextStyle(fontWeight: FontWeight.w500),
          suggestionListDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadiusDirectional.circular(8)
          ),
          decoration: InputDecoration(
            hintText: 'Digite sua mensagem...',
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.send,
                size: 22,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(16),
              style: IconButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
              onPressed: () {
                final controller = key.currentState!.controller!;
                if (controller.text.isNotEmpty) {
                  final user = _groupsProvider.currentUser!;
                  final message = Message(
                    senderId: user.id!,
                    senderName: user.nomeUsuario!,
                    text: controller.text,
                    hasSeen: [_groupsProvider.currentUser!.id!],
                    timestamp: DateTime.now(),
                  );
                  _groupsProvider.sendGroupMessage(groupId, message).whenComplete(() {
                    _scrollDown();
                    final ids = widget.participantes.where((p) => p.id != user.id).map((u) => u.id).nonNulls.toSet().toList();
                    _groupsProvider.sendGroupMessageNotification(
                        groupName: widget.group.nome!,
                        username: user.nomeUsuario!,
                        comment: message.text,
                        ids: ids
                    );
                  });
                  if(controller.text.toLowerCase().contains('@éden')) {
                    _sendAiChatMessage(message.text).whenComplete(() => _scrollDown());
                  }
                  controller.clear();
                }
              },
            ),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
            focusedBorder:
            const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
            errorBorder:
            const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
            focusedErrorBorder:
            const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
            enabledBorder:
            const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
          ),
          mentions: [
            Mention(
                trigger: '@',
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600
                ),
                data: [
                  {
                    'id': '1',
                    'display': 'Éden',
                    'full_name': 'Éden',
                    'photo': 'assets/images/eden.jpeg'
                  },
                ],
                matchAll: false,
                suggestionBuilder: (data) {
                  return Container(
                    width: 150,
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage: AssetImage(
                            data['photo'],
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          '@${data['display']}',
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600
                          ),
                        )
                      ],
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat do Grupo')),
      backgroundColor: Theme.of(context).primaryColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(child: groupMessageList(widget.group.id!, constraints)),
              groupMessageInput(widget.group.id!),
            ],
          );
        },
      ),
    );
  }
}