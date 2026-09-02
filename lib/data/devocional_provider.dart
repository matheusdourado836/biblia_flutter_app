import 'package:biblia_flutter_app/services/devocional_service.dart';
import 'package:biblia_flutter_app/services/thematic_service.dart';
import 'package:biblia_flutter_app/services/user_service.dart';
import 'package:flutter/material.dart';
import '../models/devocional.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DevocionalProvider extends ChangeNotifier {
  static final DevocionalService _service = DevocionalService();
  static final UserService _userService = UserService();
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
    await _attachAuthorPhotos(_devocionais);

    if(_devocionais?.isNotEmpty ?? false) {
      final now = DateTime.now();
      // Destaques das últimas 24h primeiro (mais recentes no topo); o restante
      // por curtidas e, em empate, pelo mais recente.
      _devocionais!.sort((a, b) {
        final dateA = _parseDate(a.createdAt);
        final dateB = _parseDate(b.createdAt);
        final freshA = now.difference(dateA).inHours <= 24;
        final freshB = now.difference(dateB).inHours <= 24;

        if (freshA != freshB) return freshA ? -1 : 1;
        if (freshA && freshB) return dateB.compareTo(dateA);

        final likes = (b.qtdCurtidas ?? 0).compareTo(a.qtdCurtidas ?? 0);
        if (likes != 0) return likes;

        return dateB.compareTo(dateA);
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
      // Mais recentes primeiro; publicações do mesmo dia, mais curtidas primeiro.
      _devocionais!.sort((a, b) {
        final dateA = _parseDate(a.createdAt);
        final dateB = _parseDate(b.createdAt);
        final sameDay = dateA.year == dateB.year &&
            dateA.month == dateB.month &&
            dateA.day == dateB.day;

        if (sameDay) {
          return (b.qtdCurtidas ?? 0).compareTo(a.qtdCurtidas ?? 0);
        }

        return dateB.compareTo(dateA);
      });
    }
    isLoading = false;
    notifyListeners();
    return;
  }

  /// Busca as fotos dos autores em lote (antes era uma consulta por item).
  Future<void> _attachAuthorPhotos(List<Devocional>? devocionais) async {
    if (devocionais == null || devocionais.isEmpty) return;

    final ownerIds = devocionais
        .map((d) => d.ownerId)
        .whereType<String>()
        .toSet()
        .toList();
    if (ownerIds.isEmpty) return;

    final users = await _userService.getUsersById(ids: ownerIds) ?? [];
    final photoById = {for (final u in users) u.id: u.profilePhotoUrl};
    for (final devocional in devocionais) {
      devocional.bgImagemUser = photoById[devocional.ownerId];
    }
  }

  static DateTime _parseDate(String? value) =>
      DateTime.tryParse(value ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);

  Future<List<Devocional>> getDevocionaisById({required String id}) async => await _service.getDevocionaisById(id: id);

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

    // Uma consulta em lote no lugar de um getUserById por comentário.
    final authorIds = _comments
        .map((c) => c.autorId)
        .whereType<String>()
        .toSet()
        .toList();
    if (authorIds.isNotEmpty) {
      final users = await _userService.getUsersById(ids: authorIds) ?? [];
      final photoById = {for (final u in users) u.id: u.profilePhotoUrl};
      for (final comment in _comments) {
        comment.authorPhotoUrl = photoById[comment.autorId];
      }
    }

    _comments.sort((a, b) => _parseDate(b.createdAt).compareTo(_parseDate(a.createdAt)));
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

  Future<void> updateDevocionalData(String devocionalId, Map<String, dynamic> info) async {
    return await _service.updateDevocionalData(devocionalId, info);
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
