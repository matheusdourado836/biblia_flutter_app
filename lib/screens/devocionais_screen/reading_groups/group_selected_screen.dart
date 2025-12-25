import 'dart:async';
import 'package:biblia_flutter_app/helpers/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../data/user_provider.dart';
import '../../../models/daily_read.dart';
import '../../../models/group.dart';
import '../../../models/message.dart';
import '../../../models/user.dart';

class GroupSelectedScreen extends StatefulWidget {
  final String groupId;
  const GroupSelectedScreen({super.key, required this.groupId});

  @override
  State<GroupSelectedScreen> createState() => _GroupSelectedScreenState();
}

class _GroupSelectedScreenState extends State<GroupSelectedScreen> {
  late final usersProvider = Provider.of<UserProvider>(context, listen: false);
  Group? group;

  List<Map<String, dynamic>> books = [];
  List<List<Map<String, dynamic>>> dailyReadings = [];
  List<MyUser> participantes = [];
  StreamSubscription<List<Message>>? listener;

  int qtdChapters = 0;
  int difference = 0;
  int daysMissed = 0;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupInitialData());
  }

  @override
  void dispose() {
    listener?.cancel();
    super.dispose();
  }

  Future<void> _setupInitialData() async {
    setState(() => _loading = true);
    group = await usersProvider.getGroupById(groupId: widget.groupId);
    if (group == null) return;
    final startDate = group!.startDate!;
    final daysList = group!.dailyReading?.dias.entries.toList() ?? [];
    daysList.sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));

    difference = DateTime.now().difference(startDate).inDays;

    if (difference > 0 && difference < daysList.length) {
      final daysPassed = daysList.sublist(0, difference);
      daysMissed = daysPassed.where(
            (d) => d.value.capitulos.values
            .where((listIds) => listIds.length == group!.participantes!.length)
            .isEmpty,
      ).length;
    } else if (difference > daysList.length) {
      daysMissed = -1;
    }

    listener = usersProvider.getGroupMessages(group!.id!).listen(usersProvider.newMessage);

    if (participantes.isEmpty) {
      final res = await usersProvider.getUsersById(ids: group!.participantes ?? []);
      if (res?.isNotEmpty ?? false) {
        participantes = res!;
        participantes.sort((a, b) => a.id == group!.ownerId ? 0 : 1);
        setState(() {});
      }
    }

    _initializeReadingPlan();
  }

  void _initializeReadingPlan() {
    books.clear();
    qtdChapters = 0;

    for (var book in group!.books ?? []) {
      final data = usersProvider.bibleData[0]["text"].firstWhere((b) => b["name"] == book);
      for (var (index, chapter) in (data["chapters"] as List).indexed) {
        books.add({
          "book": data["name"],
          "chapter": chapter,
          "number": index + 1,
        });
      }
      qtdChapters += (data["chapters"] as List).length;
    }

    final qtdDays = group!.endDate!.difference(group!.startDate!).inDays;
    dailyReadings = _generateDailyReadings(books, qtdDays);
    setState(() => _loading = false);
  }

  List<List<Map<String, dynamic>>> _generateDailyReadings(
      List<Map<String, dynamic>> chapters,
      int days,
      ) {
    List<List<Map<String, dynamic>>> plan = [];
    final dailyReading = GroupDailyReading(dias: {});
    final Map<String, DayReading> daysMap = {};

    int chaptersPerDay = chapters.length ~/ days;
    int remainingChapters = chapters.length % days;
    int currentIndex = 0;

    for (int i = 0; i < days; i++) {
      int chaptersForToday = chaptersPerDay + (remainingChapters > 0 ? 1 : 0);
      if (remainingChapters > 0) remainingChapters--;

      Map<String, List<String>> capitulos = {};
      for (var (index, _) in chapters.sublist(currentIndex, currentIndex + chaptersForToday).indexed) {
        capitulos[(index + 1).toString()] = [];
      }

      daysMap[(i + 1).toString()] = DayReading(capitulos: capitulos);
      plan.add(chapters.sublist(currentIndex, currentIndex + chaptersForToday));
      currentIndex += chaptersForToday;
    }

    if (group!.dailyReading == null) {
      dailyReading.dias = daysMap;
      group!.dailyReading = dailyReading;
      usersProvider.updateGroupData({"dailyReading": dailyReading.toJson()}, group!.id!);
    }

    return plan;
  }

  Future<void> _refreshData() async {
    await _setupInitialData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Theme.of(context).primaryColor,
      body: RefreshIndicator.adaptive(
        onRefresh: _refreshData,
        child: (_loading || group == null) ? const Center(child: CircularProgressIndicator()) : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 4 / 4,
          ),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 150),
          itemCount: dailyReadings.length,
          itemBuilder: (context, index) => _buildDayCard(index),
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildDaysCount() {
    if(group?.startDate?.isAfter(DateTime.now()) ?? false) {
      return Text(
        'Começa em ${group?.startDate?.difference(DateTime.now()).inDays} dias',
        style: TextStyle(fontSize: 12)
      );
    }
    if (daysMissed == -1) {
      return const Text('Leitura finalizada', style: TextStyle(fontSize: 12));
    } else if (daysMissed == 0) {
      return const Text('Leitura em dia', style: TextStyle(fontSize: 12));
    }
    else {
      return Text(
        'Leitura atrasada em $daysMissed dias',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      );
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Column(
        children: [
          Text(group?.nome ?? ''),
          const SizedBox(height: 4),
          _buildDaysCount()
        ],
      ),
      actions: [
        if(group?.ownerId == usersProvider.currentUser!.id)
          IconButton(
            onPressed: () => Navigator.pushNamed(
              context,
              'group_admin_config_screen',
              arguments: {"group": group, "participantes": participantes}
            ),
            icon: const Icon(Icons.settings)
          ),
        if(group?.ownerId != usersProvider.currentUser!.id && participantes.isNotEmpty)
          _buildPopupMenu()
      ],
    );
  }

  Widget _buildDayCard(int index) {
    final allRead = group!.dailyReading?.dias[(index + 1).toString()]
        ?.capitulos
        .values
        .every((listIds) => listIds.length == group!.participantes!.length) ??
        false;

    return Stack(
      children: [
        InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            'day_selected_screen',
            arguments: {
              "day": 'DIA ${index + 1}',
              "chapters": dailyReadings[index],
              "group": group,
            },
          ).whenComplete(() => setState(() {})),
          child: Card(
            child: Center(
              child: Text(
                'DIA\n${index + 1}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        if (allRead)
          Positioned(
            top: 0,
            left: 0,
            child: Icon(
              Icons.check_circle,
              color: Theme.of(context).buttonTheme.colorScheme?.secondary,
            ),
          ),
      ],
    ).animate(
      target: index == difference ? 1 : 0,
      onComplete: (c) {
        if (index == difference) c.repeat();
      },
    ).moveY(begin: 10, end: -10, curve: Curves.easeInOut, duration: 800.ms).then().moveY(begin: -10, end: 10, curve: Curves.easeInOut);
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            onTap: () => _showParticipantsBottomSheet(),
            child: const Text('Ver participantes'),
          ),
          PopupMenuItem(
            onTap: () => _confirmLeaveGroup(),
            child: const Text('Sair do grupo'),
          ),
        ];
      },
    );
  }

  void _showParticipantsBottomSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              'Membros: ${participantes.length}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            itemCount: participantes.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final user = participantes[index];
              return ListTile(
                horizontalTitleGap: 0,
                leading: Text('${index + 1}.'),
                title: Text(
                  user.id == group!.ownerId ? '${user.nomeUsuario} (Admin)' : user.nomeUsuario!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: user.id == group!.ownerId ? Colors.green : null,
                  ),
                ),
              );
            }
          )
        ],
      ),
    );
  }

  void _confirmLeaveGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar ação'),
        content: const Text('Tem certeza que deseja sair deste grupo?'),
        actions: [
          TextButton(
            onPressed: () {
              usersProvider.leaveGroup(group: group!).whenComplete(() {
                showCustomSnackBar(child: Text('Você saiu do grupo "${group!.nome}"'));
                usersProvider.getUserGroups(notify: true).whenComplete(() {
                  Navigator.popUntil(context, (route) => route.settings.name == 'user_home_screen');
                });
              });
            },
            child: const Text('Sim'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return Consumer<UserProvider>(
      builder: (context, value, _) {
        return FloatingActionButton(
          backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
          onPressed: () {
            value.markMessagesAsRead(groupId: group!.id!);
            Navigator.pushNamed(
              context,
              'chat_screen',
              arguments: {"group": group!, "participantes": participantes},
            );
          },
          child: Badge.count(
            count: value.unreadMessages,
            child: Icon(
              Icons.chat_bubble,
              size: 26,
              color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
            ),
          ),
        );
      },
    );
  }
}