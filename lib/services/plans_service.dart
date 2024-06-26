import 'package:biblia_flutter_app/models/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PlansService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> subscribeUser({required PlanType planType}) async {
    final userToken = await _firebaseMessaging.getToken().catchError((e) => throw e);
    await _database.collection('${planType.description}_subs').doc(userToken).set({'user_token': userToken, 'created_at': FieldValue.serverTimestamp()});
  }

  Future<void> unsubscribeUser({required PlanType planType}) async {
    final userToken = await _firebaseMessaging.getToken().catchError((e) => throw e);
    return await _database.collection('${planType.description}_subs').doc(userToken).delete();
  }
}