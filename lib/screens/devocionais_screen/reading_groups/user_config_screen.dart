import 'dart:io';
import 'package:biblia_flutter_app/data/user_provider.dart';
import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:biblia_flutter_app/models/user.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/reading_groups/widgets/change_pass_modal.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/reading_groups/widgets/delete_account_dialog.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/reading_groups/widgets/edit_username_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class UserConfigScreen extends StatelessWidget {
  const UserConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context, listen:  false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de conta'),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileContainer(user: userProvider.currentUser!),
          Container(
            margin: EdgeInsetsGeometry.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).listTileTheme.iconColor ?? Colors.white,
              ),
              borderRadius: BorderRadiusDirectional.circular(12)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                ListTile(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false),
                  leading: const Icon(Icons.home),
                  title: const Text('Ínicio'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                ),
                ListTile(
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) => const EditUsernameDialog()
                  ),
                  leading: const Icon(Icons.person),
                  title: const Text('Editar nome de usuário'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                ),
                ListTile(
                  onTap: () => showModalBottomSheet(
                      context: context,
                      useSafeArea: true,
                      builder: (context) => const ChangePassModal()
                  ),
                  leading: const Icon(Icons.lock),
                  title: const Text('Alterar senha'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                ),
                ListTile(
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) => const DeleteAccountDialog()
                  ),
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  leading: const Icon(Icons.delete),
                  title: const Text('Deletar conta'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                ),
                ListTile(
                  onTap: () => userProvider.doLogout().whenComplete(() => Navigator.pushNamedAndRemoveUntil(
                      context, 'login_screen', (route) => route.settings.name == 'devocionais_screen'
                  )),
                  leading: const Icon(Icons.logout),
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  title: const Text('Sair'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ProfileContainer extends StatefulWidget {
  final MyUser user;
  const _ProfileContainer({required this.user});

  @override
  State<_ProfileContainer> createState() => _ProfileContainerState();
}

class _ProfileContainerState extends State<_ProfileContainer> {
  final imagePicker = ImagePicker();
  late Widget avatar;
  bool _loading = false;

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
        final imageFile = File(croppedImage.path);
        saveImageEdit(croppedImage);
        setState(() {
          avatar = CircleAvatar(
            backgroundImage: FileImage(imageFile),
            radius: 55,
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
                    avatar = const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/icone_bg.png'),
                      radius: 55,
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

  Future<void> saveImageEdit(File? file) async {
    try{
      setState(() => _loading = true);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.currentUser!.profilePhotoUrl = file?.path;
      await userProvider.updateUserProfilePicture(userProvider.currentUser!);
      await userProvider.getLoggedUser();
      showCustomSnackBar(child: Text('Foto de perfil atualizada com sucesso!'));
      return;
    }catch(e, stack) {
      print('ERRO AO ATUALIZAR FOTO DE PERFIL: $e /// STACK $stack');
      showCustomSnackBar(child: Text('Houve um erro ao atualizar sua foto de perfil!'));
      return;
    }finally {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    if(widget.user.profilePhotoUrl?.isNotEmpty ?? false) {
      avatar = CircleAvatar(
        foregroundImage: CachedNetworkImageProvider(widget.user.profilePhotoUrl!),
        radius: 55,
      );
    }else {
      avatar = const CircleAvatar(
        backgroundImage: AssetImage('assets/images/icone_bg.png'),
        radius: 55,
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).listTileTheme.iconColor ?? Colors.white, width: 3),
          borderRadius: BorderRadius.circular(80),
        ),
        child: Stack(
          children: [
            avatar,
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: .7),
                borderRadius: BorderRadiusDirectional.circular(100)
              ),
              child: _loading ? Center(child: const CircularProgressIndicator()) : IconButton(
                  onPressed: () => _showOpcoesBottomSheet(),
                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.white70,)
              ),
            )
          ],
        )
      ),
    );
  }
}
