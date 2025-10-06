import 'package:biblia_flutter_app/models/ai_message.dart';
import 'package:biblia_flutter_app/models/user.dart';
import 'package:biblia_flutter_app/services/user_service.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/message.dart';
import 'bible_data.dart';

class UserProvider extends ChangeNotifier {
  static final BibleData _bibleData = BibleData();
  static final UserService _service = UserService();
  MyUser? currentUser;
  bool loading = false;
  int unreadMessages = 0;

  List<Map<String, dynamic>> get bibleData => _bibleData.data;

  List<AiChatMessage> _chatMessages = [];

  List<AiChatMessage> get chatMessages => _chatMessages;

  void newMessage(List<Message> messages) {
    unreadMessages = messages.where((m) => !(m.hasSeen?.contains(currentUser!.id!) ?? true)).length;
    notifyListeners();
  }

  Future<void> getLoggedUser() async {
    currentUser = await _service.getLoggedUser();
    if(currentUser?.id != null) {
      await getUserGroups();
    }
    notifyListeners();
  }

  Future<MyUser?> getUserById({required String id}) async => await _service.getUserById(id: id);

  Future<void> getUserGroups({bool notify = false}) async {
    loading = true;
    notifyListeners();
    currentUser!.gruposParticipantes = await _service.getUserGroups();
    loading = false;
    if(notify) {
      notifyListeners();
    }
  }

  Future<List<MyUser>?> getUsersById({required List<String> ids}) async {
    return await _service.getUsersById(ids: ids);
  }

  Future<bool> registerUser({required MyUser user, required String pass}) async {
    final res = await _service.registerUser(user: user, pass: pass);
    notifyListeners();
    return res;
  }

  Future<void> doLogin({required String email, required String pass}) async {
    await _service.doLogin(email: email, pass: pass);
    await getLoggedUser();
    notifyListeners();
  }

  Future<bool> updateUserProfilePicture(MyUser user) async => await _service.updateUserProfilePicture(user);

  Future<void> updateUsername({required String newUsername}) async {
    currentUser!.nomeUsuario = newUsername;
    return await _service.updateUsername(newUsername: newUsername);
  }

  Future<Object?> reauthenticateUser(String email, String password) async {
    return await _service.reauthenticateUser(email, password);
  }

  Future<void> deleteAccount() async {
    currentUser = null;
    return await _service.deleteAccount();
  }

  Future<void> doLogout() async {
    currentUser = null;
    return await _service.doLogout();
  }

  Future<void> updateUserData(Map<String, dynamic> info) async {
    return await _service.updateUserData(info, currentUser!.id!);
  }

  Future<bool> changePassword({required String newPassword}) async {
    return await _service.changePassword(newPassword: newPassword);
  }

  Future<void> resetPassword(String email) async {
    return await _service.resetPassword(email);
  }

  Future<bool> checkIfUsernameIsAvailable({required String username}) async {
    return await _service.checkIfUsernameIsAvailable(username: username);
  }

  Future<bool> createGroup({required Group group}) async {
    final code = await _gerarCodigoGrupo();
    group.code = int.parse(code);
    return await _service.createGroup(group: group);
  }

  Future<void> updateGroupData(Map<String, dynamic> info, String id) async {
    return await _service.updateGroupData(info, id);
  }

  Future<bool> uploadGroupPicture(Group group) async {
    return await _service.uploadGroupPicture(group).whenComplete(() => notifyListeners());
  }

  Future<void> deleteGroup({required String groupId, String? groupBgUrl}) async {
    return await _service.deleteGroup(groupId: groupId, groupBgUrl: groupBgUrl);
  }

  Future<String> _gerarCodigoGrupo() async {
    return await _service.gerarCodigoGrupo();
  }

  Future<void> sendGroupMessage(String groupId, Message message) async {
    return await _service.sendGroupMessage(groupId, message);
  }

  Future<void> sendGroupMessageNotification({
    required String groupName,
    required String username,
    required String comment,
    required List<String> ids
  }) async {
    final fcmTokens = await _service.getAllUsersTokens(ids: ids) ?? [];
    return await _service.sendGroupMessageNotification(
      groupName: groupName,
      username: username,
      comment: comment,
      fcmTokens: fcmTokens
    );
  }

  Stream<List<Message>> getGroupMessages(String groupId) {
    return _service.getGroupMessages(groupId);
  }

  Future<void> markMessagesAsRead({required String groupId}) async {
    return await _service.markMessagesAsRead(groupId: groupId);
  }

  Future<Group?> getGroupById({required String groupId}) async => _service.getGroupById(groupId: groupId);

  Future<Group?> getGroupByCode({required int code}) async {
    return await _service.getGroupByCode(code: code);
  }

  Future<void> leaveGroup({required Group group}) async {
    group.participantes!.remove(currentUser!.id!);
    return await _service.updateGroupData({"participantes": group.participantes}, group.id!);
  }

  Future<List<Invite>?> getInvites({required String groupId}) async {
    loading = true;
    notifyListeners();
    return await _service.getInvites(groupId: groupId).whenComplete(() => loading = false);
  }

  Future<bool> sendInvite({required Group group}) async {
    bool inviteAlreadyExists = group.solicitacoes?.where((i) => i.user?.id == currentUser!.id).isEmpty ?? true;
    bool userIsOwner = group.ownerId == currentUser!.id!;
    if(inviteAlreadyExists || userIsOwner) {
      return await _service.sendInvite(user: currentUser!, group: group);
    }

    return false;
  }

  Future<bool> sendInviteNotification({
    required String userId,
    required String groupName
  }) async {
    return await _service.sendInviteNotification(
        userId: userId,
        username: currentUser!.nomeUsuario!,
        groupName: groupName
    );
  }
  
  Future<void> confirmSolicitation({required Group group, required Invite invite}) async {
    group.participantes ??= [];
    group.participantes!.add(invite.user!.id!);
    group.solicitacoes!.remove(invite);
    final solicitacoesJson = group.solicitacoes!.map((s) => s.toJson()).toList();
    await _service.updateGroupData({
      "participantes": group.participantes,
      "solicitacoes": solicitacoesJson
    },
      group.id!
    );
    notifyListeners();
  }

  Future<void> rejectSolicitation({required Group group, required Invite invite}) async {
    group.solicitacoes!.remove(invite);
    final solicitacoesJson = group.solicitacoes!.map((s) => s.toJson()).toList();
    await _service.updateGroupData({"solicitacoes": solicitacoesJson}, group.id!);
    notifyListeners();
  }

  Future<void> updateDailyReading({
    required String groupId,
    required String dayId,
    required String chapterId,
    required String userId,
    required bool isRead,
  }) async {
    return await _service.updateDailyReading(
      groupId: groupId,
      dayId: dayId,
      chapterId: chapterId,
      userId: userId,
      isRead: isRead,
    );
  }

  Future<void> markAllChaptersRead({
    required String groupId,
    required String dayId,
    required int chapterIds,
    required String userId
  }) async {
    return await _service.markAllChaptersRead(
      groupId: groupId,
      dayId: dayId,
      chapterIds: chapterIds,
      userId: userId
    );
  }

  Future<void> saveAiChatHistory(List<Content> history) async {
    return await _service.saveAiChatHistory(chatMessages: history, user: currentUser!);
  }

  Future<void> loadAiChatHistory() async {
    _chatMessages = await _service.loadAiChatHistory();
    return;
  }

  Future<void> deleteAiChatHistory() async {
    return await _service.deleteAiChatHistory();
  }
}