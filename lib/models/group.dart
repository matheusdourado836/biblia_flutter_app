import 'package:biblia_flutter_app/models/user.dart';

import 'daily_read.dart';

class Group {
  String? id;
  String? ownerId;
  int? code;
  String? nome;
  String? descricao;
  String? bgUrl;
  List<String>? participantes;
  List<Invite>? solicitacoes;
  int? maxPeople;
  String? plan;
  List<String>? books;
  GroupDailyReading? dailyReading;
  DateTime? createdAt;
  DateTime? startDate;
  DateTime? endDate;

  Group({
    this.id,
    this.ownerId,
    this.code,
    this.nome,
    this.descricao,
    this.bgUrl,
    this.participantes,
    this.solicitacoes,
    this.maxPeople,
    this.plan,
    this.books,
    this.dailyReading,
    this.createdAt,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'nome': nome,
      'code': code,
      'descricao': descricao,
      'bgUrl': bgUrl,
      'participantes': participantes?.toSet().toList(),
      'solicitacoes': solicitacoes?.toSet().map((s) => s.toJson()).toList(),
      'maxPeople': maxPeople,
      'plan': plan,
      'books': books,
      'dailyReading': dailyReading?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String?,
      ownerId: json['ownerId'] as String?,
      code: json['code'],
      nome: json['nome'] as String?,
      descricao: json['descricao'] as String?,
      bgUrl: json['bgUrl'] as String?,
      participantes: List<String>.from(json['participantes'] ?? []),
      solicitacoes: (json['solicitacoes'] as List<dynamic>?)?.map((e) => Invite.fromJson(e)).toList() ?? [],
      maxPeople: json['maxPeople'],
      plan: json['plan'] as String?,
      books: (json['books'] as List<dynamic>?)?.map((e) => e as String).toList(),
      dailyReading: json["dailyReading"] == null ? null : GroupDailyReading.fromJson(json["dailyReading"]),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }
}

class Invite {
  String? id;
  MyUser? user;
  DateTime? createdAt;

  Invite({
    this.id,
    this.user,
    this.createdAt
  });

  factory Invite.fromJson(Map<String, dynamic> json) => Invite(
    id: json['id'],
    user: json['user'] == null ? null : MyUser.fromJson(json["user"]),
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user": user?.toJson(),
    'createdAt': createdAt?.toIso8601String(),
  };
}