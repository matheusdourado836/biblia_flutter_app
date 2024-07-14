import 'package:biblia_flutter_app/services/devocional_service.dart';
import 'package:biblia_flutter_app/services/thematic_service.dart';
import 'package:flutter/material.dart';
import '../models/devocional.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DevocionalProvider extends ChangeNotifier {
  static final DevocionalService _service = DevocionalService();
  static final ThematicService _thematicService = ThematicService();
  List<Devocional> _devocionais = [];

  List<Devocional> get devocionais => _devocionais;

  List<ThematicDevocional> _thematicDevocionais = [];

  List<ThematicDevocional> get thematicDevocionais => _thematicDevocionais;

  List<Devocional> _pendingDevocionais = [];

  List<Devocional> get pendingDevocionais => _pendingDevocionais;

  List<Comentario> _comments = [];

  List<Comentario> get comments => _comments;

  bool isLoading = false;

  List<String> _tutorials = [];

  List<String> get tutorials => _tutorials;

  Future<void> getDevocionais() async {
    isLoading = true;
    notifyListeners();
    _devocionais = [];
    _devocionais = await _service.getDevocionais();
    _devocionais.sort((a, b) => b.qtdCurtidas?.compareTo(a.qtdCurtidas ?? 0) ?? 0);
    isLoading = false;
    notifyListeners();
    return;
  }

  Future<void> getUserDevocionais() async {
    isLoading = true;
    notifyListeners();
    _devocionais = [];
    _devocionais = await _service.getUserDevocionais();
    isLoading = false;
    notifyListeners();
    return;
  }

  Future<void> getThematicDevocionais() async {
    isLoading = true;
    _thematicDevocionais = [];
    _thematicDevocionais = await _thematicService.getDevocionais();
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

  Future<void> reportComment({required Report report}) async {
    return await _service.reportComment(report: report);
  }

  Future<String> postDevocional({required Devocional devocional}) async {
    return await _service.postDevocional(devocional: devocional);
  }

  Future<void> updateUserData(String devocionalId, Map<String, dynamic> info) async {
    return await _service.updateUserData(devocionalId, info);
  }

  Future<void> likePost({required String postId, required bool like}) async {
    return await _service.likePost(postId: postId, like: like);
  }

  Future<bool> checkIfPostIsLiked({required String postId}) async {
   return await _service.checkIfPostIsLiked(postId: postId);
  }

  Future<void> countView(String devocionalId, String ownerDevocionalId) async {
    return await _service.countView(devocionalId, ownerDevocionalId);
  }

  Future<void> getCompletedTutorials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _tutorials = prefs.getStringList('tutorials') ?? [];
    notifyListeners();
  }

  Future<void> markTutorial(int tutorialNumber) async {
    if(!_tutorials.contains('tutorial $tutorialNumber')) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _tutorials.add('tutorial $tutorialNumber');
      prefs.setStringList('tutorials', _tutorials);
    }
  }
}
