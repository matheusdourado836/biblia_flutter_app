import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderName;
  final String text;
  final List<String>? hasSeen;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.hasSeen,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'hasSeen': hasSeen,
      'timestamp': timestamp.toUtc(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['senderId'],
      senderName: json['senderName'],
      text: json['text'],
      hasSeen: (json['hasSeen'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}