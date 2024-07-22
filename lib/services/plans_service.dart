import 'package:biblia_flutter_app/models/enums.dart';
import 'package:biblia_flutter_app/models/plan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PlansService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<List<Plan>?> getPlans() async {
    List<Plan> plans = [];
    QuerySnapshot<Map<String, dynamic>>? docs;
    docs = await _database.collection('plans').get().then((res) {
      if(res.docs.isNotEmpty) {
        for(var doc in res.docs) {
          if(doc.exists) {
            plans.add(Plan.fromJson(doc.data()));
          }
        }
      }

      return res;
    });

    if(docs == null) {
      return null;
    }

    return plans;
  }

  Future<void> subscribeUser({required PlanType planType}) async {
    final userToken = await _firebaseMessaging.getToken().catchError((e) => throw e);
    await _database.collection('${planType.description}_subs').doc(userToken).set({'user_token': userToken, 'created_at': FieldValue.serverTimestamp()});
  }

  Future<void> unsubscribeUser({required PlanType planType}) async {
    final userToken = await _firebaseMessaging.getToken().catchError((e) => throw e);
    return await _database.collection('${planType.description}_subs').doc(userToken).delete();
  }
}