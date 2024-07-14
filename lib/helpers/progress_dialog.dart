import 'package:biblia_flutter_app/data/version_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProgressDialog extends StatefulWidget {
  final String versionName;
  const ProgressDialog({super.key, required this.versionName});

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
      title: const Text('Baixando versão'),
      contentPadding: const EdgeInsets.all(24.0),
      content: Consumer<VersionProvider>(
        builder: (context, value, _) {
          if(value.downloadCompleted) {
            value.setDownloadProgress = false;
            Navigator.pop(context);
          }
          if(value.downloadError.isNotEmpty) {
            return Center(
              child: Text(value.downloadError),
            );
          }
          final progress = value.downloadProgress * 100 > 100 ? 100 : value.downloadProgress;
          return Row(
            children: [
              Text('Progresso: ${(progress.toStringAsFixed(0))}% ', style: const TextStyle(fontSize: 14),),
              Expanded(
                  child: LinearProgressIndicator(
                    value: value.downloadProgress,
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
