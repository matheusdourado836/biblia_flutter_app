import 'package:biblia_flutter_app/models/user.dart';
import 'package:biblia_flutter_app/services/reading_group_service.dart';
import 'package:flutter/material.dart';
import '../models/daily_read.dart';
import '../models/group.dart';
import '../models/message.dart';

class ReadingGroupsProvider extends ChangeNotifier {
  static final ReadingGroupService _service = ReadingGroupService();
  MyUser? currentUser;
  bool loading = false;
  int unreadMessages = 0;

  void newMessage(List<Message> messages) {
    unreadMessages = messages.where((m) => !(m.hasSeen?.contains(currentUser!.id!) ?? true)).length;
    notifyListeners();
  }

  Future<void> getUser() async {
    currentUser = await _service.getLoggedUser();
    if(currentUser?.id != null) {
      await getUserGroups();
    }
    notifyListeners();
  }

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
    await getUser();
    notifyListeners();
  }

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

  Future<void> deleteGroup({required String groupId}) async {
    return await _service.deleteGroup(groupId: groupId);
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

  Future<Group?> getGroupByCode({required int code}) async {
    return await _service.getGroupByCode(code: code, user: currentUser!);
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
      sendInviteNotification(
          userId: group.ownerId!,
          username: currentUser!.nomeUsuario!,
          groupName: group.nome!
      );
      return await _service.sendInvite(user: currentUser!, group: group);
    }

    return true;
  }

  Future<void> sendInviteNotification({
    required String userId,
    required String username,
    required String groupName
  }) async {
    return await _service.sendInviteNotification(
        userId: userId,
        username: username,
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

  Future<void> updateDailyReading(GroupDailyReading dailyReading, String groupId) async {

    final updatedData = dailyReading.toJson();
    return await updateGroupData({"dailyReading": updatedData}, groupId);
  }
}