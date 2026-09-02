import 'package:biblia_flutter_app/helpers/app_logger.dart';
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

/// O operador `whereIn` do Firestore aceita no máximo 30 valores por consulta.
const int _whereInLimit = 30;

List<List<T>> _chunk<T>(List<T> items, int size) {
  final chunks = <List<T>>[];
  for (var i = 0; i < items.length; i += size) {
    chunks.add(items.sublist(i, i + size > items.length ? items.length : i + size));
  }
  return chunks;
}

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
      logError('Nao foi possivel recuperar o usuario $e /// $stack');
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
      logError('Nao foi possivel recuperar o usuario pelo ID $e');
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
      logError('Não foi possível recuperar os grupos do usuário: $e');
      return [];
    }
  }

  Future<List<String>?> getAllUsersTokens({required List<String> ids}) async {
    final usersTokens = <String>[];
    if (ids.isEmpty) return usersTokens;

    for (final batch in _chunk(ids, _whereInLimit)) {
      final res = await _database.collection('users').where('id', whereIn: batch).get();
      for (final doc in res.docs) {
        final token = doc.data()["fcmToken"];
        if (token is String && token.isNotEmpty) usersTokens.add(token);
      }
    }

    return usersTokens;
  }

  Future<bool> registerUser({required MyUser user, required String pass}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: user.email!, password: pass);
      if(credential.user != null) {
        // A reserva só é possível depois do login. Se o nome foi tomado entre a
        // checagem na tela e agora, desfazemos a conta recém-criada.
        final claimed = await _claimUsername(user.nomeUsuario ?? '');
        if (!claimed) {
          await _auth.currentUser!.delete();
          return false;
        }
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
      logError('Nao foi possivel criar um usuario $e');
      return false;
    }
  }

  Future<List<MyUser>?> getUsersById({required List<String> ids}) async {
    try {
      final users = <MyUser>[];
      if (ids.isEmpty) return users;

      for (final batch in _chunk(ids, _whereInLimit)) {
        final res = await _database
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        for (final doc in res.docs) {
          users.add(MyUser.fromJson(doc.data()));
        }
      }

      return users;
    }catch(e, stack) {
      logError('Nao foi possivel recuperar os usuarios pelo ID', e, stack);
      return null;
    }
  }

  Future<UserCredential> doLogin({required String email, required String pass}) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: pass);
  }

  /// Devolve false quando o nome foi tomado no meio do caminho. O antigo só é
  /// liberado depois que o novo está reservado, para não ficar sem nenhum.
  Future<bool> updateUsername({required String newUsername, String? currentUsername}) async {
    if (!await _claimUsername(newUsername)) return false;

    await updateUserData({"username": newUsername}, _auth.currentUser!.uid);
    await _auth.currentUser!.updateDisplayName(newUsername);

    if (normalizeUsername(currentUsername ?? '') != normalizeUsername(newUsername)) {
      await _releaseUsername(currentUsername);
    }

    return true;
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
      logError('Não foi possível atualizar a imagem ${e.message}');
      return false;
    }
  }

  Future<Object?> reauthenticateUser(String email, String password) async {
    try{
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch(e) {
      logError('Nao foi possivel reautenticar $e');
      return e;
    }
  }

  Future<void> deleteAccount({String? username}) async {
    await _releaseUsername(username);
    await _database.collection('users').doc(_auth.currentUser!.uid).delete();
    return await _auth.currentUser!.delete();
  }

  Future<void> doLogout() async => await _auth.signOut();

  Future<bool> changePassword({required String newPassword}) async {
    try {
      await _auth.currentUser!.updatePassword(newPassword);

      return true;
    }catch(e) {
      logError('Nao foi possivel alterar a senha $e');
      return false;
    }
  }

  Future<void> resetPassword(String email) async {
    return await _auth.sendPasswordResetEmail(email: email);
  }

  /// Índice público de nomes em uso: `usernames/{nome normalizado}` guarda
  /// apenas o uid do dono. Existe porque a coleção `users` só é legível para
  /// quem está autenticado, e a checagem precisa rodar durante o cadastro.
  static const String usernamesCollection = 'usernames';

  /// Mesma normalização na escrita e na leitura, para "Alice" e "alice"
  /// ocuparem a mesma chave.
  static String normalizeUsername(String username) => username.trim().toLowerCase();

  Future<bool> checkIfUsernameIsAvailable({required String username}) async {
    final key = normalizeUsername(username);
    if (key.isEmpty) return false;

    try {
      final doc = await _database.collection(usernamesCollection).doc(key).get();

      return !doc.exists;
    } catch (e, stack) {
      logError('Não foi possível verificar a disponibilidade do username', e, stack);
      return false;
    }
  }

  /// Reserva o nome. A unicidade é garantida pelas regras: `update` é proibido
  /// em `usernames`, então um `set` sobre um nome já tomado é negado — duas
  /// pessoas não conseguem reservar o mesmo nome nem em corrida.
  Future<bool> _claimUsername(String username) async {
    final key = normalizeUsername(username);
    if (key.isEmpty) return false;

    try {
      await _database
          .collection(usernamesCollection)
          .doc(key)
          .set({'uid': _auth.currentUser!.uid});

      return true;
    } catch (e, stack) {
      logError('Não foi possível reservar o username "$key"', e, stack);
      return false;
    }
  }

  Future<void> _releaseUsername(String? username) async {
    final key = normalizeUsername(username ?? '');
    if (key.isEmpty) return;

    try {
      await _database.collection(usernamesCollection).doc(key).delete();
    } catch (e, stack) {
      logError('Não foi possível liberar o username "$key"', e, stack);
    }
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
      logError("Erro ao atualizar leitura: $e");
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
      logError('Nao foi possivel criar o grupo $e');
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
      logError('Não foi possível atualizar a imagem ${e.message}');
      return false;
    }
  }

  /// Sorteia um código livre consultando apenas o candidato, em vez de baixar
  /// todos os grupos existentes a cada criação.
  Future<String> gerarCodigoGrupo() async {
    final random = Random();
    String generateCode() => List.generate(4, (_) => random.nextInt(10)).join();

    for (var attempt = 0; attempt < 10; attempt++) {
      final code = generateCode();
      final existing = await _database
          .collection('groups')
          .where('code', isEqualTo: int.parse(code))
          .limit(1)
          .get();
      if (existing.docs.isEmpty) return code;
    }

    // Fallback improvável: mantém o comportamento anterior de sempre devolver
    // algo, mesmo que a colisão só seja detectada na escrita.
    return generateCode();
  }

  Future<void> deleteGroup({required String groupId, String? groupBgUrl}) async {
    if(groupBgUrl != null) {
      await _storage.refFromURL(groupBgUrl).delete();
    }
    return await _database.collection('groups').doc(groupId).delete();
  }

  Future<void> sendGroupMessage(String groupId, Message message) async {
    final chatRef = _database
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
      logError('Erro: $e');
    }
  }

  Stream<List<Message>> getGroupMessages(String groupId) {
    return _database
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

    // Só as mensagens que o usuário ainda não viu, e em lote: antes era um
    // update por documento a cada abertura do chat.
    final snapshot = await _database
        .collection('groups')
        .doc(groupId)
        .collection('chat')
        .get();

    final pending = snapshot.docs.where((doc) {
      final seen = doc.data()['hasSeen'];
      return seen is! List || !seen.contains(userId);
    }).toList();

    if (pending.isEmpty) return;

    // O batch do Firestore aceita até 500 operações.
    for (final group in _chunk(pending, 500)) {
      final batch = _database.batch();
      for (final doc in group) {
        batch.update(doc.reference, {
          'hasSeen': FieldValue.arrayUnion([userId]),
        });
      }
      await batch.commit();
    }
  }

  Future<Group?> getGroupById({required String groupId}) async {
    try {
      final doc = await _database.collection('groups').doc(groupId).get();
      final data = doc.data();
      if (!doc.exists || data == null || data.isEmpty) return null;

      return Group.fromJson(data);
    }catch(e) {
      logError('Nao foi possivel recuperar o grupo pelo ID $e');
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
      logError('Nao foi possivel recuperar o grupo pelo codigo $e /// $stack');
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
      logError('Nao foi possivel recuperar os convites $e');
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
      logError('Nao foi possivel enviar um convite $e');
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
        logError('Notificação enviada com sucesso');
        return true;
      } else {
        logError('Erro ao enviar notificação: ${result.data['error']}');
        return false;
      }
    } catch (e) {
      logError('Erro: $e');
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
    if (chatMessages.isEmpty) return;

    final chatRef = _database.collection('users').doc(_auth.currentUser!.uid).collection('chat');
    for (final group in _chunk(chatMessages, 500)) {
      final batch = _database.batch();
      for (final message in group) {
        final messageJson = message.toJson();
        messageJson["timestamp"] = DateTime.now().millisecondsSinceEpoch;
        batch.set(chatRef.doc(), messageJson);
      }
      await batch.commit();
    }
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
    if (history.docs.isEmpty) return;

    for (final group in _chunk(history.docs, 500)) {
      final batch = _database.batch();
      for (final doc in group) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}