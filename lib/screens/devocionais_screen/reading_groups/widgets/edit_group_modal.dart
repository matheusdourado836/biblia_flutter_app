import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:biblia_flutter_app/models/group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../data/user_provider.dart';
import '../../../../helpers/image_container.dart';
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
  late final UserProvider _usersProvider = Provider.of<UserProvider>(context, listen: false);
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

  Widget _loadingWidget() => const Center(
    child: SizedBox(
      height: 35,
      width: 35,
      child: CircularProgressIndicator(),
    ),
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
      await _usersProvider.updateGroupData(group.toJson()..remove('solicitacoes'), group.id!);
      setState(() => _saving = false);
      _usersProvider.getUserGroups(notify: true);
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
    _updatedBgUrl = group.bgUrl;
    _titleController.text = group.nome!;
    _descController.text = group.descricao ?? '';
    _numberPeopleController.text = group.maxPeople.toString();
    _selectedOption = group.plan ?? 'Bíblia toda em 1 ano';
    _books.add('Todos');
    _books.add('Adicionar antigo testamento');
    _books.add('Adicionar novo testamento');
    for (var book in _usersProvider.bibleData[0]["text"]) {
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
          const SizedBox(height: 24),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 32)
            ),
          ),
          ProfileContainer(
            user: _usersProvider.currentUser!,
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
                if(_updatedBgUrl != group.bgUrl) {
                  group.bgUrl = group.bgUrl;
                  final res = await _usersProvider.uploadGroupPicture(group);
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