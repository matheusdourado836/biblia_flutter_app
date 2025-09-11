import 'group.dart';

class MyUser {
  String? id;
  final String? email;
  String? nomeUsuario;
  String? profilePhotoUrl;
  int? qtdQuestionsLeft;
  String? fcmToken;
  List<Group>? gruposParticipantes;

  MyUser({
    this.id,
    this.email,
    this.nomeUsuario,
    this.profilePhotoUrl,
    this.qtdQuestionsLeft,
    this.fcmToken,
    this.gruposParticipantes,
  });

  factory MyUser.fromJson(Map<String, dynamic> json) {
    return MyUser(
      id: json['id'],
      email: json['email'],
      nomeUsuario: json['username'],
      fcmToken: json['fcmToken'],
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      qtdQuestionsLeft: json['qtdQuestionsLeft'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': nomeUsuario,
      'profilePhotoUrl': profilePhotoUrl,
      'fcmToken': fcmToken,
      'gruposParticipantes': gruposParticipantes?.map((g) => g.toJson()).toList(),
      'qtdQuestionsLeft': qtdQuestionsLeft,
    };
  }
}