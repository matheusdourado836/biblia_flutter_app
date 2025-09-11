import 'package:biblia_flutter_app/data/user_provider.dart';
import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditUsernameDialog extends StatefulWidget {
  const EditUsernameDialog({super.key});

  @override
  State<EditUsernameDialog> createState() => _EditUsernameDialogState();
}

class _EditUsernameDialogState extends State<EditUsernameDialog> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  late final UserProvider _groupsProvider = Provider.of<UserProvider>(context, listen:  false);
  final TextEditingController _nameController = TextEditingController();
  bool _loading = false;
  String _errorMsg = '';

  Future<void> updateUsername() async {
    setState(() {
      _loading = true;
      _errorMsg = '';
    });
    final groupsProvider = Provider.of<UserProvider>(context, listen:  false);
    final usernameAvailable = await groupsProvider.checkIfUsernameIsAvailable(username: _nameController.text);
    if(usernameAvailable) {
      await groupsProvider.updateUsername(newUsername: _nameController.text);
      setState(() => _loading = false);
      showCustomSnackBar(child: const Text('Nome de usuário atualizado com sucesso!')
      );
      Navigator.pop(context);
    }else {
      setState(() {
       _loading = false;
       _errorMsg = 'Este nome de usuário não está disponível';
      });
    }
  }

  @override
  void initState() {
    _nameController.text = _groupsProvider.currentUser!.nomeUsuario ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar nome de usuário'),
      content: Form(
        key: _key,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                maxLength: 35,
                validator: (value) {
                  if(value?.isEmpty ?? true) {
                    return 'O nome não pode estar vazio';
                  }

                  return null;
                },
                decoration: const InputDecoration(
                    labelText: 'Novo nome de usuário',
                    hintText: 'Digite seu novo nome de usuário'
                ),
              ),
              if(_errorMsg.isNotEmpty)
                Text(_errorMsg, style: const TextStyle(color: Colors.red))
            ],
          ),
        ),
      ),
      actions: [
        if(_loading)
          const CircularProgressIndicator()
        else
          TextButton(
            onPressed: () {
              if(_key.currentState!.validate()) {
                updateUsername();
              }
            },
            child: const Text('Salvar')
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      ],
    );
  }
}
