import 'dart:io';
import 'package:biblia_flutter_app/data/devocional_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/devocional_saved_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../helpers/expandable_container.dart';

class SaveBottomSheet extends StatefulWidget {
  final Devocional devocional;
  const SaveBottomSheet({super.key, required this.devocional});

  @override
  State<SaveBottomSheet> createState() => _SaveBottomSheetState();
}

class _SaveBottomSheetState extends State<SaveBottomSheet> {
  late final DevocionalProvider _devocionalProvider;
  bool _public = true;
  bool _isLoading = false;

  @override
  void initState() {
    _devocionalProvider =
        Provider.of<DevocionalProvider>(context, listen: false);
    widget.devocional.public = _public;
    super.initState();
  }

  void saveUserPost(String devocionalId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userPosts = prefs.getStringList('posts') ?? [];

    userPosts.add(devocionalId);

    prefs.setStringList('posts', userPosts);
  }

  Widget _loading() => const SizedBox(
        height: 25,
        width: 25,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Complete seu post'),
          const SizedBox(height: 20),
          _PostContainer(devocional: widget.devocional),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Público'),
              const SizedBox(width: 12),
              Switch(
                  value: _public,
                  onChanged: ((newValue) {
                    setState(() => _public = !_public);
                    widget.devocional.public = _public;
                  }))
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: ElevatedButton(
                      onPressed: (() => Navigator.pop(context)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Text('Cancelar'))),
              const SizedBox(width: 12),
              Expanded(
                  child: ElevatedButton(
                      onPressed: (() {
                        setState(() => _isLoading = true);
                        _devocionalProvider
                            .postDevocional(devocional: widget.devocional)
                            .then((value) {
                          setState(() => _isLoading = false);
                          if (value.isNotEmpty) {
                            saveUserPost(value);
                            showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) =>
                                        const DevocionalSavedDialog())
                                .whenComplete(() {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, 'feed_screen', (route) => route.settings.name == 'feed_screen');
                            });
                          }
                        });
                      }),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child:
                          (_isLoading) ? _loading() : const Text('Publicar')))
            ],
          )
        ],
      ),
    );
  }
}

class _PostContainer extends StatefulWidget {
  final Devocional devocional;
  const _PostContainer({super.key, required this.devocional});

  @override
  State<_PostContainer> createState() => _PostContainerState();
}

class _PostContainerState extends State<_PostContainer> {
  final TextEditingController _nameController = TextEditingController();
  final imagePicker = ImagePicker();
  File? imageFile;
  Widget? bgImage;
  Widget? avatar;
  String todayDate = '';

  pick(ImageSource source, bool profile) async {
    var storageStatus = await Permission.storage.status;
    var cameraStatus = await Permission.camera.status;
    if (source == ImageSource.camera && cameraStatus.isDenied) {
      Permission.camera.request();
    }
    if (source == ImageSource.gallery && storageStatus.isDenied) {
      Permission.storage.request();
    }
    final pickedFile = await imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      final croppedImage = await cropImage(File(pickedFile.path));
      if (!mounted) return;
      setState(() {
        imageFile = File(croppedImage.path);
        if (profile) {
          widget.devocional.bgImagemUser = imageFile!.path;
          avatar = Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                image: DecorationImage(
                    fit: BoxFit.cover, image: FileImage(imageFile!))),
          );
        } else {
          widget.devocional.bgImagem = imageFile!.path;
          bgImage = Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                image: DecorationImage(
                    fit: BoxFit.cover, image: FileImage(imageFile!))),
          );
        }
      });
    }
  }

  Future<CroppedFile> cropImage(File file) async {
    final croppedImage = await ImageCropper()
        .cropImage(sourcePath: file.path,
        aspectRatioPresets: [CropAspectRatioPreset.ratio4x3],
        uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Cortar imagem',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Theme.of(context).colorScheme.primary,
          statusBarColor: Theme.of(context).primaryColor,
          activeControlsWidgetColor: Theme.of(context).colorScheme.primary,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      IOSUiSettings(title: 'Cortar imagem')
    ]);

    return croppedImage!;
  }

  void _showOpcoesBottomSheet(bool profile) {
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
              Text(
                ' Selecione a imagem',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 20, color: Colors.black),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(50)),
                  child: Icon(
                    Icons.image,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.of(context).pop();
                  pick(ImageSource.gallery, profile);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(50)),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text('Tirar foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  pick(ImageSource.camera, profile);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(50)),
                  child: Icon(
                    Icons.image,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text('Imagem aleatória'),
                onTap: () {
                  setState(() {
                    final versesProvider =
                        Provider.of<VersesProvider>(context, listen: false);
                    versesProvider.getOnlyImage().then((res) async {
                      Navigator.pop(context);
                      setState(() async {
                        imageFile = File(res["url"]);
                        bgImage = Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      versesProvider.verseInfo["url"]))),
                        );
                      });
                    });
                  });
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(50)),
                  child: Icon(
                    Icons.delete,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text('Remover'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() => imageFile = null);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget iconInfo({required Widget icon, required String text}) => Row(
        children: [
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(width: 10),
          icon,
        ],
      );

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    String day = DateTime.now().day < 10
        ? '0${DateTime.now().day}'
        : DateTime.now().day.toString();
    String month = DateTime.now().month < 10
        ? '0${DateTime.now().month}'
        : DateTime.now().month.toString();
    int year = DateTime.now().year;
    todayDate = '$day/$month/$year';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.primary,
          boxShadow: kElevationToShadow[1]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: InkWell(
              onTap: (() => _showOpcoesBottomSheet(false)),
              child: (bgImage == null)
                  ? DottedBorder(
                      borderType: BorderType.RRect,
                      color: Colors.white,
                      dashPattern: const [5, 5],
                      radius: const Radius.circular(12),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        child: Container(
                          color: Colors.grey,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 80),
                              Text(
                                'Adicionar imagem de fundo (opcional)',
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : bgImage,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: ExpandableContainer(
              header: widget.devocional.titulo!,
              expandedText: widget.devocional.texto!,
              verCompleto: false,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: (() => _showOpcoesBottomSheet(true)),
                    child: (imageFile != null && avatar != null)
                        ? avatar!
                        : Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.grey),
                            child: const Center(
                              child: Icon(Icons.edit, size: 22),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .43,
                        child: TextFormField(
                          controller: _nameController,
                          validator: (value) => value?.isEmpty ?? true
                              ? 'o nome é obrigatório'
                              : null,
                          onChanged: (value) =>
                              widget.devocional.nomeAutor = value,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          cursorColor: Colors.white,
                          decoration: const InputDecoration(
                              hintText: 'Digite seu nome...',
                              hintStyle:
                                  TextStyle(color: Colors.white, fontSize: 12),
                              suffixIcon: Icon(Icons.edit_outlined, size: 14),
                              suffixIconColor: Colors.white,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none),
                        ),
                      ),
                      Text('Em $todayDate',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10))
                    ],
                  )
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: (() {}),
                      child: iconInfo(
                          text: '0',
                          icon: const Icon(
                            Icons.chat_bubble,
                            color: Colors.white,
                            size: 16,
                          )),
                    ),
                    const SizedBox(width: 12),
                    iconInfo(
                        text: '0',
                        icon: Material(
                          color: Colors.transparent,
                          child: InkWell(
                              onTap: (() {}),
                              radius: 40,
                              borderRadius: BorderRadius.circular(50),
                              child: const Icon(
                                CupertinoIcons.heart_fill,
                                color: Colors.red,
                                size: 16,
                              )),
                        )),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
