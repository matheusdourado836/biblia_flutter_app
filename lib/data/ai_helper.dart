import 'package:biblia_flutter_app/models/group.dart';
import 'package:firebase_ai/firebase_ai.dart';

class AiHelper {
  static ChatSession? _chatSessionInstance;
  static GenerativeModel? _modelInstance;
  static GenerativeModel? _groupModelInstance;

  void initializeAi() {
    _initModel();
  }

  void initializeGroupAi(Group group, {List<String>? participants}) {
    _initGroupModel(group, participants: participants);
  }

  static ChatSession get chat {
    if(_chatSessionInstance == null) {
      return _modelInstance!.startChat(
          safetySettings: [
            SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium, null),
          ],
          generationConfig: GenerationConfig()
      );
    }

    return _chatSessionInstance!;
  }

  static GenerativeModel get model {
    if(_modelInstance == null) {

    }

    return _modelInstance!;
  }

  void _initModel() {
    _modelInstance = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      safetySettings: [
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium, null),
      ],
      systemInstruction: Content.system('Seu nome é Éden e você é uma assistente do aplicativo BibleWise focado em fornecer respostas relacionadas à Bíblia e temas bíblicos. '
        'Evite discutir qualquer outro tópico que não seja relacionado ao conteúdo bíblico. '
        'Sempre que for citar uma passagem bíblica coloque esse símbolo "~" antes da referência da passagem e depois. '
        'Não utilize "*" antes e depois dos textos.'
      ),
      generationConfig: GenerationConfig()
    );
  }

  void _initGroupModel(Group group, {List<String>? participants}) {
    _groupModelInstance = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash',
        safetySettings: [
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium, null),
        ],
        systemInstruction: Content.system('Seu nome é Éden e você faz parte de um chat do grupo ${group.nome} e seu objetivo é ajudar os particpantes no plano de leitura deles. '
            'Evite discutir qualquer outro tópico que não seja relacionado ao conteúdo bíblico ou do grupo. '
            'Estes são os participantes do grupo: ${participants?.join(', ')}. '
            'Caso algum usuário solicite qualquer informação sobre o grupo, você pode utilizar esse JSON como referência ${group.simpleJson()}. '
            'Você pode utilizar o nome de quem fez a pergunta nas suas respostas para deixar a conversa mais humanizada. '
            'Considere esta data ${DateTime.now().toIso8601String()} para referências de data ou para perguntas sobre o inicio e o fim do plano de leitura. '
        ),
        generationConfig: GenerationConfig()
    );
  }

  void initChat(List<Content>? history) {
    _chatSessionInstance = _modelInstance!.startChat(
        history: history,
        safetySettings: [
          SafetySetting(
              HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium, null),
        ],
        generationConfig: GenerationConfig()
    );
  }

  void initGroupChat(List<Content>? history) {
    _chatSessionInstance = _groupModelInstance!.startChat(
        history: history,
        safetySettings: [
          SafetySetting(
              HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium, null),
        ],
        generationConfig: GenerationConfig()
    );
  }
}