import 'package:biblia_flutter_app/data/version_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProgressDialog extends StatefulWidget {
  final String versionName;
  final String versionNameRaw;
  const ProgressDialog({super.key, required this.versionName, required this.versionNameRaw});

  @override
  State<ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> {

  @override
  void initState() {
    final versionProvider = Provider.of<VersionProvider>(context, listen: false);
    versionProvider.downloadVersion(versionName: widget.versionName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.center,
      title: Text('Baixando versão - ${widget.versionNameRaw}', style: const TextStyle(fontSize: 20),),
      contentPadding: const EdgeInsets.all(24.0),
      content: Consumer<VersionProvider>(
        builder: (context, value, _) {
          if(value.downloadCompleted) {
            value.setDownloadProgress = false;
            Navigator.pop(context, true);
          }
          if(value.downloadError.isNotEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value.downloadError),
                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.surface,
                      ),
                      onPressed: () => value.downloadVersion(versionName: widget.versionName),
                      child: const Text('Tentar novamente')
                    ),
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar', style: TextStyle(decoration: TextDecoration.underline),))
                  ],
                )
              ],
            );
          }
          final progress = value.downloadProgress;
          return Row(
            children: [
              Text('Progresso: ${(progress.toStringAsFixed(0))}% ', style: const TextStyle(fontSize: 14),),
              Expanded(
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(2),
                    backgroundColor: Colors.black,
                  )
              ),
            ],
          );
        },
      )
    );
  }
}
