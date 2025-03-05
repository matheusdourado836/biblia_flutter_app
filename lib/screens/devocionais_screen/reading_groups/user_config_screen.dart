import 'package:biblia_flutter_app/data/reading_groups_provider.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/reading_groups/widgets/change_pass_modal.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/reading_groups/widgets/delete_account_dialog.dart';
import 'package:biblia_flutter_app/screens/devocionais_screen/reading_groups/widgets/edit_username_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserConfigScreen extends StatelessWidget {
  const UserConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ReadingGroupsProvider groupsProvider = Provider.of<ReadingGroupsProvider>(context, listen:  false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false),
            leading: const Icon(Icons.home),
            title: const Text('Ínicio'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          ListTile(
            onTap: () => showDialog(
              context: context,
              builder: (context) => const EditUsernameDialog()
            ),
            leading: const Icon(Icons.person),
            title: const Text('Editar nome de usuário'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          ListTile(
            onTap: () => showModalBottomSheet(
                context: context,
                useSafeArea: true,
                builder: (context) => const ChangePassModal()
            ),
            leading: const Icon(Icons.lock),
            title: const Text('Alterar senha'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          ListTile(
            onTap: () => showDialog(
              context: context,
              builder: (context) => const DeleteAccountDialog()
            ),
            iconColor: Colors.red,
            textColor: Colors.red,
            leading: const Icon(Icons.delete),
            title: const Text('Deletar conta'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          ListTile(
            onTap: () => groupsProvider.doLogout().whenComplete(() => Navigator.pushNamedAndRemoveUntil(
                context, 'login_screen', (route) => route.settings.name == 'devocionais_screen'
            )),
            leading: const Icon(Icons.logout),
            iconColor: Colors.red,
            textColor: Colors.red,
            title: const Text('Sair'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
          )
        ],
      ),
    );
  }
}
