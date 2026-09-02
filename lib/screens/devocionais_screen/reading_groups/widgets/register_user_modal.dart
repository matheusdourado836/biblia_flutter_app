import 'dart:async';
import 'dart:io';
import 'package:biblia_flutter_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../data/user_provider.dart';
import '../../../../helpers/pick_and_crop_image.dart';

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
  late final UserProvider _groupsProvider = Provider.of<UserProvider>(context, listen: false);
  bool _isLoading = false;
  bool _error = false;
  bool _usernameIndisponivel = false;
  Timer? _debounceUsername;
  final imagePicker = ImagePicker();
  File? imageFile;
  late Widget avatar;

  Widget _loadingWidget() => const SizedBox(
    height: 35,
    width: 35,
    child: CircularProgressIndicator(),
  );

  Future<void> setImage() async {
    final res = await showOpcoesBottomSheet(context, label: ' Adicionar foto de perfil');
    if(res == null) return;
    if(res == true) {
      setState(() {
        imageFile = null;
        avatar = const CircleAvatar(
          backgroundImage: AssetImage('assets/images/icone_bg.png'),
          radius: 55,
        );
      });
      return;
    }
    File croppedImage = res;
    setState(() {
      imageFile = croppedImage;
      avatar = CircleAvatar(
        backgroundImage: FileImage(croppedImage),
        radius: 55,
      );
    });
  }

  @override
  void initState() {
    avatar = InkWell(
      borderRadius: BorderRadius.circular(70),
      onTap: () => setImage(),
      child: const CircleAvatar(
        backgroundImage: AssetImage('assets/images/icone_bg.png'),
        radius: 55,
      ),
    );
    super.initState();
  }

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
                const Text('Foto de perfil (opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).listTileTheme.iconColor ?? Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: avatar,
                ),
                const Text('Nome de usuário', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  maxLength: 35,
                  onChanged: _onUsernameChanged,
                  validator: (value) {
                    if(value?.isEmpty ?? true) {
                      return 'Este campo é obrigatório';
                    }

                    // O `return` dentro do .then() saía do callback, não do
                    // validator — a mensagem nunca aparecia. A checagem agora
                    // roda ao digitar e guarda o resultado em _usernameIndisponivel.
                    if (_usernameIndisponivel) {
                      return 'Este nome de usuário não está disponível';
                    }

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
                      profilePhotoUrl: imageFile?.path,
                      gruposParticipantes: []
                    );
                    _groupsProvider.registerUser(user: user, pass: _passController.text).then((res) {
                      setState(() => _isLoading = false);
                      if(res) {
                        if (!context.mounted) return;
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

  /// Consulta o índice público `usernames` enquanto a pessoa digita. Com
  /// debounce para não disparar uma leitura por tecla.
  void _onUsernameChanged(String value) {
    _debounceUsername?.cancel();
    if (_usernameIndisponivel) {
      setState(() => _usernameIndisponivel = false);
    }
    if (value.trim().isEmpty) return;

    _debounceUsername = Timer(const Duration(milliseconds: 500), () async {
      final disponivel = await _groupsProvider.checkIfUsernameIsAvailable(username: value);
      if (!mounted || value != _usernameController.text) return;
      setState(() => _usernameIndisponivel = !disponivel);
      _key.currentState?.validate();
    });
  }

  @override
  void dispose() {
    _debounceUsername?.cancel();
    _emailController.dispose();
    _passController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
