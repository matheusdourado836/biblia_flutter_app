import 'dart:math';
import 'package:biblia_flutter_app/data/ai_helper.dart';
import 'package:biblia_flutter_app/data/user_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/helpers/alert_dialog.dart';
import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:biblia_flutter_app/models/ai_message.dart';
import 'package:biblia_flutter_app/screens/ai_screen/ad_dialog.dart';
import 'package:biblia_flutter_app/services/ad_mob_service.dart';
import 'package:biblia_flutter_app/services/bible_service.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../data/bible_data.dart';
import '../../data/theme_provider.dart';
import '../../helpers/go_to_verse_screen.dart';
import '../../themes/theme_colors.dart';
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
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  ChatSession? _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode(debugLabel: 'TextField');
  final ValueNotifier<String?> dayLabel = ValueNotifier(null);
  List<Content> _history = [];
  int _qtdQuestions = 0;
  bool _loading = false;
  bool requireLabel = false;

  Future<void> loadAd() async {
    await RewardedAd.load(
      adUnitId: AdMobService.rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {}
            );
            _rewardedAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {}
      )
    );
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdMobService.aiInterstitialAdId!,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _showInterstitialAd();
          },
          onAdFailedToLoad: (error) => _interstitialAd = null,
        )
    );
  }

  void _showInterstitialAd() {
    if(_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) => ad.dispose(),
        onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose()
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  bool showAd() {
    Random random = Random();

    int randomInt = random.nextInt(3);

    bool showAd = randomInt == 1;

    return showAd;
  }

  @override
  void initState() {
    super.initState();
    eventBus.on().listen((event) {
      if(event == 'Refresh') {
        setState(() {
          _chatHistoryFuture = _loadChatHistory();
        });
      }
    });
    if(showAd()) {
      _createInterstitialAd();
    }
    loadAd();
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
    Navigator.pop(context);
    return;
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
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
                                      onTap: () => _rewardedAd?.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
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
                            onTap: () => _rewardedAd?.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
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
          print('ERRO AO ENVIAR MENSAGEM: $e /// STACK $stack');
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

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.text,
    required this.isFromUser,
    required this.timestamp
  });

  final String text;
  final bool isFromUser;
  final int? timestamp;

  Widget _buildFormattedText(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final darkMode = !themeProvider.isOn;
    final List<InlineSpan> children = [];
    final RegExp regExp = RegExp(r'\*\s*\*\*(.*?)\*\*');

    int start = 0;

    regExp.allMatches(text).forEach((match) {
      final String plainText = text.substring(start, match.start);
      final String boldText = match.group(1)!;
      children.add(TextSpan(text: plainText));
      children.add(TextSpan(
        text: '\n$boldText'.trimRight(),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ));
      start = match.end;
    });

    if (start < text.length) {
      children.add(TextSpan(text: text.substring(start)));
    }

    return Text.rich(
      textWidthBasis: TextWidthBasis.longestLine,
      TextSpan(
        style: TextStyle(
          fontFamily: 'Poppins',
          color: isFromUser ? Colors.white : (darkMode) ? const Color.fromRGBO(255, 255, 255, 0.85) : Colors.black,
          fontSize: 16,
          height: 1.4
        ),
        children: children,
      ),
    );
  }

  Widget _timestampWidget(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final darkMode = !themeProvider.isOn;
    return Text(
      DateTime.fromMillisecondsSinceEpoch(timestamp ?? 0).formattedShort(),
      style: TextStyle(
        fontSize: 10,
        color: isFromUser ? Colors.white70 : (darkMode) ? Colors.white70 : Colors.black54,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final RegExp passageRegExp = RegExp(r'~(.*?)~');
    final passageMatches = passageRegExp
        .allMatches(text)
        .expand((match) => match.group(1)!.split(';'))
        .map((e) => e.trim())
        .map((passage) {
          if (!RegExp(r'\d+:\d+').hasMatch(passage)) {
            final parts = passage.split(RegExp(r'\s+'));
            if (parts.length > 1 && RegExp(r'^\d+$').hasMatch(parts.last)) {
              parts.last += ':1';
              return parts.join(' ');
            }
          }
          return passage;
        })
        .where((passage) => RegExp(r'\d+:\d+').hasMatch(passage))
        .toSet()
        .toList();
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth >= 500 ? 600 : 300),
            decoration: BoxDecoration(
              color: isFromUser
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildFormattedText(context),
                _timestampWidget(context)
              ],
            ),
          ),
          if (passageMatches.isNotEmpty)
            Container(
              width: constraints.maxWidth,
              height: 50,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: passageMatches.length,
                itemBuilder: (context, idx) {
                  final passage = passageMatches[idx];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final List<dynamic> list = BibleData().data[0]["text"];
                        String bookName = (passage.split(' ')[0].contains('ª') || passage.split(' ')[0].contains('º') || passage.split(' ')[0].contains('°') || RegExp(r'^\d+$').hasMatch(passage.split(' ')[0]))
                            ? '${passage.split(' ')[0]} ${passage.split(' ')[1]}'
                            : passage.split(' ')[0];
                        int chapter = (passage.split(' ')[0].contains('ª') || passage.split(' ')[0].contains('º') || passage.split(' ')[0].contains('°') || RegExp(r'^\d+$').hasMatch(passage.split(' ')[0]))
                            ? int.parse(passage.split(' ')[2].split(':')[0])
                            : int.parse(passage.split(' ')[1].split(':')[0]);
                        String verse = passage.split(':')[1];
                        int start = 0;
                        int end = 0;
                        if(verse.contains('-')) {
                          start = int.parse(verse.split('-')[0]);
                          end = int.parse(verse.split('-')[1]);
                        }else {
                          start = int.parse(verse);
                          end = start;
                        }
                        final bookInfo = list.where((element) => element['name'] == bookName).toList();
                        final sublist = bookInfo[0]["chapters"][chapter - 1].sublist(start - 1, end);
                        showDialog(
                            context: context,
                            useRootNavigator: false,
                            builder: (BuildContext context) {
                              return VerseDialog(
                                width: constraints.maxWidth * .6,
                                height: constraints.maxWidth >= 500 ? 350 : 200,
                                bookName: bookName,
                                chapter: chapter,
                                verse: (end == start) ? '$start' : '$start-$end',
                                verses: sublist.toList(),
                              );
                            });
                      },
                      child: Text(passage),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    });
  }
}

