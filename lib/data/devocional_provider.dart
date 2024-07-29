import 'package:biblia_flutter_app/services/devocional_service.dart';
import 'package:biblia_flutter_app/services/thematic_service.dart';
import 'package:flutter/material.dart';
import '../models/devocional.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DevocionalProvider extends ChangeNotifier {
  static final DevocionalService _service = DevocionalService();
  static final ThematicService _thematicService = ThematicService();
  List<Devocional>? _devocionais = [];

  List<Devocional>? get devocionais => _devocionais;

  List<ThematicDevocional> _thematicDevocionais = [];

  List<ThematicDevocional> get thematicDevocionais => _thematicDevocionais;

  List<Devocional> _pendingDevocionais = [];

  List<Devocional> get pendingDevocionais => _pendingDevocionais;

  List<Comentario> _comments = [];

  List<Comentario> get comments => _comments;

  bool isLoading = false;

  bool isLoadingThematic = false;

  List<String> _tutorials = [];

  List<String> get tutorials => _tutorials;

  Future<void> getDevocionais({int? limit}) async {
    isLoading = true;
    notifyListeners();
    _devocionais = [];
    _devocionais = await _service.getDevocionais(limit: limit);
    if(_devocionais?.isNotEmpty ?? false) {
      _devocionais!.sort((a, b) => b.qtdCurtidas! > a.qtdCurtidas! ? 0 : 1);
      _devocionais!.sort((a, b) {
        final createdDateA = DateTime.parse(a.createdAt!);
        final createdDateB = DateTime.parse(b.createdAt!);

        if(DateTime.now().difference(createdDateA).inHours <= 24) {
          final differenceA = DateTime.now().difference(createdDateA);
          final differenceB = DateTime.now().difference(createdDateB);
          if(differenceB.inHours <= 24) {
            return differenceA.inMinutes.compareTo(differenceB.inMinutes);
          }

          return 0;
        }

        return 1;
      });
    }
    isLoading = false;
    notifyListeners();
    return;
  }

  Future<void> getUserDevocionais() async {
    isLoading = true;
    notifyListeners();
    _devocionais = [];
    _devocionais = await _service.getUserDevocionais();
    if(_devocionais?.isNotEmpty ?? false) {
      _devocionais!.sort((a, b) {
        final createdDateA = DateTime.parse(a.createdAt!);
        final createdDateB = DateTime.parse(b.createdAt!);
        if(createdDateA.day == createdDateB.day && createdDateA.month == createdDateB.month && createdDateA.year == createdDateB.year) {
          return a.qtdCurtidas! > b.qtdCurtidas! ? 0 : 1;
        }
        return createdDateA.isBefore(createdDateB) ? 1 : 0;
      });
    }
    isLoading = false;
    notifyListeners();
    return;
  }

  Future<void> getThematicDevocionais() async {
    if(_thematicDevocionais.isEmpty) {
      isLoadingThematic = true;
      notifyListeners();
      _thematicDevocionais = await _thematicService.getDevocionais();
      isLoadingThematic = false;
      notifyListeners();
    }
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
    final devocional = _devocionais!.where((devocional) => devocional.id! == devocionalId).first;
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

  Future<void> sendReview({required Devocional devocional, required String argument}) async {
    return await _service.sendReview(devocional: devocional, argument: argument);
  }

  Future<void> deletePost(String devocionalId) async {
    return await _service.deletePost(devocionalId);
  }
}
