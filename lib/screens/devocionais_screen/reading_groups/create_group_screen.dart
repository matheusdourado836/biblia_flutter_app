import 'dart:io';
import 'package:biblia_flutter_app/data/reading_groups_provider.dart';
import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:biblia_flutter_app/models/group.dart';
import 'package:biblia_flutter_app/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../data/bible_data.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final BibleData _bibleData = BibleData();
  late final ReadingGroupsProvider _groupsProvider = Provider.of<ReadingGroupsProvider>(context, listen: false);
  final GlobalKey<FormState> _key = GlobalKey();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _numberPeopleController = TextEditingController();
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
  final Group group = Group();
  bool _saving = false;

  Widget _formItem(String label, String hint, TextEditingController controller, {List<TextInputFormatter>? inputFormatters, bool required = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        inputFormatters: inputFormatters,
        validator: required ? (value) {
          if(value?.isEmpty ?? true) {
            return 'Este campo é obrigatório';
          }
          return null;
        } : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey)
        ),
      ),
    ],
  );

  @override
  void initState() {
    _books.add('Todos');
    _books.add('Adicionar antigo testamento');
    _books.add('Adicionar novo testamento');
    for (var book in _bibleData.data[0]["text"]) {
      _books.add(book["name"]);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar um grupo'),),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileContainer(
                user: _groupsProvider.currentUser!,
                group: group,
              ),
              const SizedBox(height: 24),
              _formItem('Nome do grupo (obrigatório)', 'Digite o nome aqui', _titleController, required: true),
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
                  const Text('Selecione o plano de leitura (obrigatório)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
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
              const SizedBox(height: 100)
            ],
          ),
        ),
      ),
      floatingActionButton: (_saving) ? const CircularProgressIndicator() : FloatingActionButton(
        backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
        tooltip: 'Salvar',
        onPressed: () {
          if(_selectedOption == 'Personalizado' && (group.books?.isEmpty ?? true)) {
            showCustomSnackBar(child: const Text('Escolha ao menos 1 livro'));
            return;
          }
          if(_key.currentState?.validate() ?? false) {
            setState(() => _saving = true);
            group.ownerId = _groupsProvider.currentUser!.id!;
            group.nome = _titleController.text;
            group.descricao = _descController.text;
            group.participantes = [_groupsProvider.currentUser!.id!];
            group.maxPeople = int.tryParse(_numberPeopleController.text) ?? 10;
            group.plan = _selectedOption;
            group.createdAt = DateTime.now();
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

            if (options.containsKey(_selectedOption)) {
              final selectedConfig = options[_selectedOption]!;
              group.books = selectedConfig['books']();
              group.startDate = DateTime.now();
              group.endDate = DateTime.now().add(Duration(days: selectedConfig['days']));
            }
            group.books?.remove('Todos');
            group.books?.remove('Adicionar antigo testamento');
            group.books?.remove('Adicionar novo testamento');
            _groupsProvider.createGroup(group: group).then((res) {
              setState(() => _saving = false);
              if(res) {
                _groupsProvider.getUserGroups(notify: true);
                showCustomSnackBar(child: const Text('Grupo criado com sucesso'));
                Navigator.popUntil(context, (route) => route.settings.name == 'user_home_screen');
              }
            });
          }
        },
        child: Icon(
          Icons.save,
          size: 26,
          color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
        ),
      ),
    );
  }
}

class PersonalizadoWidget extends StatefulWidget {
  final Group group;
  final List<String> books;
  const PersonalizadoWidget({super.key, required this.group, required this.books});

  @override
  State<PersonalizadoWidget> createState() => _PersonalizadoWidgetState();
}

class _PersonalizadoWidgetState extends State<PersonalizadoWidget> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  List<String> _addedBooks = [];

  @override
  void initState() {
    widget.group.startDate ??= DateTime.now();
    widget.group.endDate ??= DateTime.now().add(const Duration(days: 30));
    _startController.text = widget.group.startDate?.formatted() ?? DateTime.now().formatted();
    _endController.text = widget.group.endDate?.formatted() ?? DateTime.now().add(const Duration(days: 30)).formatted();
    _addedBooks = widget.group.books ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            const Text('Adicione os livros:'),
            Transform.scale(
              scale: .75,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  useSafeArea: true,
                  builder: (context) => SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.books.where((b) => !_addedBooks.contains(b)).map((book) => InkWell(
                        onTap: () {
                          if(book == 'Todos') {
                            _addedBooks = List<String>.from(widget.books);
                            _addedBooks.remove('Todos');
                            _addedBooks.remove('Adicionar antigo testamento');
                            _addedBooks.remove('Adicionar novo testamento');
                          }else if(book == 'Adicionar antigo testamento') {
                            final oldTestament = widget.books.sublist(0, 42);
                            _addedBooks.addAll(oldTestament);
                            _addedBooks.remove('Todos');
                            _addedBooks.remove('Adicionar antigo testamento');
                            _addedBooks.remove('Adicionar novo testamento');
                          }else if(book == 'Adicionar novo testamento') {
                            final newTestament = widget.books.sublist(42);
                            _addedBooks.addAll(newTestament);
                            _addedBooks.remove('Todos');
                            _addedBooks.remove('Adicionar antigo testamento');
                            _addedBooks.remove('Adicionar novo testamento');
                          }else {
                            _addedBooks.add(book);
                          }
                          setState(() {
                            _addedBooks;
                            widget.group.books = _addedBooks;
                          });
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(book),
                              const Icon(Icons.add)
                            ],
                          ),
                        ),
                      )).toList(),
                    ),
                  )
                ),
                child: const Text('Selecionar')
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if(_addedBooks.length > 7)
          Transform.scale(
            scale: .8,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _addedBooks = []);
                widget.group.books = [];
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  iconColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              label: const Text('Remover todos'),
              icon: const Icon(Icons.delete),
            ),
          ),
        const Text('Livros adicionados:'),
        Wrap(
          spacing: 8,
          children: _addedBooks.map((book) => Chip(
            label: Text(book),
            onDeleted: () {
              setState(() => _addedBooks.remove(book));
              widget.group.books = _addedBooks;
            },
          )).toList(),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 24.0, bottom: 16),
          child: Text('Selecione o período de leitura', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
        ),
        TextFormField(
          readOnly: true,
          controller: _startController,
          decoration: const InputDecoration(
            hintText: 'Escolha a data',
            hintStyle: TextStyle(color: Colors.grey),
            label: Text('Data de início'),
          ),
          onTap: () => showDatePicker(
            context: context,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 1000)),
            barrierDismissible: false,
            confirmText: 'OK',
            cancelText: 'Cancelar',
            initialDate: DateTime.now(),

          ).then((value) {
            _startController.text = value?.formatted() ?? '';
            widget.group.startDate = value;
          }),
        ),
        const SizedBox(height: 24),
        TextFormField(
          readOnly: true,
          controller: _endController,
          decoration: const InputDecoration(
            hintText: 'Escolha a data',
            hintStyle: TextStyle(color: Colors.grey),
            label: Text('Data de conclusão'),
          ),
          onTap: () => showDatePicker(
            context: context,
            firstDate: DateTime.now().add(const Duration(days: 30)),
            lastDate: DateTime.now().add(const Duration(days: 1000)),
            barrierDismissible: false,
            confirmText: 'OK',
            cancelText: 'Cancelar',
            initialDate: DateTime.now().add(const Duration(days: 30)),

          ).then((value) {
            _endController.text = value?.formatted() ?? '';
            widget.group.endDate = value;
          }),
        )
      ],
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
        widget.group.bgUrl = croppedImage.path;
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