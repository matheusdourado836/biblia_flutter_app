import 'dart:io';
import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:biblia_flutter_app/models/group.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../../data/bible_data.dart';
import '../../../../data/reading_groups_provider.dart';
import '../../../../models/user.dart';
import '../create_group_screen.dart';
import 'package:collection/collection.dart';

String? _updatedBgUrl;

class EditGroupModal extends StatefulWidget {
  final Group group;
  const EditGroupModal({super.key, required this.group});

  @override
  State<EditGroupModal> createState() => _EditGroupModalState();
}

class _EditGroupModalState extends State<EditGroupModal> {
  final BibleData _bibleData = BibleData();
  late final ReadingGroupsProvider _groupsProvider = Provider.of<ReadingGroupsProvider>(context, listen: false);
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _numberPeopleController = TextEditingController();
  Group group = Group();
  final List<String> _books = [];
  final List<String> _plansOptions = [
    'Bíblia toda em 1 ano',
    'Bíblia toda em 3 meses',
    'Bíblia toda em 6 meses',
    'Antigo testamento em 3 meses',
    'Antigo testamento em 6 meses',
    'Novo testamento em 3 meses',
    'Novo testamento em 6 meses',
    'Personalizado'
  ];
  String _selectedOption = 'Bíblia toda em 1 ano';
  bool _saving = false;
  String _errorMsg = '';

