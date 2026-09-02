import 'package:biblia_flutter_app/data/devocional_provider.dart';
import 'package:biblia_flutter_app/models/devocional.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

GlobalKey<FormState> _formKey = GlobalKey<FormState>();
final TextEditingController _controller = TextEditingController();

class RejectReasonDialog extends StatelessWidget {
  final Devocional devocional;
  const RejectReasonDialog({super.key, required this.devocional});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Motivo: ${devocional.rejectReason}'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Se achar que isso foi um engano você pode pedir uma nova revisão do seu post. '
              'Basta digitar seu argumento no campo abaixo e enviar seu pedido de revisão e seu post será reavaliado'),
          ArgumentField()
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        TextButton(
          onPressed: () {
            if(_formKey.currentState!.validate()) {
              final devocionalProvider = Provider.of<DevocionalProvider>(context, listen: false);
              devocionalProvider.sendReview(devocional: devocional, argument: _controller.text);
              Navigator.pop(context, true);
            }
          },
          child: const Text('Pedir revisão')
        ),
      ],
    );
  }
}

class ArgumentField extends StatefulWidget {
  const ArgumentField({super.key});

  @override
  State<ArgumentField> createState() => _ArgumentFieldState();
}

class _ArgumentFieldState extends State<ArgumentField> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Digite seu texto aqui...'
        ),
        validator: (value) {
          if((value?.isEmpty ?? true) || value!.length < 5) {
            return 'digite pelo menos 5 caracteres';
          }

          return null;
        },
      ),
    );
  }
}
