import 'dart:io';
import 'package:biblia_flutter_app/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../../data/user_provider.dart';

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
  final imagePicker = ImagePicker();
  File? imageFile;
  late Widget avatar;

  Widget _loadingWidget() => const SizedBox(
    height: 35,
    width: 35,
    child: CircularProgressIndicator(),
  );

  Future<File?> cropImage(File file) async {
    final cropController = CropController();

    try {
      final imageBytes = await file.readAsBytes();
      Uint8List? croppedBytes;

      await showModalBottomSheet(
          context: context,
          useSafeArea: true,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: CropPreview(
                    controller: cropController,
                    mode: CropMode.oval,
                    maskOptions: const MaskOptions(
                      backgroundColor: Colors.black38,
                      borderColor: Colors.grey,
                      strokeWidth: 2,
                      aspectRatio: 4 / 4,
                      minSize: 25,
                    ),
                    bytes: imageBytes
                ),
              ),
              TextButton(
                  onPressed: () async {
                    croppedBytes = await cropController.crop();
                    Navigator.pop(context, true);
                  },
                  child: const Text('Cortar')
              )
            ],
          )
      );

      if (croppedBytes == null) {
        return null;
      }

      final directory = await getTemporaryDirectory();
      final croppedFilePath = '${directory.path}/cropped_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final croppedFile = File(croppedFilePath);
      await croppedFile.writeAsBytes(croppedBytes!);

      return croppedFile;
    } catch (e) {
      print('Erro ao cortar a imagem: $e');
      return null;
    }
  }

  pick(ImageSource source) async {
    var storageStatus = await Permission.storage.status;
    var cameraStatus = await Permission.camera.status;
    if (source == ImageSource.camera && cameraStatus.isDenied) {
      Permission.camera.request();
    }
    if(source == ImageSource.gallery && storageStatus.isDenied) {
      Permission.storage.request();
    }
    final pickedFile = await imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      final croppedImage = await cropImage(File(pickedFile.path));
      if (!mounted) return;
      if(croppedImage != null) {
        setState(() {
          imageFile = File(croppedImage.path);
          avatar = InkWell(
            borderRadius: BorderRadius.circular(70),
            onTap: (() => _showOpcoesBottomSheet()),
            child: CircleAvatar(
              backgroundImage: FileImage(imageFile!),
              radius: 65,
            ),
          );
        });
      }
    }
  }

  void _showOpcoesBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).primaryColor,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(' Adicionar foto de perfil'),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(50)
                  ),
                  child: Icon(
                    Icons.image,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text('Galeria',),
                onTap: () {
                  Navigator.pop(context);
                  pick(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(50)
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text('Tirar foto',),
                onTap: () {
                  Navigator.pop(context);
                  pick(ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(50)
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                title: const Text('Remover'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    imageFile = null;
                    avatar = InkWell(
                      borderRadius: BorderRadius.circular(70),
                      onTap: () => _showOpcoesBottomSheet(),
                      child: const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/icone_bg.png'),
                        radius: 55,
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    avatar = InkWell(
      borderRadius: BorderRadius.circular(70),
      onTap: () => _showOpcoesBottomSheet(),
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
                const Text('Foto de perfil(opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      profilePhotoUrl: imageFile?.path,
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
