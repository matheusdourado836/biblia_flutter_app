import 'dart:io';
import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:biblia_flutter_app/helpers/pick_and_crop_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/group.dart';
import '../models/user.dart';

class ProfileContainer extends StatefulWidget {
  final MyUser user;
  final Group group;
  const ProfileContainer({super.key, required this.user, required this.group});

  @override
  State<ProfileContainer> createState() => _ProfileContainerState();
}

class _ProfileContainerState extends State<ProfileContainer> {
  late Widget avatar;
  final imagePicker = ImagePicker();
  File? imageFile;

  Widget setAvatar(Widget child) => InkWell(
      borderRadius: BorderRadius.circular(70),
      onTap: () => setImage(),
      child: child
  );

  Future<void> setImage() async {
    final res = await showOpcoesBottomSheet(context, label: ' Adicionar imagem do grupo');
    if(res == null) return;
    if(res == true) {
      setState(() {
        imageFile = null;
        avatar = setAvatar(Stack(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/icone_bg.png'),
              radius: 65,
            ),
            Positioned(
              top: 0,
              bottom: 0,
              child: Container(
                  width: 130,
                  height: 140,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: .7),
                      borderRadius: BorderRadius.circular(70)
                  ),
                  child: Text((widget.user.nomeUsuario ?? '').initials(), style: TextStyle(fontSize: 48, color: Colors.white))
              ),
            )
          ],
        ));
      });
      return;
    }

    File croppedImage = res;
    widget.group.bgUrl = croppedImage.path;
    setState(() {
      imageFile = File(croppedImage.path);
      avatar = setAvatar(CircleAvatar(
        backgroundImage: FileImage(imageFile!),
        radius: 65,
      ));
    });
  }

  @override
  void initState() {
    if(widget.group.bgUrl?.isNotEmpty ?? false) {
      avatar = setAvatar(CircleAvatar(
        radius: 65,
        backgroundImage: CachedNetworkImageProvider(widget.group.bgUrl!),
      ));
    }else {
      avatar = setAvatar(Stack(
        children: [
          const CircleAvatar(
            backgroundImage: AssetImage('assets/images/icone_bg.png'),
            radius: 65,
          ),
          Positioned(
            top: 0,
            bottom: 0,
            child: Container(
              width: 130,
              height: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: .7),
                  borderRadius: BorderRadius.circular(70)
              ),
              child: Text((widget.user.nomeUsuario ?? '').initials(), style: const TextStyle(fontSize: 50, color: Colors.white),),
            ),
          )
        ],
      ));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.only(right: 8, top: 16),
            decoration: BoxDecoration(
                color: Theme.of(context).listTileTheme.iconColor ?? Colors.white,
                borderRadius: BorderRadiusDirectional.circular(2)
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).listTileTheme.iconColor ?? Colors.white, width: 3),
            borderRadius: BorderRadius.circular(80),
          ),
          child: avatar,
        ),
        Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.only(left: 8, top: 16),
            decoration: BoxDecoration(
                color: Theme.of(context).listTileTheme.iconColor ?? Colors.white,
                borderRadius: BorderRadiusDirectional.circular(2)
            ),
          ),
        ),
      ],
    );
  }
}