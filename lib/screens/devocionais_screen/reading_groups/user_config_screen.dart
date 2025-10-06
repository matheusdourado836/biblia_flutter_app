import 'dart:io';
import 'package:biblia_flutter_app/data/user_provider.dart';
import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:biblia_flutter_app/models/user.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/reading_groups/widgets/change_pass_modal.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/reading_groups/widgets/delete_account_dialog.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/reading_groups/widgets/edit_username_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../helpers/pick_and_crop_image.dart';

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
  late Widget avatar;
  bool _loading = false;

  Future<void> setImage() async {
    final res = await showOpcoesBottomSheet(context, label: ' Adicionar foto de perfil');
    if(res == null) return;
    if(res == true) {
      setState(() {
        avatar = const CircleAvatar(
          backgroundImage: AssetImage('assets/images/icone_bg.png'),
          radius: 55,
        );
      });
      saveImageEdit(null);
      return;
    }
    File croppedImage = res;
    saveImageEdit(croppedImage);
    setState(() {
      avatar = CircleAvatar(
        backgroundImage: FileImage(croppedImage),
        radius: 55,
      );
    });
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
                  onPressed: () => setImage(),
                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.white70,)
              ),
            )
          ],
        )
      ),
    );
  }
}
