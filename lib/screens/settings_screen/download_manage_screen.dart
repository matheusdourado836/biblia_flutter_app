import 'package:biblia_flutter_app/data/version_provider.dart';
import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:biblia_flutter_app/helpers/version_to_name.dart';
import 'package:biblia_flutter_app/screens/settings_screen/remove_all_dialog.dart';
import 'package:biblia_flutter_app/screens/settings_screen/remove_version_dialog.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadManageScreen extends StatefulWidget {
  final EventBus eventBus;
  const DownloadManageScreen({super.key, required this.eventBus});

  @override
  State<DownloadManageScreen> createState() => _DownloadManageScreenState();
}

class _DownloadManageScreenState extends State<DownloadManageScreen> {
  late final VersionProvider _versionProvider = Provider.of<VersionProvider>(context, listen: false);
  List<dynamic> _downloadedVersions = [];

  Future<void> removeAllVersions() async {
    final res = await showDialog(context: context, builder: (context) => RemoveAllDialog());
    if(res == true) {
      await checkAndRemoveFromPrefs(versions: _downloadedVersions.map((v) => v["version"] as String).toList());
      await _versionProvider.deleteVersions(versions: _downloadedVersions.map((v) => v["version"] as String).toList());
      setState(() => _downloadedVersions.clear());
      showCustomSnackBar(child: Text('Versões removidas com sucesso!'));
    }
  }

  Future<void> removeVersions({required List<String> versions}) async {
    final res = await showDialog(context: context, builder: (context) => RemoveVersionDialog());
    if(res == true) {
      await checkAndRemoveFromPrefs(versions: versions);
      await _versionProvider.deleteVersions(versions: versions);
      setState(() {
        _downloadedVersions = _downloadedVersions.where((v) => !versions.contains(v["version"])).toList();
      });
      showCustomSnackBar(child: Text('Versão ${nameToVersion(versions.first).toUpperCase()} removida com sucesso!'));
    }
  }

  Future<void> checkAndRemoveFromPrefs({required List<String> versions}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasVersion = false;
    for(var version in versions) {
      final versionSaved = prefs.getString('version')?.split(' ')[0].toLowerCase();
      if(versionSaved == nameToVersion(version)) {
        hasVersion = true;
        await prefs.remove(version);
      }
      if(_versionProvider.selectedOption.split(' ')[0].toLowerCase() == nameToVersion(version)) {
        _versionProvider.changeVersion('NVI (Nova Versão Internacional)');
      }
    }
    if(hasVersion) {
      widget.eventBus.fire('Reset');
    }
  }

  Widget emptyListPlaceholder() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
        'assets/images/nothing_yet.png',
        width: double.infinity,
        height: MediaQuery.of(context).size.height * .55,
      ),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: const Text('Você não baixou nenhuma versão ainda...',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200), textAlign: TextAlign.center),
      )
    ],
  );

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final defaultVersions = ['nvi', 'acf', 'en_kjv', 'ntlh', 'aa'];
      _downloadedVersions = _versionProvider.getVersions().where((v) => !defaultVersions.contains(v["version"])).toList();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar downloads'),
        centerTitle: true,
        actions: [
          if(_downloadedVersions.isNotEmpty)
            IconButton(
                onPressed: removeAllVersions,
                icon: const Icon(Icons.delete_forever)
            )
        ],
      ),
      body: _downloadedVersions.isEmpty ? emptyListPlaceholder() : ListView.separated(
        itemCount: _downloadedVersions.length,
        itemBuilder: (context, index) {
          final version = _downloadedVersions[index];
          return ListTile(
            title: Text(nameToVersion(version["version"]).toUpperCase()),
            subtitle: Text('${version["size"]} MB', style: TextStyle(color: Colors.grey, fontSize: 10)),
            trailing: IconButton(onPressed: () => removeVersions(versions: [version["version"]]), icon: const Icon(Icons.delete)),
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}
