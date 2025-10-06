import 'dart:io';
import 'dart:math';
import 'package:biblia_flutter_app/models/ai_message.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/group.dart';
import '../models/message.dart';
import '../models/user.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<MyUser?> getLoggedUser() async {
    try {
      MyUser? user;
      if(_auth.currentUser == null) {
        return null;
      }
      await _database.collection("users").doc(_auth.currentUser?.uid ?? "").get().then((DocumentSnapshot doc) async {
        if(doc.exists) {
          final dbUser = doc.data() as Map<String, dynamic>;
          user = MyUser.fromJson(dbUser);
          final fcmToken = Platform.isIOS ? await _messaging.getAPNSToken() : await _messaging.getToken();
          await updateUserData({"fcmToken": fcmToken}, user!.id!);
        }
      });

      return user;
    }catch(e, stack) {
      print('Nao foi possivel recuperar o usuario $e /// $stack');
      return null;
    }
  }

  Future<MyUser?> getUserById({required String id}) async {
    try {
      MyUser? user;
      await _database.collection("users").doc(id).get().then((DocumentSnapshot doc) async {
        if(doc.exists) {
          final dbUser = doc.data() as Map<String, dynamic>;
          user = MyUser.fromJson(dbUser);
        }
      });

      return user;
    }catch(e) {
      print('Nao foi possivel recuperar o usuario pelo ID $e');
      return null;
    }
  }

  Future<List<Group>> getUserGroups() async {
    try {
      List<Group> groups = [];

      final ownerQuery = _database
          .collection('groups')
          .where("ownerId", isEqualTo: _auth.currentUser!.uid)
          .get();

      final participantsQuery = _database
          .collection('groups')
          .where("participantes", arrayContains: _auth.currentUser!.uid)
          .get();

      // Executar ambas as consultas em paralelo
      final results = await Future.wait([ownerQuery, participantsQuery]);

      // Combinar resultados e remover duplicados
      final combinedDocs = {
        for (var doc in results.expand((snapshot) => snapshot.docs)) doc.id: doc
      };

      for (var doc in combinedDocs.values) {
        final data = doc.data();
        groups.add(Group.fromJson(data));
      }

      return groups;
    } catch (e) {
      print('Não foi possível recuperar os grupos do usuário: $e');
      return [];
    }
  }

  Future<List<String>?> getAllUsersTokens({required List<String> ids}) async {
    List<String>? usersTokens = [];
    await _database.collection('users').where('id', whereIn: ids).get().then((res) {
      if(res.docs.isNotEmpty) {
        final docs = res.docs;
        for(var doc in docs) {
          final data = doc.data();
          usersTokens.add(data["fcmToken"]);
        }
      }
    });

    return usersTokens;
  }

  Future<bool> registerUser({required MyUser user, required String pass}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: user.email!, password: pass);
      if(credential.user != null) {
        await _auth.currentUser!.updateDisplayName(user.nomeUsuario);
        final fcmToken = Platform.isIOS ? await _messaging.getAPNSToken() : await _messaging.getToken();
        await _database.collection('users').doc(_auth.currentUser!.uid).set(user.toJson());
        await _database.collection('users').doc(_auth.currentUser!.uid).update({
          "id": _auth.currentUser!.uid,
          "fcmToken": fcmToken,
          "createdAt": FieldValue.serverTimestamp(),
        });
        user.id = _auth.currentUser!.uid;
        if(user.profilePhotoUrl?.isNotEmpty ?? false) {
          await updateUserProfilePicture(user);
        }
        return true;
      }

      return false;
    }catch(e) {
      print('Nao foi possivel criar um usuario $e');
      return false;
    }
  }

  Future<List<MyUser>?> getUsersById({required List<String> ids}) async {
    try {
      List<MyUser> users = [];
      await _database.collection('users').where(FieldPath.documentId, whereIn: ids).get().then((res) {
        if(res.docs.isNotEmpty) {
          for(var doc in res.docs) {
            users.add(MyUser.fromJson(doc.data()));
          }
        }
      });

      return users;
    }catch(e) {
      print('Nao foi possivel recuperar os usuarios pelo ID $e');
      return null;
    }
  }

  Future<UserCredential> doLogin({required String email, required String pass}) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: pass);
  }

  Future<void> updateUsername({required String newUsername}) async {
    await updateUserData({"username": newUsername}, _auth.currentUser!.uid);
    return await _auth.currentUser!.updateDisplayName(newUsername);
  }

  Future<void> _clearImages(String path) async {
    final files = await _storage.ref().child(path).listAll();
    if(files.items.isNotEmpty) {
      await files.items.first.delete();
    }
    return;
  }

  Future<bool> updateUserProfilePicture(MyUser user) async {
    Future<void> setImage(String? photoURL) async {
      user.profilePhotoUrl = photoURL;
      await _auth.currentUser!.updatePhotoURL(photoURL);
      await updateUserData({'profilePhotoUrl': photoURL}, user.id!);
    }
    try {
      if(user.profilePhotoUrl?.isEmpty ?? true) {
        await _clearImages('users/${user.id!}');
        await setImage('');
        return true;
      }
      final file = File(user.profilePhotoUrl!);
      final fileName = file.path.split('/').last;
      final timeStamp = DateTime.now().microsecondsSinceEpoch;
      final uploadRef = _storage.ref().child('users/${user.id!}/$timeStamp-$fileName');
      await _clearImages('users/${user.id!}');
      await uploadRef.putFile(file);

      String photoURL = await uploadRef.getDownloadURL();
      await setImage(photoURL);
      return true;
    }on FirebaseException catch(e) {
      print('Não foi possível atualizar a imagem ${e.message}');
      return false;
    }
  }

  Future<Object?> reauthenticateUser(String email, String password) async {
    try{
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch(e) {
      print('Nao foi possivel reautenticar $e');
      return e;
    }
  }

  Future<void> deleteAccount() async {
    await _database.collection('users').doc(_auth.currentUser!.uid).delete();
    return await _auth.currentUser!.delete();
  }

  Future<void> doLogout() async => await _auth.signOut();

  Future<bool> changePassword({required String newPassword}) async {
    try {
      await _auth.currentUser!.updatePassword(newPassword);

      return true;
    }catch(e) {
      print('Nao foi possivel alterar a senha $e');
      return false;
    }
  }

  Future<void> resetPassword(String email) async {
    return await _auth.sendPasswordResetEmail(email: email);
  }

  Future<bool> checkIfUsernameIsAvailable({required String username}) async {
    final querySnapshot = await _database.collection('users').where('username', isEqualTo: username).get();

    return querySnapshot.docs.isEmpty;
  }

  Future<void> updateDailyReading({
      required String groupId,
      required String dayId,
      required String chapterId,
      required String userId,
      required bool isRead,
   }) async {
    final docRef = _database.collection('groups').doc(groupId);
    try {
      if (isRead) {
        // Marca como lido → adiciona o userId à lista do capítulo
        await docRef.update({
          'dailyReading.dias.$dayId.capitulos.$chapterId': FieldValue.arrayUnion([userId])
        });
      } else {
        // Desmarca → remove o userId da lista do capítulo
        await docRef.update({
          'dailyReading.dias.$dayId.capitulos.$chapterId': FieldValue.arrayRemove([userId])
        });
      }
    } catch (e) {
      print("Erro ao atualizar leitura: $e");
    }
  }

  Future<void> markAllChaptersRead({
    required String groupId,
    required String dayId,
    required int chapterIds,
    required String userId
  }) async {
    final docRef = _database.collection('groups').doc(groupId);
    final batch = _database.batch();

    for (int i = 0; i < chapterIds; i++) {
      batch.update(docRef, {
        'dailyReading.dias.$dayId.capitulos.${i + 1}': FieldValue.arrayUnion([userId])
      });
    }
    await batch.commit();
  }

  Future<bool> createGroup({required Group group}) async {
    try{
      final ref = await _database.collection('groups').add(group.toJson());
      await _database.collection('groups').doc(ref.id).update({"id": ref.id});
      group.id = ref.id;
      if(group.bgUrl?.isNotEmpty ?? false) {
        await uploadGroupPicture(group);
      }

      return true;
    }catch(e) {
      print('Nao foi possivel criar o grupo $e');
      return false;
    }
  }


  Future<bool> uploadGroupPicture(Group group) async {
    Future<void> setImage(String? photoURL) async {
      group.bgUrl = photoURL;
      await updateGroupData({'bgUrl': photoURL}, group.id!);
    }
    try {
      if(group.bgUrl?.isEmpty ?? true) {
        await _clearImages('groups/${group.id!}');
        await setImage('');
        return true;
      }
      final file = File(group.bgUrl!);
      final fileName = file.path.split('/').last;
      final timeStamp = DateTime.now().microsecondsSinceEpoch;
      final uploadRef = _storage.ref().child('groups/${group.id!}/$timeStamp-$fileName');
      await _clearImages('groups/${group.id!}');
      await uploadRef.putFile(file);

      String photoURL = await uploadRef.getDownloadURL();
      await setImage(photoURL);
      return true;
    }on FirebaseException catch(e) {
      print('Não foi possível atualizar a imagem ${e.message}');
      return false;
    }
  }

  Future<String> gerarCodigoGrupo() async {
    String generateCode() {
      final random = Random();
      return List.generate(4, (_) => random.nextInt(10)).join();
    }
    String code = generateCode();
    final querySnapshot = await _database
        .collection('groups')
        .get();
    List<String> codigos = [];
    for(var docs in querySnapshot.docs) {
      if(docs.exists) {
        final data = docs.data();
        codigos.add(data["code"].toString());
      }
    }

    if(codigos.isNotEmpty) {
      while(codigos.contains(code)) {
        code = generateCode();
      }
    }

    return code;
  }

  Future<void> deleteGroup({required String groupId, String? groupBgUrl}) async {
    if(groupBgUrl != null) {
      await _storage.refFromURL(groupBgUrl).delete();
    }
    return await _database.collection('groups').doc(groupId).delete();
  }

  Future<void> sendGroupMessage(String groupId, Message message) async {
    final chatRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('chat');

    await chatRef.add(message.toJson());
  }

  //TODO: TROCAR FCMTOKENS POR IDS DOS PARTICIPANTES E REMOVER O ID DE QUEM ESTA ENVIANDO A MENSAGEM
  Future<void> sendGroupMessageNotification({
    required String groupName,
    required String username,
    required String comment,
    required List<String> fcmTokens
  }) async {
    final HttpsCallable callable = _functions.httpsCallableFromUri(Uri.parse('https://sendgroupmessagenotification-693460458631.us-central1.run.app'));
    try {
      await callable.call({
        'groupName': groupName,
        'username': username,
        'comment': comment,
        'fcmTokens': fcmTokens,
      });
      return;
    } catch (e) {
      print('Erro: $e');
    }
  }

  Stream<List<Message>> getGroupMessages(String groupId) {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('chat')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Message.fromJson(doc.data()))
        .toList());
  }
  
  Future<void> markMessagesAsRead({required String groupId}) async {
    final userId = _auth.currentUser!.uid;
    await _database.collection('groups').doc(groupId).collection('chat').where('hasSeen', whereNotIn: [userId]).get().then((res) async {
      if(res.docs.isNotEmpty) {
        final docs = res.docs;
        for(var doc in docs) {
          if(doc.exists) {
            List<String>? hasSeen = (doc.data()['hasSeen'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
            hasSeen.add(userId);
            await _database.collection('groups').doc(groupId).collection('chat').doc(doc.id).update({"hasSeen": hasSeen});
          }
        }
      }
    });

    return;
  }

  Future<Group?> getGroupById({required String groupId}) async {
    try {
      Group? group;
      await _database.collection('groups').where('id', isEqualTo: groupId).get().then((res) async {
        if(res.docs.isNotEmpty) {
          final docs = res.docs;
          final data = docs.first.data();
          if(data.isNotEmpty) {
            group = Group.fromJson(data);
          }
        }
      });

      return group;
    }catch(e) {
      print('Nao foi possivel recuperar o grupo pelo ID $e');
      return null;
    }
  }

  Future<Group?> getGroupByCode({required int code}) async {
    try{
      Group? group;
      await _database.collection('groups').where('code', isEqualTo: code).get().then((res) async {
        if(res.docs.isNotEmpty) {
          final docs = res.docs;
          final data = docs.first.data();
          if(data.isNotEmpty) {
            group = Group.fromJson(data);
          }
        }
      });

      return group;
    }catch(e, stack) {
      print('Nao foi possivel recuperar o grupo pelo codigo $e /// $stack');
      return null;
    }
  }

  Future<List<Invite>?> getInvites({required String groupId}) async {
    try {
      List<Invite> invites = [];
      await _database.collection('groups').doc(groupId).get().then((res) {
        if(res.exists) {
          final data = res.data();
          if(data?.isNotEmpty ?? false) {
            final group = Group.fromJson(data!);
            invites.addAll(group.solicitacoes ?? []);
          }
        }
      });

      return invites;
    }catch(e) {
      print('Nao foi possivel recuperar os convites $e');
      return null;
    }
  }

  Future<bool> sendInvite({required MyUser user, required Group group}) async {
    try{
      final Invite invite = Invite(user: user, createdAt: DateTime.now());
      group.solicitacoes ??= [];
      group.solicitacoes!.add(invite);
      final List<Map<String, dynamic>> solicitacoesJson = group.solicitacoes?.map((s) => s.toJson()).toList() ?? [];
      await _database.collection('groups').doc(group.id!).update({"solicitacoes": solicitacoesJson});
      return true;
    }catch(e) {
      print('Nao foi possivel enviar um convite $e');
      return false;
    }
  }

  Future<bool> sendInviteNotification({
    required String userId,
    required String username,
    required String groupName
  }) async {
    final HttpsCallable callable = _functions.httpsCallable('sendInvitenotification');
    try {
      final result = await callable.call({
        'userId': userId,
        'username': username,
        'groupName': groupName,
      });
      if (result.data['success']) {
        print('Notificação enviada com sucesso');
        return true;
      } else {
        print('Erro ao enviar notificação: ${result.data['error']}');
        return false;
      }
    } catch (e) {
      print('Erro: $e');
      return false;
    }
  }

  Future<void> updateUserData(Map<String, dynamic> info, String id) async {
    return await _database.collection('users').doc(id).update(info);
  }

  Future<void> updateGroupData(Map<String, dynamic> info, String id) async {
    return await _database.collection('groups').doc(id).update(info);
  }

  Future<void> saveAiChatHistory({required List<Content> chatMessages, required MyUser user}) async {
    for(final message in chatMessages) {
      final messageJson = message.toJson();
      messageJson["timestamp"] = DateTime.now().millisecondsSinceEpoch;
      await _database.collection('users').doc(_auth.currentUser!.uid).collection('chat').add(messageJson);
    }

    return;
  }

  Future<List<AiChatMessage>> loadAiChatHistory() async {
    final List<AiChatMessage> chatMessages = [];
    final chat = await _database.collection('users').doc(_auth.currentUser!.uid).collection('chat').orderBy('timestamp', descending: false).get();
    if(chat.docs.isNotEmpty) {
      final docs = chat.docs;
      for(final doc in docs) {
        final data = doc.data();
        chatMessages.add(AiChatMessage.fromMap(data));
      }
    }

    return chatMessages;
  }

  Future<void> deleteAiChatHistory() async {
    final history = await _database.collection('users').doc(_auth.currentUser!.uid).collection('chat').get();
    if(history.docs.isNotEmpty) {
      final docs = history.docs;
      for(final doc in docs) {
        await doc.reference.delete();
      }
    }

    return;
  }
}