class VerseDialog extends StatelessWidget {
  final double width;
  final double height;
  final String bookName;
  final int chapter;
  final String verse;
  final List<dynamic> verses;
  const VerseDialog({super.key, required this.bookName, required this.chapter, required this.verse, required this.verses, required this.width, required this.height});

  static ThemeColors themeColors = ThemeColors();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0),
      title: Container(
          height: 90,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadiusDirectional.only(topStart: Radius.circular(26), topEnd: Radius.circular(26))
          ),
          child: Stack(
            children: [
              Center(
                child: Text('$bookName $chapter:$verse', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white,),
                ),
              )
            ],
          )
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      content: SelectionArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for(var i = 0; i < verses.length; i++)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text.rich(TextSpan(
                      text: '${int.parse(verse.contains('-') ? verse.split('-')[0] : verse) + i}  ',
                      style: themeColors.coloredVerse(themeProvider.isOn),
                      children: <TextSpan>[
                        TextSpan(text: verses[i], style: themeColors.verseColor(themeProvider.isOn))
                      ]
                  )
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: (() {
              final versesProvider = Provider.of<VersesProvider>(context, listen: false);
              final List<dynamic> list = BibleData().data[0]["text"];
              final bookInfo = list.where((element) => element['name'] == bookName).toList();
              int verseNumber = int.parse(verse.contains('-') ? verse.split('-')[0] : verse);
              versesProvider.clear();
              versesProvider.loadVerses(list.indexOf(bookInfo.first), bookName);
              GoToVerseScreen().goToVersePage(
                bookName,
                bookInfo[0]['abbrev'],
                list.indexOf(bookInfo.first),
                bookInfo[0]['chapters'].length,
                chapter,
                verseNumber
              );
            }),
            child: const Text('Ler completo')
          ),
        )
      ],
    );
  }
}
