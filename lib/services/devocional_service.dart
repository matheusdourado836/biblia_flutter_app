import 'dart:io';
import 'package:biblia_flutter_app/helpers/alert_dialog.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DevocionalService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

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
      alertDialog(title: 'Erro', content: 'Não foi possível carregar os devocionais\n${e.toString()}');
      return [];
    }
  }

  Future<List<Devocional>> getUserDevocionais() async {
    try {
      final userId = _auth.currentUser!.uid;
      List<Devocional> devocionais = [];
      await _database.collection('devocionais').where('ownerId', isEqualTo: userId).get().then((res) {
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

  Future<List<Devocional>> getDevocionaisById({required String id}) async {
    try {
      List<Devocional> devocionais = [];
      await _database.collection('devocionais').where('ownerId', isEqualTo: id).get().then((res) {
        if(res.docs.isNotEmpty) {
          final docs = res.docs;
          for(var doc in docs) {
            if(doc.exists) {
             devocionais.add(Devocional.fromJson(doc.data()));
            }
          }
        }
      });

      return devocionais;
    }catch(e) {
      alertDialog(title: 'Erro', content: 'Não foi possível recuperar o devocional ${e.toString()}');
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
    final userId = _auth.currentUser?.uid;
    final commentJson = comentario.toJson();
    commentJson["autorId"] = userId;
    try {
      final HttpsCallable callable = _functions.httpsCallableFromUri(Uri.parse('https://sendcommentnotification-693460458631.us-central1.run.app'));
      callable.call({'comment': commentJson, 'postId': devocionalId});
    }catch(e) {
      print('Erro ao enviar notificação: $e');
    }
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
      final devocionalJson = devocional.toJson();
      devocionalJson["bgImagem"] = "";
      final docRef = await _database.collection('devocionais').add(devocionalJson);
      if(devocional.bgImagem != null) {
        final fileName = devocional.bgImagem!.split('/').last;
        final bgRef = _storage.ref().child('devocionais/${docRef.id}/bgImage/$fileName');
        await bgRef.putFile(File(devocional.bgImagem!));
        String photoURL = await bgRef.getDownloadURL();
        updateDevocionalData(docRef.id, {'bgImagem': photoURL});
      }

      _database.collection('devocionais').doc(docRef.id).update({'id': docRef.id});
      _database.collection('devocionais').doc(docRef.id).collection('comentarios');

      return docRef.id;
    }catch(e) {
      alertDialog(title: 'Erro', content: 'Não foi possível salvar seu devocional. Tente novamente mais tarde.\n${e.toString()}');
      return '';
    }
  }

  Future<void> updateDevocionalData(String devocionalId, Map<String, dynamic> info) async {
    return await _database.collection('devocionais').doc(devocionalId).update(info);
  }

  Future<void> likePost({required String postId, required bool like}) async {
    final userId = _auth.currentUser?.uid;
    if(userId == null) return;
    if(like) {
      final HttpsCallable callable = _functions.httpsCallable('sendPostLikedNotification');
      try {
        await callable.call({'postId': postId, 'userId': userId});
      }catch(e) {
        print('Erro ao enviar notificação: $e');
      }
    }
    return (like)
        ? await _database.collection('devocionais').doc(postId).collection('curtidas').doc(userId).set({})
        : await _database.collection('devocionais').doc(postId).collection('curtidas').doc(userId).delete();
  }

  Future<bool> checkIfPostIsLiked({required String postId}) async {
    final userId = _auth.currentUser?.uid;
    if(userId == null) return false;
    bool isLiked = false;
    await _database.collection('devocionais').doc(postId).collection('curtidas').doc(userId).get().then((res) {
      if(res.exists) {
        isLiked = true;
      }
    });

    return isLiked;
  }

  Future<void> countView(String devocionalId, String ownerDevocionalId) async {
    final userId = _auth.currentUser?.uid;
    if(userId == null) return;
    if(userId != ownerDevocionalId) {
      _database.collection('devocionais').doc(devocionalId).update({'qtdViews': FieldValue.increment(1)});
    }
  }
  
  Future<void> sendReview({required Devocional devocional, required String argument}) async {
    await _database.collection('toReview').add({"devocionalId": devocional.id, "argument": argument});
    return;
  }

  Future<void> deletePost(String devocionalId) async {
    final bgImageData = await _storage.ref().child('devocionais/$devocionalId/bgImage').listAll();
    final bgUserImageData = await _storage.ref().child('devocionais/$devocionalId/bgUserImage').listAll();
    if(bgImageData.items.isNotEmpty) {
      for (var item in bgImageData.items) {
        await item.delete();
      }
    }
    if(bgUserImageData.items.isNotEmpty) {
      for (var item in bgUserImageData.items) {
        await item.delete();
      }
    }

    return await _database.collection('devocionais').doc(devocionalId).delete();
  }
}