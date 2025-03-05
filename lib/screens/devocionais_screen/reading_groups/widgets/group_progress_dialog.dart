import 'package:biblia_flutter_app/data/reading_groups_provider.dart';
import 'package:biblia_flutter_app/models/group.dart';
import 'package:biblia_flutter_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupProgressDialog extends StatefulWidget {
  final Group group;
  final Map<String, List<String>> capitulos;
  final List<String> chaptersLabel;
  final List<MyUser> participantes;
  const GroupProgressDialog({super.key, required this.capitulos, required this.participantes, required this.chaptersLabel, required this.group});

  @override
  State<GroupProgressDialog> createState() => _GroupProgressDialogState();
}

class _GroupProgressDialogState extends State<GroupProgressDialog> {
  List<MapEntry<String, List<String>>> sortedChapters = [];

  DataCell _userInfo(BuildContext context, MyUser user, String chapter, bool value) {
    return DataCell(Checkbox(
        value: value,
        onChanged: (newValue) {
          final groupsProvider = Provider.of<ReadingGroupsProvider>(context, listen: false);
          if(groupsProvider.currentUser!.id == widget.group.ownerId) {
            final index = widget.chaptersLabel.indexOf(chapter) + 1;
            if(value) {
              widget.capitulos[index.toString()]!.remove(user.id);
            }else {
              widget.capitulos[index.toString()]!.add(user.id!);
            }
            groupsProvider.updateDailyReading(widget.group.dailyReading!, widget.group.id!);
            setState(() {
              sortedChapters = widget.capitulos.entries.toList()
                ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
            });
          }
        })
    );
  }

  @override
  void initState() {
    sortedChapters = widget.capitulos.entries.toList()
      ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const Column(
          children: [
            Text(
                'Progresso do grupo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            Text(
                'arraste para o lado para ver mais',
                style: TextStyle(fontSize: 12, color: Colors.grey)
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                const DataColumn(label: Text('Nomes')),
                for (var chapter in widget.chaptersLabel)
                  DataColumn(label: Text('CAP $chapter'))
              ],
              rows: widget.participantes.map((user) => DataRow(
                cells: [
                  DataCell(SizedBox(width: 80, child: Text(user.nomeUsuario!))),
                  for (var (index, chapter) in sortedChapters.indexed)
                    if (chapter.value.contains(user.id!))
                      _userInfo(context, user, widget.chaptersLabel[index], true)
                    else
                      _userInfo(context, user, widget.chaptersLabel[index], false)
                ]
              )).toList()
            ),
          ),
        )
      ],
    );
  }
}
