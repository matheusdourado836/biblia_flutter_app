import 'package:biblia_flutter_app/data/user_provider.dart';
import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:biblia_flutter_app/models/group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SolicitationsScreen extends StatefulWidget {
  final Group group;
  const SolicitationsScreen({super.key, required this.group});

  @override
  State<SolicitationsScreen> createState() => _SolicitationsScreenState();
}

class _SolicitationsScreenState extends State<SolicitationsScreen> {
  late final UserProvider _groupsProvider = Provider.of<UserProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitações'),
        actions: [
          IconButton(
            onPressed: () {
              _groupsProvider.getInvites(groupId: widget.group.id!).then((res) {
                setState(() {
                  widget.group.solicitacoes = res;
                });
              });
            },
            icon: const Icon(Icons.refresh)
          )
        ],
      ),
      body: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: Consumer<UserProvider>(
          builder: (context, value, _) {
            if(value.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if(widget.group.solicitacoes?.isEmpty ?? true) {
              return Column(
                children: [
                  SvgPicture.asset('assets/images/notifications.svg'),
                  const Text('Nenhuma solicitação ainda...',
                    textAlign: TextAlign.center,
                  )
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.group.solicitacoes?.map((invite) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(invite.user?.nomeUsuario ?? ''),
                          Text(
                            invite.createdAt?.formatted() ?? DateTime.now().formatted(),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Transform.scale(
                            scale: .75,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _groupsProvider.confirmSolicitation(group: widget.group, invite: invite).whenComplete(() {
                                  showCustomSnackBar(child: const Text('Solicitação aceita com sucesso!'));
                                });
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                              ),
                              label: const Text('Aceitar'),
                              icon: const Icon(Icons.check, color: Colors.white,),
                            ),
                          ),
                          Transform.scale(
                            scale: .75,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _groupsProvider.rejectSolicitation(group: widget.group, invite: invite).whenComplete(() {
                                  showCustomSnackBar(child: const Text('Solicitação removida com sucesso!')
                                  );
                                });
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                              ),
                              label: const Text('Rejeitar'),
                              icon: const Icon(Icons.close, color: Colors.white,),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                );
              }).toList() ?? [],
            );
          },
        ),
      ),
    );
  }
}
