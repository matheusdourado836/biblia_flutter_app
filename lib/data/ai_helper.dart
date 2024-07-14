import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiHelper {
  static ChatSession? _chatSessionInstance;
  static GenerativeModel? _modelInstance;
  static String? token = dotenv.env['GEMINI_TOKEN'];

  void initializeAi() {
    _initModel();
    _initChat();
  }

  static ChatSession get chat {
    if(_chatSessionInstance == null) {
    }

    return _chatSessionInstance!;
  }

  static GenerativeModel get model {
    if(_modelInstance == null) {

    }

    return _modelInstance!;
  }

  void _initModel() {
    _modelInstance = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: token!,
        systemInstruction: Content.system('Seu nome é Éden e você é uma assistente do aplicativo BibleWise focado em fornecer respostas relacionadas à Bíblia e temas bíblicos. '
            'Evite discutir qualquer outro tópico que não seja relacionado ao conteúdo bíblico. '
            'Sempre que for citar uma passagem bíblica coloque esse símbolo "~" antes da referência da passagem e depois. '
            'Não utilize "*" antes e depois dos textos.')
    );
  }

  void _initChat() {
    _chatSessionInstance = _modelInstance!.startChat(
        safetySettings: [
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        ],
        generationConfig: GenerationConfig()
    );
  }
}