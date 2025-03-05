import 'package:biblia_flutter_app/models/user.dart';
import 'package:flutter/material.dart';

class ParticipantesModal extends StatefulWidget {
  final List<MyUser> participantes;
  final String ownerId;
  const ParticipantesModal({super.key, required this.participantes, required this.ownerId});

  @override
  State<ParticipantesModal> createState() => _ParticipantesModalState();
}

class _ParticipantesModalState extends State<ParticipantesModal> {
  List<String> participantesRemoved = [];

  @override
  void initState() {
    widget.participantes.sort((a, b) => a.id == widget.ownerId ? 0 : 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.participantes.map((p) => ListTile(
          title: Text((widget.ownerId == p.id!) ? '${p.nomeUsuario!}(você)' : p.nomeUsuario!),
          iconColor: Colors.red,
          trailing: (widget.ownerId == p.id!) ? null : TextButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Remover ${p.nomeUsuario!}?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      widget.participantes.remove(p);
                      participantesRemoved.add(p.id!);
                      setState(() {});
                      Navigator.pop(context, true);
                    },
                    child: const Text('Sim')
                  ),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Não')),
                ],
              )
            ).then((res) {
              if(res ?? false) {
                Navigator.pop(context, participantesRemoved);
              }
            }),
            label: const Text('Remover', style: TextStyle(color: Colors.red),),
            icon: const Icon(Icons.delete, color: Colors.red,)
          ),
        )).toList(),
      ),
    );
  }
}