  Widget _formItem(String label, String hint, TextEditingController controller, {List<TextInputFormatter>? inputFormatters}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontWeight: FontWeight.normal),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey)
        ),
      ),
    ],
  );

  Widget _loadingWidget() => const SizedBox(
    height: 35,
    width: 35,
    child: CircularProgressIndicator(),
  );

  bool checkIfPlanHasChanged() {
    bool changed = false;
    if(_selectedOption == group.plan && _selectedOption == 'Personalizado') {
      bool booksIsEqual = const DeepCollectionEquality().equals(group.books, widget.group.books);
      bool datesIsEqual = group.startDate == widget.group.startDate && group.endDate == widget.group.endDate;
      if(!booksIsEqual || !datesIsEqual) {
        changed = true;
      }
    }else if(_selectedOption != widget.group.plan) {
      changed = true;
    }

    return changed;
  }

  Future<void> updateGroupData() async {
    try {
      await _groupsProvider.updateGroupData(group.toJson()..remove('solicitacoes'), group.id!);
      setState(() => _saving = false);
      _groupsProvider.getUserGroups(notify: true);
      Navigator.popUntil(context, (route) => route.settings.name == 'user_home_screen');
    }catch(e) {
      showCustomSnackBar(
        child: const Text('Nao foi possível salvar suas alterações')
      );
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    final jsonGroup = widget.group.toJson();
    jsonGroup["solicitacoes"] = widget.group.solicitacoes?.map((s) => s.toJson()).toList();
    group = Group.fromJson(jsonGroup);
    _titleController.text = group.nome!;
    _descController.text = group.descricao ?? '';
    _numberPeopleController.text = group.maxPeople.toString();
    _selectedOption = group.plan ?? 'Bíblia toda em 1 ano';
    _books.add('Todos');
    _books.add('Adicionar antigo testamento');
    _books.add('Adicionar novo testamento');
    for (var book in _bibleData.data[0]["text"]) {
      if(!(group.books?.contains(book) ?? false)) {
        _books.add(book["name"]);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 32,)
            ),
          ),
          ProfileContainer(
            user: _groupsProvider.currentUser!,
            group: group,
          ),
          const SizedBox(height: 24),
          _formItem('Nome do grupo', 'Digite o nome aqui', _titleController),
          const SizedBox(height: 24),
          _formItem('Descrição', 'Digite a descrição aqui', _descController),
          const SizedBox(height: 24),
          _formItem(
              'Número de participantes',
              'Máx. 100',
              _numberPeopleController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mudar plano de leitura', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if(_errorMsg.isNotEmpty)
                Text(_errorMsg, style: const TextStyle(color: Colors.red)),
              DropdownButton(
                  value: _selectedOption,
                  style: Theme.of(context).dropdownMenuTheme.textStyle,
                  items: _plansOptions.map((plan) => DropdownMenuItem(
                    value: plan,
                    child: Text(plan)
                  )).toList(),
                  onChanged: (value) => setState(() => _selectedOption = value!)
              ),
            ],
          ),
          if(_selectedOption == 'Personalizado')
            PersonalizadoWidget(group: group, books: _books),
          const SizedBox(height: 32),
          if(_saving)
            _loadingWidget()
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                fixedSize: const Size(500, 40)
              ),
              onPressed: () async {
                if(_selectedOption == 'Personalizado' && (group.books?.isEmpty ?? true)) {
                  setState(() => _errorMsg = 'Escolha ao menos 1 livro');
                  return;
                }
                setState(() {
                  _saving = true;
                  _errorMsg = '';
                });
                group.nome = _titleController.text;
                group.descricao = _descController.text;
                group.maxPeople = int.parse(_numberPeopleController.text);
                if(_updatedBgUrl?.isNotEmpty ?? false) {
                  group.bgUrl = _updatedBgUrl;
                  final res = await _groupsProvider.uploadGroupPicture(group);
                  if(res) {
                    _updatedBgUrl = null;
                  }
                }

                final Map<String, Map<String, dynamic>> options = {
                  'Bíblia toda em 1 ano': {
                    'days': 365,
                    'books': () => _books,
                  },
                  'Bíblia toda em 3 meses': {
                    'days': 90,
                    'books': () => _books,
                  },
                  'Bíblia toda em 6 meses': {
                    'days': 180,
                    'books': () => _books,
                  },
                  'Novo testamento em 3 meses': {
                    'days': 90,
                    'books': () => _books.sublist(42),
                  },
                  'Novo testamento em 6 meses': {
                    'days': 180,
                    'books': () => _books.sublist(42),
                  },
                  'Antigo testamento em 3 meses': {
                    'days': 90,
                    'books': () => _books.sublist(0, 42),
                  },
                  'Antigo testamento em 6 meses': {
                    'days': 180,
                    'books': () => _books.sublist(0, 42),
                  },
                };

                if (_selectedOption != group.plan && options.containsKey(_selectedOption)) {
                  final selectedConfig = options[_selectedOption]!;
                  group.books = selectedConfig['books']();
                  group.startDate = DateTime.now();
                  group.endDate = DateTime.now().add(Duration(days: selectedConfig['days']));
                }
                group.books?.remove('Todos');
                group.books?.remove('Adicionar antigo testamento');
                group.books?.remove('Adicionar novo testamento');
                group.plan = _selectedOption;
                if(checkIfPlanHasChanged()) {
                  group.dailyReading = null;
                }

                updateGroupData();
              },
              child: const Text('Salvar')
            ),
          const SizedBox(height: 32)
        ],
      ),
    );
  }
}

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
  String _userName = '';

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
          _updatedBgUrl = croppedImage.path;
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
              const Text(' Adicionar foto do grupo'),
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
                      onTap: (() => _showOpcoesBottomSheet()),
                      child: Stack(
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
                              child: const Text('MD', style: TextStyle(fontSize: 48, color: Colors.white),),
                            ),
                          )
                        ],
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
    if(widget.user.nomeUsuario!.split(' ').length > 1) {
      _userName = '${widget.user.nomeUsuario!.split(' ')[0].split('')[0].toUpperCase()}${widget.user.nomeUsuario!.split(' ')[1].split('')[0].toUpperCase()}';
    }else {
      _userName = '${widget.user.nomeUsuario!.split('')[0].toUpperCase()}${widget.user.nomeUsuario!.split('')[1].toUpperCase()}';
    }
    if(widget.group.bgUrl?.isNotEmpty ?? false) {
      avatar = InkWell(
        borderRadius: BorderRadius.circular(70),
        onTap: (() => _showOpcoesBottomSheet()),
        child: CircleAvatar(
          foregroundImage: CachedNetworkImageProvider(widget.group.bgUrl!),
          radius: 65,
        ),
      );
    }else {
      avatar = InkWell(
        borderRadius: BorderRadius.circular(70),
        onTap: (() => _showOpcoesBottomSheet()),
        child: Stack(
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
                child: Text(_userName, style: const TextStyle(fontSize: 50, color: Colors.white),),
              ),
            )
          ],
        ),
      );
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