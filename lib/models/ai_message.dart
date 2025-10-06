import 'package:firebase_ai/firebase_ai.dart';

class AiChatMessage {
  String? id;
  String? role;
  List<Part>? parts;
  int? timestamp;

  AiChatMessage({
    this.id,
    this.role,
    this.parts,
    this.timestamp,
  });

  factory AiChatMessage.fromMap(Map<String, dynamic> data) {
    return AiChatMessage(
      role: data['role'] ?? '',
      parts: (data['parts'] as List<dynamic>).map((p) => TextPart(p['text'])).toList(),
      timestamp: data['timestamp'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'parts': [
        {'text': parts},
      ],
      'timestamp': timestamp,
    };
  }
}