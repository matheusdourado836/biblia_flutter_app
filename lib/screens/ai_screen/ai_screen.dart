import 'dart:convert';
import 'package:biblia_flutter_app/data/ai_helper.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/helpers/alert_dialog.dart';
import 'package:biblia_flutter_app/screens/ai_screen/ad_dialog.dart';
import 'package:biblia_flutter_app/services/ad_mob_service.dart';
import 'package:biblia_flutter_app/services/bible_service.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/bible_data.dart';
import '../../data/theme_provider.dart';
import '../../helpers/go_to_verse_screen.dart';
import '../../themes/theme_colors.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  RewardedAd? _rewardedAd;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode(debugLabel: 'TextField');
  final List<Content> _contents = [];
  int _qtdQuestions = 0;
  bool _loading = false;

  void loadAd() {
    RewardedAd.load(
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
          onAdFailedToLoad: (LoadAdError error) {

          }
      )
    );
  }

  @override
  void initState() {
    super.initState();
    loadAd();
    _chat = AiHelper.chat;
    getAvailableQuestions();
    _loadChatHistory();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? chatHistoryJson = prefs.getString('chat_history');

    if (chatHistoryJson != null) {
      final List<dynamic> decodedHistory = jsonDecode(chatHistoryJson);
      for (var item in decodedHistory) {
        final role = item['role'];
        final parts = (item['parts'] as List<dynamic>)
            .map((part) => TextPart(part['text']))
            .toList();
        _contents.add(Content(role, parts));
      }
    }
    setState(() {_chat;});
    _scrollDown();
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('available_questions', _qtdQuestions);
    final List<Map<String, dynamic>> historyToSave = _contents.map((msg) => {
      'role': msg.role,
      'parts': msg.parts.map((part) => {'text': (part as TextPart).text}).toList(),
    }).toList();
    await prefs.setString('chat_history', jsonEncode(historyToSave));
  }

  Future<void> _deleteHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _contents.clear();
    });
    await prefs.remove('chat_history').whenComplete(() => Navigator.pop(context));
  }

  Future<void> getAvailableQuestions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _qtdQuestions = prefs.getInt('available_questions') ?? 5;
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = _contents;
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
                    'Essta ação não poderá ser desfeita.'
                ),
                actions: [
                  TextButton(onPressed: (() => _deleteHistory()), child: const Text('Sim')),
                  TextButton(onPressed: (() => Navigator.pop(context)), child: const Text('Não')),
                ],
              )
              );
            },
            icon: const Icon(Icons.delete_forever_rounded)
          )
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
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
                Expanded(
                    child: history.isEmpty
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
                                'Quer fazer uma pergunta? Ficarei feliz em ajudar 😃', style: TextStyle(color: Colors.black),),
                          )
                        ],
                      ),
                    )
                        : SelectionArea(
                      child: ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(12.0),
                        itemCount: history.length,
                        itemBuilder: (context, idx) {
                          final content = history[idx];
                          final text = content.parts
                              .whereType<TextPart>()
                              .map<String>((e) => e.text)
                              .join('');
                          return MessageWidget(
                            text: text,
                            isFromUser: content.role == 'user',
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
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
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
    );
  }
  void _sendChatMessage(String message) {
    BibleService().checkInternetConnectivity().then((res) async {
      if(res) {
        setState(() => _loading = true);
        String text = '';

        try {
          final response = await _chat.sendMessage(
            Content.text(message),
          );
          text = response.text ?? '';

          if (text.isEmpty) {
            _showError('Resposta vazia.');
            return;
          } else {
            setState(() {
              _qtdQuestions--;
              _loading = false;
              _contents.add(Content('user', [TextPart(message)]));
              _contents.add(Content('model', [TextPart(text)]));
              _scrollDown();
            });
            _saveChatHistory();
          }
        } catch (e) {
          _showError(e.toString());
          setState(() => _loading = false);
        } finally {
          _textController.clear();
          setState(() {
            _loading = false;
          });

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
  });

  final String text;
  final bool isFromUser;

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
              vertical: 15,
              horizontal: 20,
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildFormattedText(context),
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
            )
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
                      style: themeColors.verseNumberColor(themeProvider.isOn),
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
