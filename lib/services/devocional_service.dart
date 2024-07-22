import 'dart:io';
import 'package:biblia_flutter_app/helpers/alert_dialog.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DevocionalService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<List<Devocional>?> getDevocionais({int? limit}) async {
    try {
      List<Devocional> devocionais = [];
      QuerySnapshot<Map<String, dynamic>>? docs;
      final docRef = limit == null
        ? _database.collection('devocionais').where('status', isEqualTo: 0).where('public', isEqualTo: true)
        : _database.collection('devocionais').where('status', isEqualTo: 0).where('public', isEqualTo: true).orderBy('qtdCurtidas', descending: true).limit(limit);
      docs = await docRef.get().then((res) {
        if(res.docs.isNotEmpty) {
          final docs = res.docs;
          for(var devocional in docs) {
            if(devocional.exists) {
              devocionais.add(Devocional.fromJson(devocional.data()));
            }
          }
        }
        return res;
      });

      if(docs == null) {
        return null;
      }

      return devocionais;
    }catch(e) {
      print(e);
      alertDialog(title: 'Erro', content: 'Não foi possível carregar os devocionais\n${e.toString()}');
      return [];
    }
  }

  Future<List<Devocional>> getUserDevocionais() async {
    try {
      final userToken = await _messaging.getToken();
      List<Devocional> devocionais = [];
      await _database.collection('devocionais').where('ownerId', isEqualTo: userToken).get().then((res) {
        if(res.docs.isNotEmpty) {
          final docs = res.docs;
          for(var devocional in docs) {
            if(devocional.exists) {
              devocionais.add(Devocional.fromJson(devocional.data()));
            }

          }
        }
      });

      return devocionais;
    }catch(e) {
      alertDialog(title: 'Erro', content: 'Não foi possível recuperar seus devocionais\n${e.toString()}');
      return [];
    }
  }

  Future<List<Devocional>> getPendingDevocionais() async {
    try {
      List<Devocional> devocionais = [];
      await _database.collection('devocionais').where('status', isEqualTo: 0).get().then((res) {
        if(res.docs.isNotEmpty) {
          final docs = res.docs;
          for(var devocional in docs) {
            if(devocional.exists) {
              devocionais.add(Devocional.fromJson(devocional.data()));
            }

          }
        }
      });

      return devocionais;
    }catch(e) {
      alertDialog(title: 'Erro', content: 'Não foi possível carregar os devocionais pendentes\n${e.toString()}');
      return [];
    }
  }

  Future<List<Comentario>> getComments({required String devocionalId}) async {
    try {
      List<Comentario> comentarios = [];
      await _database.collection('devocionais').doc(devocionalId).collection('comentarios').get().then((res) {
        if(res.docs.isNotEmpty) {
          for(var doc in res.docs) {
            if(doc.exists) {
              comentarios.add(Comentario.fromJson(doc.data()));
            }
          }
        }
      });

      return comentarios;
    }catch(e) {
      alertDialog(title: 'Erro', content: 'Não foi possível carregar os comentários\n${e.toString()}');
      return [];
    }
  }

  Future<void> postComment({required String devocionalId, required Comentario comentario}) async {
    final userToken = await _messaging.getToken();
    final commentJson = comentario.toJson();
    commentJson["autorId"] = userToken;
    final docRef = await _database.collection('devocionais').doc(devocionalId).collection('comentarios').add(commentJson);
    _database.collection('devocionais').doc(devocionalId).collection('comentarios').doc(docRef.id).update({'id': docRef.id});
    _database.collection('devocionais').doc(devocionalId).update({'qtdComentarios': FieldValue.increment(1)});
  }

  Future<void> reportComment({required Report report}) async {
    final jsonReport = report.toJson();
    jsonReport["reportId"] = '';
    final docRef = await _database.collection('reports').add(jsonReport);
    _database.collection('reports').doc(docRef.id).update({"reportId": docRef.id});
  }

  Future<String> postDevocional({required Devocional devocional}) async {
    try {
      final userToken = await _messaging.getToken();
      final devocionalJson = devocional.toJson();
      devocionalJson["bgImagem"] = "";
      devocionalJson["bgImagemUser"] = "";
      final docRef = await _database.collection('devocionais').add(devocionalJson);
      if(devocional.bgImagem != null) {
        final fileName = devocional.bgImagem!.split('/').last;
        final bgRef = _storage.ref().child('devocionais/${docRef.id}/bgImage/$fileName');
        await bgRef.putFile(File(devocional.bgImagem!));
        String photoURL = await bgRef.getDownloadURL();
        updateUserData(docRef.id, {'bgImagem': photoURL});
      }
      if(devocional.bgImagemUser != null) {
        final fileName = devocional.bgImagemUser!.split('/').last;
        final userRef = _storage.ref().child('devocionais/${docRef.id}/bgUserImage/$fileName');
        await userRef.putFile(File(devocional.bgImagemUser!));
        String photoURL = await userRef.getDownloadURL();
        updateUserData(docRef.id, {'bgImagemUser': photoURL});
      }

      _database.collection('devocionais').doc(docRef.id).update({'id': docRef.id});
      _database.collection('devocionais').doc(docRef.id).update({'ownerId': userToken});
      _database.collection('devocionais').doc(docRef.id).collection('comentarios');

      return docRef.id;
    }catch(e) {
      alertDialog(title: 'Erro', content: 'Não foi possível salvar seu devocional. Tente novamente mais tarde.\n${e.toString()}');
      return '';
    }
  }

  Future<void> updateUserData(String devocionalId, Map<String, dynamic> info) async {
    return await _database.collection('devocionais').doc(devocionalId).update(info);
  }

  Future<void> likePost({required String postId, required bool like}) async {
    final userToken = await _messaging.getToken();
    return (like)
        ? await _database.collection('devocionais').doc(postId).collection('curtidas').doc(userToken).set({})
        : await _database.collection('devocionais').doc(postId).collection('curtidas').doc(userToken).delete();
  }

  Future<bool> checkIfPostIsLiked({required String postId}) async {
    final userToken = await _messaging.getToken();
    bool isLiked = false;
    await _database.collection('devocionais').doc(postId).collection('curtidas').doc(userToken).get().then((res) {
      if(res.exists) {
        isLiked = true;
      }
    });

    return isLiked;
  }

  Future<void> countView(String devocionalId, String ownerDevocionalId) async {
    final userToken = await _messaging.getToken();
    if(userToken != ownerDevocionalId) {
      _database.collection('devocionais').doc(devocionalId).update({'qtdViews': FieldValue.increment(1)});
    }
  }
}