import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiHelper {
  static ChatSession? _chatSessionInstance;
  static GenerativeModel? _modelInstance;
  static String? token = dotenv.env['GEMINI_TOKEN'];

  void initializeAi() {
    _initModel();
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

  void initChat(List<Content>? history) {
    _chatSessionInstance = _modelInstance!.startChat(
      history: history,
      safetySettings: [
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium, null),
      ],
      generationConfig: GenerationConfig()
    );
  }
}