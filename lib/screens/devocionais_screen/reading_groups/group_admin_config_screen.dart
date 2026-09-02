import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:biblia_flutter_app/models/user.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/reading_groups/widgets/edit_group_modal.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/reading_groups/widgets/participantes_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/user_provider.dart';
import '../../../models/group.dart';

class GroupAdminConfigScreen extends StatefulWidget {
  final Group group;
  final List<MyUser> participantes;
  const GroupAdminConfigScreen({super.key, required this.group, required this.participantes});

  @override
  State<GroupAdminConfigScreen> createState() => _GroupAdminConfigScreenState();
}

class _GroupAdminConfigScreenState extends State<GroupAdminConfigScreen> {
  @override
  Widget build(BuildContext context) {
    final groupsProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações do grupo')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: () => Navigator.pushNamed(
              context,
              'solicitations_screen',
              arguments: {"group": widget.group},
            ),
            leading: Badge.count(
              count: widget.group.solicitacoes?.length ?? 0,
              child: const Icon(Icons.notifications),
            ),
            title: const Text('Solicitações'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          ListTile(
            onTap: () => showModalBottomSheet(
              context: context,
              builder: (context) => ParticipantesModal(
                participantes: widget.participantes,
                ownerId: widget.group.ownerId!,
              )
            ).then((res) {
              if(res is List<String>) {
                for(var id in res) {
                  widget.participantes.removeWhere((u) => u.id == id);
                  widget.group.participantes!.remove(id);
                }
                setState(() {});
                groupsProvider.updateGroupData({"participantes": widget.group.participantes}, widget.group.id!).whenComplete(() {
                  showCustomSnackBar(child: const Text('Usuário removido com sucesso.'));
                });
              }
            }),
            leading: Badge.count(
              count: widget.group.participantes?.length ?? 0,
              child: const Icon(Icons.people),
            ),
            title: const Text('Participantes'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          ListTile(
            onTap: () => showModalBottomSheet(
              isScrollControlled: true,
              useRootNavigator: true,
              context: context,
              builder: (context) => EditGroupModal(group: widget.group)
            ).then((res) {
              if(res ?? false) {
                showCustomSnackBar(child: const Text('Alterações salvas com sucesso!'));
              }
            }),
            leading: const Icon(Icons.edit),
            title: const Text('Editar informações'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          ListTile(
            onTap: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tem certeza que deseja deletar seu grupo?', style: TextStyle(fontSize: 18),),
                    Text('esta ação não poderá ser desfeita', style: TextStyle(fontSize: 16, color: Colors.grey),)
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      groupsProvider.deleteGroup(groupId: widget.group.id!, groupBgUrl: widget.group.bgUrl).whenComplete(() {
                        groupsProvider.getUserGroups(notify: true).whenComplete(() {
                          if (!context.mounted) return;
                          Navigator.popUntil(context, (route) => route.settings.name == 'user_home_screen');
                        });
                      });
                    },
                    child: const Text('Sim')
                  ),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Não')),
                ],
              )
            ),
            iconColor: Colors.red,
            textColor: Colors.red,
            leading: const Icon(Icons.delete),
            title: const Text('Excluir grupo'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 24),
            child: Text(
              'Tipo do plano: "${widget.group.plan}"',
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 24),
            child: Text(
              'Criado em: ${widget.group.createdAt?.formatted()}',
              textAlign: TextAlign.left,
              style: const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 24),
            child: Text(
              'Início da leitura: ${widget.group.startDate?.formatted()}',
              textAlign: TextAlign.left,
              style: const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 24),
            child: Text(
              'Fim da leitura: ${widget.group.endDate?.formatted()}',
              textAlign: TextAlign.left,
              style: const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic
              ),
            ),
          ),
          const SizedBox(height: 80),
          const Spacer(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextButton.icon(
                    onPressed: () => Clipboard.setData(
                      ClipboardData(text: widget.group.code.toString())
                    ),
                    iconAlignment: IconAlignment.end,
                    label: Text(
                      'Código do grupo: ${widget.group.code}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    icon: const Icon(Icons.copy, size: 26),
                  ),
                  const Text(
                    'Envie este código para as pessoas poderem entrar no seu grupo',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}
