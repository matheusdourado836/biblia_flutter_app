import 'dart:io';

import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DevocionalService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<Devocional>> getDevocionais() async {
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
      print('NAO FOI POSSIVEL RECUPERAR OS DEVOCIONAIS $e');
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
      print('NAO FOI POSSIVEL RECUPERAR OS DEVOCIONAIS $e');
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
      print('NAO FOI POSSIVEL RECUPERAR OS COMENTÁRIOS $e');
      return [];
    }
  }

  Future<void> postComment({required String devocionalId, required Comentario comentario}) async {
    final commentJson = comentario.toJson();
    await _database.collection('devocionais').doc(devocionalId).collection('comentarios').add(commentJson);
    _database.collection('devocionais').doc(devocionalId).update({'qtdComentarios': FieldValue.increment(1)});
  }

  Future<String> postDevocional({required Devocional devocional}) async {
    try {
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
      _database.collection('devocionais').doc(docRef.id).collection('comentarios');

      return docRef.id;
    }catch(e) {
      print('NAO FOI POSSIVEL SALVAR O DEVOCIONAL $e');
      return '';
    }
  }

  Future<void> updateUserData(String id, Map<String, dynamic> info) async {
    return await _database.collection('devocionais').doc(id).update(info);
  }

  Future<void> likePost({required String userId, required String postId, required bool like}) async {
    return (like)
        ? await _database.collection('devocionais').doc(postId).collection('curtidas').doc(userId).set({})
        : await _database.collection('devocionais').doc(postId).collection('curtidas').doc(userId).delete();
  }

  Future<bool> checkIfPostIsLiked({required String userId, required String postId}) async {
    bool isLiked = false;
    await _database.collection('devocionais').doc(postId).collection('curtidas').doc(userId).get().then((res) {
      if(res.exists) {
        isLiked = true;
      }
    });

    return isLiked;
  }
}