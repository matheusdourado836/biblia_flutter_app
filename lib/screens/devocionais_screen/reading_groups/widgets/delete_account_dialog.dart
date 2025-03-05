import 'package:biblia_flutter_app/data/reading_groups_provider.dart';
import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final GlobalKey<FormState> _key = GlobalKey();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _loading = false;
  bool _hidePass = true;
  String _errorMsg = '';

  Future<void> deleteAccount() async {
    try {
      setState(() => _loading = true);
      final groupsProvider = Provider.of<ReadingGroupsProvider>(context, listen: false);
      final res = await groupsProvider.reauthenticateUser(_emailController.text, _passController.text);
      if(res is FirebaseAuthException) {
        throw FirebaseAuthException(code: res.code);
      }
      await groupsProvider.deleteAccount();
      setState(() => _loading = false);
      Navigator.popUntil(context, (route) => route.settings.name == 'devocionais_screen');
    }on FirebaseAuthException catch(e) {
      setState(() {
        _loading = false;
        _errorMsg = e.translated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Column(
        children: [
          Text('Confirme sua decisão'),
          Text(
            'digite seu email e sua senha para deletar sua conta',
            style: TextStyle(fontSize: 12),
          )
        ],
      ),
      content: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Digite seu email'
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passController,
              obscureText: _hidePass,
              decoration: InputDecoration(
                hintText: 'Digite sua senha',
                suffixIcon: IconButton(
                    onPressed: () => setState(() => _hidePass = !_hidePass),
                    icon: _hidePass
                        ? const Icon(CupertinoIcons.eye)
                        : const Icon(CupertinoIcons.eye_slash)
                )
              ),
            ),
            if(_errorMsg.isNotEmpty)
              Text(_errorMsg, style: const TextStyle(color: Colors.red))
          ],
        ),
      ),
      actions: [
        if(_loading)
          const CircularProgressIndicator()
        else
          TextButton(
              onPressed: () {
                if(_key.currentState!.validate()) {
                  deleteAccount();
                }
              },
              child: const Text('Deletar', style: TextStyle(color: Colors.red))
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      ],
    );
  }
}
