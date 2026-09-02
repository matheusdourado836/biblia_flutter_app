import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/theme_provider.dart';
import '../../../data/verses_provider.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  late final VersesProvider versesProvider;
  late final ThemeProvider themeProvider;
  final DateTime today = DateTime.now();
  int readBooks = 0;
  int qtdVerses = 0;
  int qtdAnnotations = 0;
  double width = 0.0;
  double height = 0.0;
  bool removeBadge = false;

  double _formatValue(double value) {
    value = value * 100;
    var formatedLevel = value.toStringAsFixed(2);

    return double.parse(formatedLevel);
  }

  @override
  void initState() {
    versesProvider = Provider.of<VersesProvider>(context, listen: false);
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if(themeProvider.themeMode == null) {
      themeProvider.getThemeMode();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        removeBadge = today.year == 2024 && today.month == 9 && today.day == 18;
        readBooks = versesProvider.listMap.where((element) => element['finishedReading'] == 1).length;
        qtdVerses = versesProvider.qtdVerses;
        qtdAnnotations = versesProvider.qtdAnnotations;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.sizeOf(context).width;
    height = MediaQuery.sizeOf(context).height;
    final screenOrientation = MediaQuery.of(context).orientation;
    return (screenOrientation == Orientation.landscape)
        ? _LandscapeDrawer(
      readingProgressWidget: _readingProgressWidget(Orientation.landscape),
      savedVersesWidget: _savedVersesWidget(),
      aiWidget: _aiWidget(),
      annotationsWidget: _annotationsWidget(),
      searchPassagesWidget: _searchPassagesWidget(),
      toggleModeWidget: _toggleModeWidget(),
      devocionalWidget: _devocionaisWidget(),
      settingsWidget: _settingsWidget(),
    )
        : _PortraitDrawer(
      readingProgressWidget:_readingProgressWidget(Orientation.portrait),
      savedVersesWidget: _savedVersesWidget(),
      aiWidget: _aiWidget(),
      annotationsWidget: _annotationsWidget(),
      searchPassagesWidget: _searchPassagesWidget(),
      toggleModeWidget: _toggleModeWidget(),
      devocionalWidget: _devocionaisWidget(),
      settingsWidget: _settingsWidget(),
    );
  }

  Widget _readingProgressWidget(Orientation orientataion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        height: (orientataion == Orientation.landscape && width < 900) ? height * .57 : height * .29,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.only(bottomRight: Radius.circular(14)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.0, 16.0, 0.0, (width > 500 && orientataion == Orientation.portrait) ? 72 : 12.0),
              child: Row(
                children: [
                  SizedBox(
                    height: (width > 500 && orientataion == Orientation.portrait) ? 150 : 80,
                    width: (width > 500 && orientataion == Orientation.portrait) ? 150 : 80,
                    child: CircularProgressIndicator(
                      strokeWidth: (width > 500) ? 10.0 : 8.0,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      color: Theme.of(context).colorScheme.onSurface,
                      value: readBooks / 66,
                    ),
                  ),
                  Text(
                    '    Progresso: ${_formatValue(readBooks / 66)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 0.0, 12.0),
              child: Text(
                'Livros Lidos:\n$readBooks / 66',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiWidget() {
    return ListTileDrawer(
      onTap: () => Navigator.pushNamed(context, 'ai_screen'),
      leading: Icons.lightbulb,
      title: 'Pesquisa com IA',
      trailing: removeBadge ? const SizedBox() : Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Theme.of(context).colorScheme.primary),
          color: Theme.of(context).colorScheme.primary
        ),
        child: const Text('NOVO', style: TextStyle(fontSize: 8, color: Colors.white),),
      ),
    );
  }

  Widget _savedVersesWidget() {
    return ListTileDrawer(
      onTap: () => Navigator.popAndPushNamed(context, 'saved_verses'),
      leading: Icons.bookmark,
      title: 'Versículos Salvos',
      trailing: Text('$qtdVerses', style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  Widget _annotationsWidget() {
    return ListTileDrawer(
      onTap: () => Navigator.popAndPushNamed(context, 'annotations_screen'),
      leading: Icons.create_rounded,
      title: 'Anotações',
      trailing: Text('$qtdAnnotations', style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  Widget _searchPassagesWidget() {
    return ListTileDrawer(
       onTap: () => Navigator.popAndPushNamed(context, 'search_screen'),
       leading: Icons.search,
       title: 'Pesquisar passagens'
    );
  }

  Widget _toggleModeWidget() {
    return ListTile(
       onTap: () => themeProvider.toggleTheme(),
       leading: themeProvider.isOn
         ? const Icon(Icons.light_mode_sharp)
         : const Icon(Icons.dark_mode_sharp),
       titleTextStyle: Theme.of(context).textTheme.bodyMedium,
       title: const Text('Trocar modo do app', style: TextStyle(fontSize: 14))
    );
  }

  Widget _devocionaisWidget() {
    final today = DateTime.now();
    bool removeBadge = today.year >= 2025 && today.month > 6;
    return ListTileDrawer(
      onTap: () => Navigator.pushNamed(context, 'devocionais_screen'),
      leading: Icons.menu_book_rounded,
      title: 'Devocionais',
      trailing: removeBadge ? const SizedBox() : Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
            color: Theme.of(context).colorScheme.primary
        ),
        child: const Text('NOVO', style: TextStyle(fontSize: 8, color: Colors.white),),
      ),
    );
  }

  Widget _settingsWidget() {
    return Padding(
      padding: (Platform.isIOS) ? const EdgeInsets.only(bottom: 24.0) : EdgeInsets.zero,
      child: ListTileDrawer(
        onTap: () => Navigator.pushNamed(context, 'settings'),
        leading: Icons.settings,
        title: 'Configurações'
      ),
    );
  }
}

class ListTileDrawer extends StatelessWidget {
  final Function onTap;
  final IconData leading;
  final String title;
  final Widget? trailing;
  const ListTileDrawer({super.key, required this.onTap, required this.leading, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (() => onTap()),
      leading: Icon(
        leading,
      ),
      titleTextStyle: Theme.of(context).textTheme.bodyMedium,
      title: Text(title, style: const TextStyle(fontSize: 14),),
      trailing: trailing,
    );
  }
}


class _PortraitDrawer extends StatelessWidget {
  final Widget readingProgressWidget;
  final Widget aiWidget;
  final Widget savedVersesWidget;
  final Widget annotationsWidget;
  final Widget searchPassagesWidget;
  final Widget toggleModeWidget;
  final Widget devocionalWidget;
  final Widget settingsWidget;
  const _PortraitDrawer({required this.readingProgressWidget, required this.savedVersesWidget, required this.annotationsWidget, required this.searchPassagesWidget, required this.toggleModeWidget, required this.devocionalWidget, required this.settingsWidget, required this.aiWidget});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).width;
    return Drawer(
      width: screenSize * .85,
      child: (screenSize > 500)
                ? tabletLayout()
                : Column(
        children: [
          readingProgressWidget,
          savedVersesWidget,
          const SizedBox(height: 15),
          annotationsWidget,
          const SizedBox(height: 15),
          aiWidget,
          const SizedBox(height: 15),
          searchPassagesWidget,
          const SizedBox(height: 15),
          toggleModeWidget,
          const SizedBox(height: 15),
          devocionalWidget,
          const Spacer(),
          settingsWidget,
        ],
      ),
    );
  }

  Widget tabletLayout() => Column(
    children: [
      readingProgressWidget,
      Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: SizedBox(
          height: 600,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              savedVersesWidget,
              annotationsWidget,
              aiWidget,
              searchPassagesWidget,
              toggleModeWidget,
              devocionalWidget
            ],
          ),
        ),
      ),
      const Spacer(),
      settingsWidget,
    ],
  );
}

class _LandscapeDrawer extends StatelessWidget {
  final Widget readingProgressWidget;
  final Widget aiWidget;
  final Widget savedVersesWidget;
  final Widget annotationsWidget;
  final Widget searchPassagesWidget;
  final Widget toggleModeWidget;
  final Widget devocionalWidget;
  final Widget settingsWidget;
  const _LandscapeDrawer({required this.readingProgressWidget, required this.savedVersesWidget, required this.annotationsWidget, required this.searchPassagesWidget, required this.toggleModeWidget, required this.devocionalWidget, required this.settingsWidget, required this.aiWidget});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight <= 400 ? constraints.maxHeight * 2 : constraints.maxHeight;
        return Drawer(
          width: constraints.maxWidth *.5,
          child: SingleChildScrollView(
            child: SizedBox(
              height: height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      readingProgressWidget,
                      savedVersesWidget,
                      const SizedBox(height: 15),
                      annotationsWidget,
                      const SizedBox(height: 15),
                      aiWidget,
                      const SizedBox(height: 15),
                      searchPassagesWidget,
                      const SizedBox(height: 15),
                      toggleModeWidget,
                      const SizedBox(height: 15),
                      devocionalWidget,
                    ],
                  ),
                  settingsWidget
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}