import 'package:biblia_flutter_app/data/ai_helper.dart';
import 'package:biblia_flutter_app/data/user_provider.dart';
import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:biblia_flutter_app/models/user.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/group.dart';
import '../../../models/message.dart';

class ChatScreen extends StatefulWidget {
  final Group group;
  final List<MyUser> participantes;
  const ChatScreen({super.key, required this.group, required this.participantes});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin{
  late final UserProvider _groupsProvider = Provider.of<UserProvider>(context, listen: false);
  late final AnimationController _controller = AnimationController(vsync: this);
  static final AiHelper _aiHelper = AiHelper();
  GlobalKey<FlutterMentionsState> key = GlobalKey<FlutterMentionsState>();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool darkMode = false;
  bool isTyping = false;
  List<Message> messages = [];

  void _animation() {
    if(_controller.isCompleted) {
      Future.delayed(1000.ms, () => _controller.repeat());
    }
  }

  @override
  void initState() {
    _aiHelper.initializeGroupAi(widget.group, participants: widget.participantes.map((p) => p.nomeUsuario!).toList());
    _controller.addListener(_animation);
    WidgetsBinding.instance.addPostFrameCallback((_) => darkMode = Theme.of(context).brightness == Brightness.dark);
    super.initState();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.removeListener(_animation);
    super.dispose();
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
                        child: Markdown(
                          data: message.text,
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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

        messages = snapshot.data!;
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
    final history = messages.reversed.map((m) => Content(
        m.senderId.isEmpty ? 'model' : 'user',
        [TextPart(m.text)]
    )).toList();

    _aiHelper.initGroupChat(history);
    final chat = AiHelper.chat;
    String text = '';
    String defaultPrompt = 'se apresente para os usuários';
    try {
      setState(() => isTyping = true);
      final username = _groupsProvider.currentUser!.nomeUsuario!;
      final userMessage = '$username enviou esta mensagem - ${message.replaceAll('@Eden', '')}';
      final response = await chat.sendMessage(
          Content.text(userMessage)
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
    }finally {
      setState(() => isTyping = false);
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

  Widget _animatedDots() {
    Widget dot(double delay) => Container(
      height: 5,
      width: 5,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle
      ),
    )
    .animate(controller: _controller)
    .moveY(begin: 3, end: -3, delay: delay.ms)
    .then()
    .moveY(begin: -3, end: 3)
    .then()
    .moveY(begin: 1, end: -1)
    .then()
    .moveY(begin: -1, end: 1);

    return Row(
      spacing: 4,
      children: [
        dot(0),
        dot(200),
        dot(500),
      ],
    );
  }
  
  Widget _typingBuilder() => Padding(
    padding: const EdgeInsetsGeometry.only(left: 16),
    child: Row(
      spacing: 6,
      children: [
        _animatedDots(),
        Text('Éden está digitando'),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat do Grupo')),
      backgroundColor: Theme.of(context).primaryColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: groupMessageList(widget.group.id!, constraints)),
              if(isTyping)
                _typingBuilder(),
              groupMessageInput(widget.group.id!),
            ],
          );
        },
      ),
    );
  }
}