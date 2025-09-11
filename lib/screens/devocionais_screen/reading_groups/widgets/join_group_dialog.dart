import 'package:biblia_flutter_app/data/user_provider.dart';
import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JoinGroupDialog extends StatefulWidget {
  const JoinGroupDialog({super.key});

  @override
  State<JoinGroupDialog> createState() => _JoinGroupDialogState();
}

class _JoinGroupDialogState extends State<JoinGroupDialog> {
  late final UserProvider _groupsProvider = Provider.of<UserProvider>(context, listen:  false);
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _error = ValueNotifier(false);
  String _errorMessage = '';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Insira o código do grupo'),
      content: ValueListenableBuilder(
          valueListenable: _error,
          builder: (context, value, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                      hintText: 'Digite o código aqui...'
                  ),
                ),
                if(_error.value)
                  Text(_errorMessage, style: const TextStyle(color: Colors.red))
              ],
            );
          }
      ),
      actions: [
        if(_loading)
          const CircularProgressIndicator()
        else
          TextButton(
            onPressed: () async {
              setState(() => _loading = true);
              final res = await _groupsProvider.getGroupByCode(code: int.parse(_controller.text));
              setState(() => _loading = false);
              if(res != null) {
                if((res.participantes?.length ?? 0) == res.maxPeople) {
                  _error.value = true;
                  _errorMessage = 'Este grupo está lotado.';
                  return;
                }
                if(res.participantes?.contains(_groupsProvider.currentUser!.id!) ?? false) {
                  _error.value = true;
                  _errorMessage = 'Você já faz parte deste grupo.';
                  return;
                }
                final inviteRes = await _groupsProvider.sendInvite(group: res);
                if(inviteRes) {
                  _groupsProvider.sendInviteNotification(
                      userId: res.ownerId!,
                      groupName: res.nome!
                  );
                  Navigator.pop(context);
                  showCustomSnackBar(child: const Text('Sua solicitação foi enviada com sucesso!'));
                }else {
                  _error.value = true;
                  _errorMessage = 'Houve um erro ao enviar sua solicitação.';
                }
              }else {
                _error.value = true;
                _errorMessage = 'grupo não encontrado';
              }
            },
            child: const Text('Enviar pedido')
          )
      ],
    );
  }
}
