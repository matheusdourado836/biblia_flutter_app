import 'package:biblia_flutter_app/data/bible_data.dart';
import 'package:biblia_flutter_app/helpers/version_to_name.dart';
import 'package:biblia_flutter_app/models/book.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/version_provider.dart';
import '../../../helpers/progress_dialog.dart';

class SelectVersionsDialog extends StatefulWidget {
  final BookFull book;
  const SelectVersionsDialog({super.key, required this.book});

  @override
  State<SelectVersionsDialog> createState() => _SelectVersionsDialogState();
}

class _SelectVersionsDialogState extends State<SelectVersionsDialog> {
  static final BibleData _bibleData = BibleData();
  List<String> _downloadedVersions = [];
  final List<String> availableVersions = [
    'NVI', 'ACF', 'NTLH', 'RA', 'KJV', 'BBE', 'RVR', 'APEE', 'GREGO'
  ];
  String? selectedVersion1;
  String? selectedVersion2;


  Widget buildVersionDropdowns() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildVersionDropdown(
          label: 'Versão 1',
          selected: selectedVersion1,
          onChanged: (value) => setState(() => selectedVersion1 = value),
        ),
        const SizedBox(height: 12),
        _buildVersionDropdown(
          label: 'Versão 2',
          selected: selectedVersion2,
          onChanged: (value) => setState(() => selectedVersion2 = value),
        ),
      ],
    );
  }

  Widget _buildVersionDropdown({
    required String label,
    required String? selected,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: selected,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
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
      onChanged: onChanged,
    );
  }

  Future<void> downloadVersions() async {
    final versionProvider = Provider.of<VersionProvider>(context, listen: false);
    final version1Formatted = versionToName(selectedVersion1!);
    final version2Formatted = versionToName(selectedVersion2!);
    if(!_downloadedVersions.contains(version1Formatted)) {
      final res = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProgressDialog(
          versionName: versionToName(selectedVersion1!),
          versionNameRaw: selectedVersion1!,
        ),
      );
      if(res != true) return;
      await versionProvider.loadBibleData();

    }
    if(!_downloadedVersions.contains(version2Formatted)) {
      final res = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProgressDialog(
          versionName: versionToName(selectedVersion2!),
          versionNameRaw: selectedVersion2!,
        ),
      );
      if(res != true) return;
      await versionProvider.loadBibleData();
    }

    Navigator.popAndPushNamed(
        context,
        'multi_version_screen',
        arguments: {
          'book': widget.book,
          'version1': selectedVersion1,
          'version2': selectedVersion2
        }
    );
  }

  @override
  void initState() {
    _downloadedVersions = _bibleData.downloadedVersions;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecione as versões'),
      content: buildVersionDropdowns(),
      actions: [
        TextButton(
          onPressed: () async {
            if (selectedVersion1 != null && selectedVersion2 != null) {
              await downloadVersions();
            }
          },
          child: const Text('OK'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
