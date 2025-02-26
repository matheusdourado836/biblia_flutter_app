import 'package:biblia_flutter_app/data/reading_groups_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final GlobalKey _key = GlobalKey<FormState>();
  late final ReadingGroupsProvider _groupsProvider = Provider.of<ReadingGroupsProvider>(context, listen:  false);
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    _nameController.text = _groupsProvider.currentUser!.nomeUsuario ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar nome de usuário'),
      content: Form(
        key: _key,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if(value?.isEmpty ?? true) {
                    return 'O nome não pode estar vazio';
                  }

                  return null;
                },
                decoration: const InputDecoration(
                    labelText: 'Nome de usuário',
                    hintText: 'Digite seu novo nome de usuário'
                ),
              ),
              const Spacer(),
              ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      fixedSize: const Size(500, 40)
                  ),
                  child: const Text('Salvar')
              ),
              const SizedBox(height: 12)
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {},
          child: const Text('Salvar')
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      ],
    );
  }
}
