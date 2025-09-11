import 'package:biblia_flutter_app/data/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResetPassModal extends StatefulWidget {
  const ResetPassModal({super.key});

  @override
  State<ResetPassModal> createState() => _ResetPassModalState();
}

class _ResetPassModalState extends State<ResetPassModal> {
  final GlobalKey<FormState> _key = GlobalKey();
  final TextEditingController _emailContorller = TextEditingController();
  bool _loading = false;
  String _errorMsg = '';

  Future<void> resetPass() async {
    final groupsProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      setState(() => _loading = true);
      await groupsProvider.resetPassword(_emailContorller.text);
      setState(() => _loading = false);
      Navigator.pop(context, _emailContorller.text);
    }catch(e) {
      setState(() {
        //_errorMsg = e.translated;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informe seu email para receber um link para redefinição de sua senha.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailContorller,
              validator: (value) {
                if(value?.isEmpty ?? true) {
                  return 'Este campo é obrigatório';
                }

                return null;
              },
              decoration: const InputDecoration(
                hintText: 'Digite seu email aqui...'
              ),
            ),
            if(_errorMsg.isNotEmpty)
              Text(_errorMsg, style: const TextStyle(color: Colors.red)),
            const Spacer(),
            if(_loading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: () {
                  setState(() => _errorMsg = '');
                  if(_key.currentState!.validate()) {
                    resetPass();
                  }
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(500, 40),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Enviar email')
              )
          ],
        ),
      ),
    );
  }
}
