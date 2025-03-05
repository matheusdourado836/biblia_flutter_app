import 'package:biblia_flutter_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/reading_groups_provider.dart';

class RegisterUserModal extends StatefulWidget {
  const RegisterUserModal({super.key});

  @override
  State<RegisterUserModal> createState() => _RegisterUserModalState();
}

class _RegisterUserModalState extends State<RegisterUserModal> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  late final ReadingGroupsProvider _groupsProvider = Provider.of<ReadingGroupsProvider>(context, listen: false);
  bool _isLoading = false;
  bool _error = false;

  Widget _loadingWidget() => const SizedBox(
    height: 35,
    width: 35,
    child: CircularProgressIndicator(),
  );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Preencha seus dados',
              style: TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nome de usuário', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  maxLength: 35,
                  validator: (value) {
                    if(value?.isEmpty ?? true) {
                      return 'Este campo é obrigatório';
                    }

                    _groupsProvider.checkIfUsernameIsAvailable(username: value!).then((res) {
                      if(!res) {
                        return 'Este nome de usuario não está disponível';
                      }
                    });

                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Digite o nome aqui...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 0, color: Theme.of(context).colorScheme.onSurface), borderRadius: const BorderRadius.all(Radius.circular(10))),
                    errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.all(Radius.circular(10))),
                    focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.all(Radius.circular(10))),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0, color: Theme.of(context).colorScheme.onSurface, strokeAlign: 10), borderRadius: const BorderRadius.all(Radius.circular(10))),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if(value?.isEmpty ?? true) {
                        return 'Este campo é obrigatório';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Digite seu email aqui...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 0, color: Theme.of(context).colorScheme.onSurface), borderRadius: const BorderRadius.all(Radius.circular(10))),
                      errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.all(Radius.circular(10))),
                      focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.all(Radius.circular(10))),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0, color: Theme.of(context).colorScheme.onSurface, strokeAlign: 10), borderRadius: const BorderRadius.all(Radius.circular(10))),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Senha', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passController,
                  validator: (value) {
                    if(value?.isEmpty ?? true) {
                      return 'Este campo é obrigatório';
                    }
                    if(value!.length < 6) {
                      return 'A senha deve ter pelo menos 6 dígitos.';
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '********',
                    filled: true,
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 0, color: Theme.of(context).colorScheme.onSurface), borderRadius: const BorderRadius.all(Radius.circular(10))),
                    errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.all(Radius.circular(10))),
                    focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.all(Radius.circular(10))),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0, color: Theme.of(context).colorScheme.onSurface, strokeAlign: 10), borderRadius: const BorderRadius.all(Radius.circular(10))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if(_error)
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Não foi possível criar seu usuário, tente novamente mais tarde',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            if(_isLoading)
              _loadingWidget()
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  fixedSize: const Size(500, 40)
                ),
                onPressed: () {
                  if(_key.currentState?.validate() ?? false) {
                    setState(() => _isLoading = true);
                    MyUser user = MyUser(
                      nomeUsuario: _usernameController.text,
                      email: _emailController.text,
                      gruposParticipantes: []
                    );
                    _groupsProvider.registerUser(user: user, pass: _passController.text).then((res) {
                      setState(() => _isLoading = false);
                      if(res) {
                        Navigator.pop(context, _emailController.text);
                      }else {
                        setState(() => _error = true);
                      }
                    });
                  }
                },
                child: const Text('Criar conta', style: TextStyle(fontWeight: FontWeight.bold))
              ),
          ],
        ),
      )
    );
  }
}
