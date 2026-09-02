import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/user_provider.dart';

class ChangePassModal extends StatefulWidget {
  const ChangePassModal({super.key});

  @override
  State<ChangePassModal> createState() => _ChangePassModalState();
}

class _ChangePassModalState extends State<ChangePassModal> {
  final GlobalKey<FormState> _key = GlobalKey();
  late final UserProvider _groupsProvider = Provider.of<UserProvider>(context, listen:  false);
  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  bool _loading = false;
  bool _hideOldPass = true;
  bool _hideNewPass = true;
  String _errorMsg = '';

  Future<void> _updatePassword() async {
    if (_key.currentState!.validate()) {
      setState(() => _loading = true);

      try {
        final userEmail = _groupsProvider.currentUser!.email!;
        final res = await _groupsProvider.reauthenticateUser(userEmail, _oldPassController.text);

        if (res is UserCredential) {
          final success = await _groupsProvider.changePassword(newPassword: _newPassController.text);
          setState(() => _loading = false);

          if (success) {
            showCustomSnackBar(child: const Text('Sua senha foi atualizada com sucesso!'));
            if (!mounted) return;
            Navigator.pop(context);
          } else {
            _showError('Não foi possível alterar sua senha');
          }
        } else {
          throw res is FirebaseAuthException ? res : Exception('Reautenticação falhou $res');
        }
      } catch (e) {
        setState(() => _loading = false);
        _showError(e is FirebaseAuthException ? e.translated : e.toString());
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMsg = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _oldPassController,
              obscureText: _hideOldPass,
              validator: (value) {
                if(value?.isEmpty ?? true) {
                  return 'Este campo é obrgatório';
                }

                return null;
              },
              decoration: InputDecoration(
                labelText: 'Senha antiga',
                hintText: '******',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _hideOldPass = !_hideOldPass),
                  icon: _hideOldPass
                    ? const Icon(CupertinoIcons.eye)
                    : const Icon(CupertinoIcons.eye_slash)
                )
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPassController,
              obscureText: _hideNewPass,
              validator: (value) {
                if(value?.isEmpty ?? true) {
                  return 'Este campo é obrgatório';
                }else if(_oldPassController.text.isEmpty) {
                  return 'A senha antiga é necessária para adicionar uma nova senha';
                }
                if(value!.length < 6) {
                  return 'A senha deve ter pelo menos 6 caracteres';
                }

                return null;
              },
              decoration: InputDecoration(
                labelText: 'Sua nova senha',
                hintText: '******',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _hideNewPass = !_hideNewPass),
                  icon: _hideNewPass
                    ? const Icon(CupertinoIcons.eye)
                    : const Icon(CupertinoIcons.eye_slash)
                )
              ),
            ),
            if(_errorMsg.isNotEmpty)
              Text(_errorMsg, style: const TextStyle(color: Colors.red)),
            const Spacer(),
            if(_loading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: () {
                  if(_key.currentState!.validate()) {
                    _updatePassword();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  fixedSize: const Size(500, 40)
                ),
                child: const Text('Salvar')
              ),
            const SizedBox(height: 12)
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    super.dispose();
  }
}
