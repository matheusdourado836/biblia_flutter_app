import 'dart:async';
import 'package:biblia_flutter_app/helpers/app_logger.dart';
import 'dart:math';
import 'package:biblia_flutter_app/data/ai_helper.dart';
import 'package:biblia_flutter_app/data/user_provider.dart';
import 'package:biblia_flutter_app/helpers/alert_dialog.dart';
import 'package:biblia_flutter_app/models/ai_message.dart';
import 'package:biblia_flutter_app/screens/ai_screen/ad_dialog.dart';
import 'package:biblia_flutter_app/screens/ai_screen/ai_ads_controller.dart';
import 'package:biblia_flutter_app/screens/ai_screen/widgets/message_widget.dart';
import 'package:biblia_flutter_app/services/bible_service.dart';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:intl/intl.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  Future<void>? _chatHistoryFuture;
  late final _userProvider = Provider.of<UserProvider>(context, listen:  false);
  final EventBus eventBus = EventBus();
  StreamSubscription<dynamic>? _eventBusSubscription;
  final AiAdsController _ads = AiAdsController();
  ChatSession? _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode(debugLabel: 'TextField');
  final ValueNotifier<String?> dayLabel = ValueNotifier(null);
  List<Content> _history = [];
  int _qtdQuestions = 0;
  bool _loading = false;
  bool requireLabel = false;

  @override
  void initState() {
    super.initState();
    _eventBusSubscription = eventBus.on().listen((event) {
      if (event == 'Refresh' && mounted) {
        setState(() {
          _chatHistoryFuture = _loadChatHistory();
        });
      }
    });
    if (_ads.shouldShowInterstitial) {
      _ads.loadAndShowInterstitial();
    }
    _ads.loadRewardedAd();
    _chatHistoryFuture = _loadChatHistory();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent * 2,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    },
    );
  }

  Future<void> getQuestionsCountFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _qtdQuestions = prefs.getInt('available_questions') ?? 5);
  }

  Future<void> _loadChatHistory() async {
    if(_userProvider.currentUser == null) {
      getQuestionsCountFromLocal();
      AiHelper().initChat(_history);
      _chat = AiHelper.chat;
      _history = _chat!.history.toList();
      return;
    }
    _qtdQuestions = _userProvider.currentUser!.qtdQuestionsLeft ?? 5;
    await _userProvider.loadAiChatHistory();

    if (_userProvider.chatMessages.isNotEmpty) {
      for (var item in _userProvider.chatMessages) {
        final role = item.role;
        _history.add(Content(role, item.parts ?? []));
      }
    }
    AiHelper().initChat(_history);
    _chat = AiHelper.chat;
    _history = _chat!.history.toList();
    _scrollDown();
    return;
  }

  Future<void> _saveChatHistory(List<Content> contents) async {
    _history = _chat!.history.toList();
    if(_userProvider.currentUser == null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('available_questions', _qtdQuestions);
      final randomBool = Random().nextBool();
      if(randomBool) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text.rich(TextSpan(
                    text: 'Para salvar seu histórico ',
                    children: [
                      TextSpan(
                          text: 'crie uma conta',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue,
                            decorationStyle: TextDecorationStyle.solid,
                          )
                      ),
                      TextSpan(text: ' ou '),
                      TextSpan(
                          text: 'faça login',
                          recognizer: TapGestureRecognizer()..onTap = () {
                            Navigator.pushNamed(
                                context,
                                'login_screen',
                                arguments: {"eventBus" : eventBus}
                            );
                          },
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue,
                            decorationStyle: TextDecorationStyle.solid,
                          )
                      )
                    ]
                ))
            )
        );
      }
      return;
    }
    _userProvider.saveAiChatHistory(contents);
    _userProvider.updateUserData({"qtdQuestionsLeft": _qtdQuestions});
  }

  Future<void> _deleteHistory() async {
    setState(() => _history.clear());
    if(_userProvider.currentUser != null) {
      await _userProvider.deleteAiChatHistory();
    }
    getQuestionsCountFromLocal();
    if (!mounted) return;
    Navigator.pop(context);
    return;
  }

  @override
  void dispose() {
    // A tela pode ser reaberta várias vezes; sem isto a assinatura do EventBus
    // e os controllers ficavam pendurados a cada abertura.
    _eventBusSubscription?.cancel();
    eventBus.destroy();
    _scrollController.dispose();
    _textController.dispose();
    _textFieldFocus.dispose();
    dayLabel.dispose();
    _ads.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pergunte à Éden'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(context: context, builder: (context) => AlertDialog(
                title: const Text('Deletar histórico?'),
                content: const Text('Tem certeza que deseja deletar todo seu histórico de conversa?\n'
                    'Esta ação não poderá ser desfeita.'
                ),
                actions: [
                  TextButton(onPressed: () => _deleteHistory(), child: const Text('Sim')),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Não')),
                ],
              )
              );
            },
            icon: const Icon(Icons.delete_forever_rounded)
          )
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: FutureBuilder(
        future: _chatHistoryFuture,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }else if(snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar histórico: ${snapshot.error}'),
            );
          }
          return SafeArea(
            child: TextSelectionTheme(
              data: const TextSelectionThemeData(
                selectionColor: Colors.grey,
                selectionHandleColor: Colors.black,
              ),
              child: SelectionArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Center(
                        child: Text(
                          'Éden pode gerar informação incorreta. Considere verificar informações importantes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ),
                    Center(
                      child: ValueListenableBuilder(
                        valueListenable: dayLabel,
                        builder: (context, value, _) {
                          if(value == null) return Container();

                          return Chip(
                            label: Text(
                              value,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          );
                        }
                      )
                    ),
                    Expanded(
                      child: _history.isEmpty
                          ? SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxWidth: 300),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 20,
                              ),
                              margin: const EdgeInsets.all(16),
                              child: const Text('Olá eu sou a Éden, uma assistente projetada para fornecer respostas sobre a Bíblia e temas bíblicos. '
                                'Posso ajudá-lo a entender passagens bíblicas, explicar conceitos teológicos, fornecer informações sobre personagens e eventos bíblicos, e responder perguntas sobre a fé cristã.\n'
                                'Quer fazer uma pergunta? Ficarei feliz em ajudar 😃'
                              ),
                            )
                          ],
                        ),
                      )
                          : SelectionArea(
                        child: ListView.builder(
                          controller: _scrollController,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.all(12.0),
                          itemCount: _history.length,
                          itemBuilder: (context, idx) {
                            final content = _history[idx];
                            final timestamp = _userProvider.chatMessages[idx].timestamp;
                            final currentMsgTime = DateTime.fromMillisecondsSinceEpoch(timestamp ?? 0);

                            final now = DateTime.now();
                            final today = DateTime(now.year, now.month, now.day);
                            final yesterday = today.subtract(Duration(days: 1));
                            final msgDay = DateTime(currentMsgTime.year, currentMsgTime.month, currentMsgTime.day);

                            String currentLabel;
                            if (msgDay == today) {
                              currentLabel = "Hoje";
                            } else if (msgDay == yesterday) {
                              currentLabel = "Ontem";
                            } else {
                              currentLabel = DateFormat('dd/MM/yyyy').format(currentMsgTime);
                            }

                            // Verifica se precisa exibir o chip de data
                            String? previousLabel;
                            if (idx > 0) {
                              final prevTimestamp = _userProvider.chatMessages[idx - 1].timestamp;
                              final prevMsgTime = DateTime.fromMillisecondsSinceEpoch(prevTimestamp ?? 0);
                              final prevDay = DateTime(prevMsgTime.year, prevMsgTime.month, prevMsgTime.day);

                              if (prevDay == today) {
                                previousLabel = "Hoje";
                              } else if (prevDay == yesterday) {
                                previousLabel = "Ontem";
                              } else {
                                previousLabel = DateFormat('dd/MM/yyyy').format(prevMsgTime);
                              }
                            }

                            final showDateLabel = idx == 0 || currentLabel != previousLabel;

                            // Atualiza o label fixo no topo se essa mensagem estiver visível
                            return VisibilityDetector(
                              key: ValueKey(_userProvider.chatMessages[idx].timestamp),
                              onVisibilityChanged: (info) {
                                var visiblePercentage = info.visibleFraction * 100;
                                if (visiblePercentage == 100) {
                                  // Atualiza o label fixo apenas se não for "Hoje"
                                  if (msgDay != today) {
                                    dayLabel.value = currentLabel;
                                  } else {
                                    dayLabel.value = null;
                                  }
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (showDateLabel)
                                    Center(
                                      child: Chip(
                                        label: Text(
                                          currentLabel,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  MessageWidget(
                                    text: content.parts.whereType<TextPart>().map((e) => e.text).join(''),
                                    isFromUser: content.role == 'user',
                                    timestamp: timestamp,
                                  ),
                                  if (idx == _history.length - 1)
                                    const SizedBox(height: 100),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(
                                maxHeight: 150,
                              ),
                              child: TextField(
                                controller: _textController,
                                focusNode: _textFieldFocus,
                                maxLines: null,
                                onSubmitted: (value) => _sendChatMessage(value),
                                decoration: InputDecoration(
                                  hintText: 'Digite a pergunta aqui...',
                                  fillColor: Theme.of(context).colorScheme.secondary,
                                  filled: true,
                                  focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                                  errorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                                  focusedErrorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                                  enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!_loading)
                            InkWell(
                              onTap: (() {
                                if(_qtdQuestions == 0) {
                                  showDialog(context: context, builder: (context) => AdDialog(
                                      onTap: () => _ads.showRewardedAd((AdWithoutView ad, RewardItem rewardItem) {
                                        Navigator.pop(context);
                                        setState(() => _qtdQuestions = rewardItem.amount.toInt());
                                      })
                                  )
                                  );
                                  return;
                                }
                                if(_textController.text.isNotEmpty) {
                                  _sendChatMessage(_textController.text);
                                }
                              }),
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(50)
                                ),
                                child: const Icon(Icons.send, size: 22, color: Colors.white,),
                              ),
                            )
                          else
                            const CircularProgressIndicator(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'scroll_down_button',
            onPressed: _scrollDown,
            child: const Icon(Icons.arrow_downward),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: FloatingActionButton(
              heroTag: 'qtd_questions_button',
              onPressed: _qtdQuestions == 0
                ? () {
                    showDialog(context: context, builder:
                        (context) => AdDialog(
                            onTap: () => _ads.showRewardedAd((AdWithoutView ad, RewardItem rewardItem) {
                              Navigator.pop(context);
                              setState(() => _qtdQuestions = rewardItem.amount.toInt());
                            })
                        )
                    );
                  }
                : null,
              tooltip: 'Perguntas restantes',
              child: Text(_qtdQuestions.toString(), style: const TextStyle(fontSize: 24),),
            ),
          ),
        ],
      ),
    );
  }
  void _sendChatMessage(String message) {
    BibleService().checkInternetConnectivity().then((res) async {
      if(res) {
        setState(() => _loading = true);
        String text = '';

        try {
          final response = await _chat!.sendMessage(Content.text(message));
          text = response.text ?? '';

          if (text.isEmpty) {
            _showError('Resposta vazia.');
            return;
          } else {
            setState(() {
              _qtdQuestions--;
              _loading = false;
              _scrollDown();
            });
            final userContent = Content('user', [TextPart(message)]);
            final aiContent = Content('model', [TextPart(response.text!)]);
            _userProvider.chatMessages.addAll([
              AiChatMessage(
                role: 'user',
                parts: [TextPart(message)],
                timestamp: DateTime.now().millisecondsSinceEpoch
              ),
              AiChatMessage(
                role: 'model',
                parts: [TextPart(response.text!)],
                timestamp: DateTime.now().millisecondsSinceEpoch
              )
            ]
            );
            _saveChatHistory([userContent, aiContent]);
          }
        } catch (e, stack) {
          _showError(e.toString());
          setState(() => _loading = false);
          logError('ERRO AO ENVIAR MENSAGEM: $e /// STACK $stack');
        } finally {
          _textController.clear();
          setState(() => _loading = false);

          _textFieldFocus.unfocus();
        }
      }else {
        alertDialog(content: 'É preciso estar conectado à internet para conversar com a Éden');
      }
    });
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
}
