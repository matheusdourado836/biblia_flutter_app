import 'package:biblia_flutter_app/helpers/alert_dialog.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ThematicService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  DocumentSnapshot<Object?>? lastQuery;

  Future<List<ThematicDevocional>> getDevocionais() async {
    Query<Map<String, dynamic>> executeQuery = (lastQuery == null)
        ? _database.collection('jornada_espiritual')
        : _database.collection('jornada_espiritual').startAfterDocument(lastQuery!).limit(3);
    try {
      List<ThematicDevocional> thematicDevocionais = [];
      await _database.collection('jornada_espiritual').get().then((res) {
        if(res.docs.isNotEmpty) {
          final docs = res.docs;
          lastQuery = docs.last;
          for(var devocional in docs) {
            if(devocional.exists) {
              thematicDevocionais.add(ThematicDevocional.fromJson(devocional.data()));
            }
          }
        }
      });

      return thematicDevocionais;
    }catch(e) {
      alertDialog(title: 'Erro', content: 'Não foi possível recuperar os devocionais\n${e.toString()}');
      return [];
    }
  }
}