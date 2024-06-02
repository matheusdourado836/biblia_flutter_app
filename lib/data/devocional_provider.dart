import 'package:biblia_flutter_app/services/devocional_service.dart';
import 'package:flutter/material.dart';

import '../models/devocional.dart';

class DevocionalProvider extends ChangeNotifier {
  static final DevocionalService _service = DevocionalService();
  List<Devocional> _devocionais = [];

  List<Devocional> get devocionais => _devocionais;

  List<Devocional> _pendingDevocionais = [];

  List<Devocional> get pendingDevocionais => _pendingDevocionais;

  List<Comentario> _comments = [];

  List<Comentario> get comments => _comments;

  bool isLoading = false;

  Future<void> getDevocionais() async {
    isLoading = true;
    _devocionais = [];
    _devocionais = await _service.getDevocionais();
    isLoading = false;
    notifyListeners();
  }

  Future<void> getPendingDevocionais() async {
    isLoading = true;
    _pendingDevocionais = [];
    _pendingDevocionais = await _service.getPendingDevocionais();
    isLoading = false;
    notifyListeners();
  }

  Future<void> getComments({required String devocionalId}) async {
    isLoading = true;
    _comments = [];
    _comments = await _service.getComments(devocionalId: devocionalId);
    isLoading = false;
    notifyListeners();
  }

  Future<void> postComment({required String devocionalId, required Comentario comentario}) async {
    final devocional = _devocionais.where((devocional) => devocional.id! == devocionalId).first;
    devocional.qtdComentarios = devocional.qtdComentarios! + 1;
    return await _service.postComment(devocionalId: devocionalId, comentario: comentario).whenComplete(() => getComments(devocionalId: devocionalId));
  }

  Future<String> postDevocional({required Devocional devocional}) async {
    return await _service.postDevocional(devocional: devocional).whenComplete(() => getDevocionais());
  }

  Future<void> updateUserData(String id, Map<String, dynamic> info) async {
    return await _service.updateUserData(id, info);
  }

  Future<void> likePost({required String userId, required String postId, required bool like}) async {
    return await _service.likePost(userId: userId, postId: postId, like: like);
  }

  Future<bool> checkIfPostIsLiked({required String userId, required String postId}) async {
   return await _service.checkIfPostIsLiked(userId: userId, postId: postId);
  }
}
