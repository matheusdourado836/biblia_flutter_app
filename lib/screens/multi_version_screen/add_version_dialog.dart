import 'package:flutter/material.dart';

import '../../data/bible_data.dart';
import '../../helpers/version_to_name.dart';

class AddVersionDialog extends StatefulWidget {
  const AddVersionDialog({super.key});

  @override
  State<AddVersionDialog> createState() => _AddVersionDialogState();
}

class _AddVersionDialogState extends State<AddVersionDialog> {
  static final BibleData _bibleData = BibleData();
  List<String> _downloadedVersions = [];
  final List<String> availableVersions = [
    'NVI', 'ACF', 'NTLH', 'RA', 'KJV', 'BBE', 'RVR', 'APEE', 'GREGO'
  ];
  String selectedVersion = 'NVI';

  @override
  void initState() {
    _downloadedVersions = _bibleData.downloadedVersions;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Versão'),
      content: DropdownButton<String>(
        value: selectedVersion,
        items: availableVersions.map((version) {
          final isInstalled = _downloadedVersions.contains(versionToName(version));
          return DropdownMenuItem<String>(
            value: version,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(version, style: Theme.of(context).textTheme.titleSmall,),
                if (!isInstalled)
                  const Icon(Icons.download_rounded, size: 18, color: Colors.grey),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) => setState(() => selectedVersion = value!),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, selectedVersion),
            child: const Text('Ok')
        )
      ],
    );
  }
}
