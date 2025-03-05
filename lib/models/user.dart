import 'group.dart';

class MyUser {
  final String? id;
  final String? email;
  String? nomeUsuario;
  String? profilePhotoUrl;
  String? fcmToken;
  List<Group>? gruposParticipantes;

  MyUser({
    this.id,
    this.email,
    this.nomeUsuario,
    this.profilePhotoUrl,
    this.fcmToken,
    this.gruposParticipantes,
  });

  factory MyUser.fromJson(Map<String, dynamic> json) {
    return MyUser(
      id: json['id'] as String,
      email: json['email'],
      nomeUsuario: json['username'] as String,
      fcmToken: json['fcmToken'],
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
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
    };
  }
}