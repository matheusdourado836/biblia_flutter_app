import 'dart:io';
import 'package:biblia_flutter_app/data/devocional_provider.dart';
import 'package:biblia_flutter_app/data/user_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/helpers/format_data.dart';
import 'package:biblia_flutter_app/helpers/loading_widget.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/devocional_saved_dialog.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/widgets/frosted_container.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../data/theme_provider.dart';
import '../../../helpers/expandable_container.dart';
import '../../../helpers/tutorial_widget.dart';
import 'package:path_provider/path_provider.dart';
import '../community/feed_screen.dart';

class SaveDevocionalWidget extends StatefulWidget {
  final Devocional devocional;
  const SaveDevocionalWidget({super.key, required this.devocional});

  @override
  State<SaveDevocionalWidget> createState() => _SaveDevocionalWidgetState();
}

class _SaveDevocionalWidgetState extends State<SaveDevocionalWidget> with WidgetsBindingObserver {
  final GlobalKey<FormState> _key = GlobalKey();
  late final UserProvider _authProvider = Provider.of<UserProvider>(context, listen: false);
  double boxHeight = 0;
  bool _public = true;
  bool _addFrost = false;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    widget.devocional.public = _public;
    widget.devocional.ownerId = _authProvider.currentUser!.id!;
    widget.devocional.nomeAutor = _authProvider.currentUser!.nomeUsuario!;
    widget.devocional.bgImagemUser = _authProvider.currentUser!.profilePhotoUrl;
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = View.of(context).viewInsets.bottom;
    setState(() {
      _isKeyboardVisible = bottomInset > 0.0;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Complete seu post', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),),
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final landscapeHeight = constraints.biggest.longestSide > 900 ? constraints.maxHeight * 1.3 : constraints.maxHeight * 3;
          boxHeight = constraints.maxHeight < constraints.biggest.longestSide ? landscapeHeight : (_isKeyboardVisible) ? constraints.maxHeight + 280 : constraints.maxHeight;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _key,
                child: SizedBox(
                  height: boxHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PostContainer(devocional: widget.devocional),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Publicar para todos'),
                          const SizedBox(width: 12),
                          Switch(
                            value: _public,
                            onChanged: ((newValue) {
                              setState(() => _public = !_public);
                              widget.devocional.public = _public;
                            })
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Adicionar título na imagem'),
                          const SizedBox(width: 12),
                          Switch(
                            value: _addFrost,
                            onChanged: ((newValue) {
                              setState(() => _addFrost = !_addFrost);
                              widget.devocional.hasFrost = _addFrost;
                            })
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: (() {
                                if(_key.currentState!.validate()) {
                                  showDialog(
                                      context: context,
                                      builder: (context) => EmailDialog(devocional: widget.devocional)
                                  );
                                }
                              }),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                              ),
                              child: const Text('Publicar')
                            )
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: (() => Navigator.pop(context)),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                                  ),
                                  child: const Text('Cancelar')
                              )
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PostContainer extends StatefulWidget {
  final Devocional devocional;
  const _PostContainer({required this.devocional});

  @override
  State<_PostContainer> createState() => _PostContainerState();
}

class _PostContainerState extends State<_PostContainer> {
  final GlobalKey bgKey = GlobalKey();
  final GlobalKey profileKey = GlobalKey();
  final imagePicker = ImagePicker();
  File? imageFile;
  File? bgImageFile;
  File? apiImage;
  String todayDate = '';
  bool _loadingImage = false;
  List<TargetFocus> _targets = [];
  TutorialCoachMark? _coachMark;

  pick(ImageSource source) async {
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
      if(croppedImage != null) {
        setState(() {
          imageFile = File(croppedImage.path);
          bgImageFile = File(croppedImage.path);
          widget.devocional.bgImagem = bgImageFile!.path;
        });
      }
    }
  }

  Future<File?> cropImage(File file) async {
    final cropController = CropController();

    try {
      final imageBytes = await file.readAsBytes();
      Uint8List? croppedBytes;

      await showModalBottomSheet(
          context: context,
          useSafeArea: true,
          builder: (context) => Column(
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: CropPreview(
                    controller: cropController,
                    maskOptions: const MaskOptions(
                      backgroundColor: Colors.black38,
                      borderColor: Colors.grey,
                      strokeWidth: 2,
                      aspectRatio: 5 / 4,
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

  Future<void> loadApiImage() async {
    final versesProvider = Provider.of<VersesProvider>(context, listen: false);
    setState(() => _loadingImage = true);
    await versesProvider.getOnlyImage().then((res) async {
      if(res != null) {
        apiImage = res;
        final croppedImage = await cropImage(File(res.path));
        if(croppedImage != null) {
          bgImageFile = File(croppedImage.path);
          widget.devocional.bgImagem = bgImageFile!.path;
          setState(() => bgImageFile);
        }
      }else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível gerar uma imagem, tente novamente')));
      }
    });
    
    setState(() => _loadingImage = false);
  }

  Future<void> deleteApiImage() async {
    if (apiImage != null && await apiImage!.exists()) {
      await apiImage!.delete();
      return;
    }
  }

  Future<void> editImage() async {
    final editedImage = await cropImage(bgImageFile!);
    if(editedImage != null) {
      setState(() => bgImageFile = File(editedImage.path));
      widget.devocional.bgImagem = bgImageFile!.path;
    }
    return;
  }

  void _showOpcoesBottomSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.longestSide
      ),
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
                    .copyWith(fontSize: 20, color: Theme.of(context).colorScheme.onSurface),
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
                      borderRadius: BorderRadius.circular(50)),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text('Tirar foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  pick(ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
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
                      deleteApiImage();
                      Navigator.pop(context);
                      loadApiImage();
                    });
                  },
                ),
              ),
              (imageFile != null || bgImageFile != null)
              ? Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(50)),
                    child: Icon(
                      Icons.edit,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: const Text('Editar'),
                  onTap: () {
                    editImage().whenComplete(() => Navigator.pop(context));
                  },
                ),
              )
                : const SizedBox(),
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
                  deleteApiImage().whenComplete(() => setState(() {
                    apiImage = null;
                    bgImageFile = null;
                  }));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showTutorial() {
    final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
    if(!devocionalProvider.tutorials.contains('tutorial 4') && (MediaQuery.of(context).orientation == Orientation.portrait || MediaQuery.of(context).size.height > 600)) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      initTargets();
      _coachMark = TutorialCoachMark(
          onSkip: () {
            devocionalProvider.markTutorial(4);
            return true;
          },
          onFinish: () {
            devocionalProvider.markTutorial(4);
          },
          colorShadow: (themeProvider.isOn) ? Colors.black : Theme.of(context).canvasColor,
          targets: _targets,
          hideSkip: true
      )..show(context: context);
    }
  }

  void initTargets() {
    _targets = [
      TargetFocus(
          identify: 'bg-image-key',
          keyTarget: bgKey,
          shape: ShapeLightFocus.RRect,
          contents: [
            TargetContent(
                align: ContentAlign.bottom,
                builder: (context, c) {
                  return TutorialWidget(
                      text: 'Clique aqui para adicionar uma imagem de fundo ao seu post.\nVocê pode escolher entre'
                          ' uma foto da câmera, imagem aleatória de uma paisagem, ou de sua galeria',
                      skip: 'Pular',
                      next: 'Próximo',
                      onNext: (() async {
                        c.next();
                        await Scrollable.ensureVisible(profileKey.currentContext!, duration: const Duration(milliseconds: 600));
                      }),
                      onSkip: (() => c.skip())
                  );
                }
            ),
          ]
      ),
      TargetFocus(
          identify: 'profile-image-key',
          keyTarget: profileKey,
          shape: ShapeLightFocus.Circle,
          contents: [
            TargetContent(
                align: ContentAlign.bottom,
                builder: (context, c) {
                  return TutorialWidget(
                      text: 'Clique aqui para adicionar uma foto de perfil ao seu post',
                      skip: '',
                      next: 'Finalizar',
                      onNext: (() {
                        c.skip();
                      }),
                      onSkip: (() => c.skip())
                  );
                }
            ),
          ]
      ),
    ];
  }

  Widget iconInfo({required Widget icon, required String text}) => Column(
        children: [
          icon,
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
  );

  Future<void> clearCache() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.listSync().forEach((file) {
        if (file is File) {
          file.deleteSync();
        }
      });
    }
  }

  @override
  void dispose() {
    if (apiImage != null && apiImage!.existsSync()) {
      apiImage!.deleteSync();
    }
    clearCache();
    _coachMark?.finish();
    super.dispose();
  }

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () => showTutorial());
    todayDate = formattedDate(dateString: DateTime.now().toIso8601String());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).cardTheme.color,
            boxShadow: kElevationToShadow[1]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              (_loadingImage)
                  ? const SizedBox(height: 250, width: 30, child: Center(child: LoadingWidget(bgColor: Colors.white, txtColor: Colors.white,)),)
                  : InkWell(
                onTap: (() => _showOpcoesBottomSheet()),
                child: (bgImageFile == null)
                    ? SizedBox(
                  height: constraints.maxWidth > 400 ? 400 : 250,
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    color: Colors.white,
                    dashPattern: const [5, 5],
                    radius: const Radius.circular(12),
                    child: ClipRRect(
                      key: bgKey,
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: Container(
                        color: Colors.grey,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  ),
                )
                    : Container(
                  height: constraints.maxWidth > 400 ? 400 : 250,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      image: DecorationImage(
                          colorFilter: (widget.devocional.hasFrost ?? false)
                              ? ColorFilter.mode(Colors.black.withValues(alpha: 0.45), BlendMode.darken)
                              : null,
                          fit: BoxFit.cover, image: FileImage(bgImageFile!)
                      )
                  ),
                  child: (widget.devocional.hasFrost ?? false)
                      ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FrostedContainer(title: widget.devocional.titulo ?? ''),
                  ) : const SizedBox(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ExpandableContainer(
                  header: widget.devocional.titulo!,
                  expandedText: widget.devocional.plainText!,
                  verCompleto: false,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (widget.devocional.bgImagemUser?.isNotEmpty ?? false)
                        Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(widget.devocional.bgImagemUser!,)
                          )
                        ),
                        ) else const NoBgUser(),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.devocional.nomeAutor!, style: const TextStyle(color: Colors.white, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(todayDate, style: const TextStyle(color: Colors.white, fontSize: 10))
                        ],
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: iconInfo(
                            text: '0',
                            icon: const Icon(
                              Icons.chat_bubble,
                              color: Colors.white,
                              size: 16,
                            )
                          ),
                        ),
                        const SizedBox(width: 20),
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
                                size: 18,
                              )
                            ),
                          )
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
