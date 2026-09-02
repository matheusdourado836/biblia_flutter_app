import 'package:biblia_flutter_app/helpers/alert_dialog.dart';
import 'package:biblia_flutter_app/helpers/app_logger.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThematicService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  Future<List<ThematicDevocional>> getDevocionais() async {
    try {
      final res = await _database.collection('jornada_espiritual').get();

      return res.docs
          .where((doc) => doc.exists)
          .map((doc) => ThematicDevocional.fromJson(doc.data()))
          .toList();
    } catch (e, stack) {
      logError('Não foi possível recuperar os devocionais temáticos', e, stack);
      alertDialog(
        title: 'Erro',
        content: 'Não foi possível recuperar os devocionais\n${e.toString()}',
      );
      return [];
    }
  }
}
