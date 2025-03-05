import 'package:biblia_flutter_app/screens/devocionais_screen/reading_groups/widgets/join_group_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/reading_groups_provider.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupsProvider = Provider.of<ReadingGroupsProvider>(context, listen: false);
    final username = groupsProvider.currentUser!.nomeUsuario!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Olá $username'),
        actions: [
          IconButton(onPressed: () => Navigator.pushNamed(context, 'user_config_screen'), icon: const Icon(Icons.settings))
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () => groupsProvider.getUserGroups(notify: true),
        child: Consumer<ReadingGroupsProvider>(
          builder: (context, value, _) {
            if(value.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if(value.currentUser!.gruposParticipantes?.isEmpty ?? true) {
              return Column(
                children: [
                  Image.asset('assets/images/nothing_yet.png'),
                  const Text('Você ainda não esta participando de nenhum grupo.'
                      '\nExperimente criar um ou peça um código de convite para alguém',
                    textAlign: TextAlign.center,
                  )
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
                itemBuilder: (context, index) {
                  final group = value.currentUser!.gruposParticipantes![index];
                  return ListTile(
                    onTap: () {
                      if(group.ownerId == value.currentUser!.id) {
                        Navigator.pushNamed(
                            context,
                            'group_selected_admin_screen',
                            arguments: {"group": group}
                        );
                      }else {
                        Navigator.pushNamed(
                            context,
                            'group_selected_screen',
                            arguments: {"group": group}
                        );
                      }
                    },
                    leading: InkWell(
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: Stack(
                            children: [
                              InteractiveViewer(
                                child: (group.bgUrl?.isEmpty ?? true)
                                  ? Image.asset('assets/images/icone.png')
                                  : CachedNetworkImage(
                                      imageUrl: group.bgUrl ?? '',
                                      fit: BoxFit.contain,
                                      errorListener: (o) => Container()
                                    ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  width: 300,
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.black38
                                  ),
                                  child: Text(
                                    group.nome!,
                                    style: const TextStyle(color: Colors.white, fontSize: 18)
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: (group.bgUrl?.isEmpty ?? true)
                            ? const AssetImage('assets/images/icone.png')
                            :  CachedNetworkImageProvider(
                          group.bgUrl ?? '',
                          errorListener: (o) => Container()
                        ),
                      ),
                    ),
                    title: Text(group.nome ?? ''),
                    subtitle: Text(group.descricao ?? ''),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
                itemCount: value.currentUser!.gruposParticipantes!.length
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
        tooltip: 'Criar grupo',
        onPressed: () => showModalBottomSheet(
            context: context,
            builder: (context) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      alignment: AlignmentDirectional.centerStart
                    ),
                    onPressed: () => Navigator.pushNamed(context, 'create_group_screen'),
                    label: const Text('Criar grupo'),
                    icon: const Icon(Icons.add),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                        alignment: AlignmentDirectional.centerStart
                    ),
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) => const JoinGroupDialog()
                    ).whenComplete(() => Navigator.pop(context)),
                    label: const Text('Entrar em um grupo'),
                    icon: const Icon(Icons.login),
                  ),
                ],
              ),
            )
        ),
        child: Icon(
          Icons.add,
          size: 26,
          color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
        ),
      ),
    );
  }
}
