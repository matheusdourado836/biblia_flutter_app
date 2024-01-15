import 'package:biblia_flutter_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/theme_provider.dart';
import '../../../data/verses_provider.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({Key? key}) : super(key: key);

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  final versesProvider = Provider.of<VersesProvider>(navigatorKey!.currentContext!, listen: false);
  int readBooks = 0;

  _formatValue(double value) {
    value = value * 100;
    var formatedLevel = value.toStringAsFixed(2);

    return double.parse(formatedLevel);
  }

  @override
  Widget build(BuildContext context) {
    final screenMode = MediaQuery.of(context).orientation;
    return Consumer<VersesProvider>(
      builder: (context, value, _) {
        readBooks = versesProvider.listMap.where((element) => element['finishedReading'] == 1).length;
        return (screenMode == Orientation.landscape)
            ? _LandscapeDrawer(
            readingProgressWidget: _readingProgressWidget(context, readBooks),
            savedVersesWidget: _savedVersesWidget(context, versesProvider.qtdVerses),
            annotationsWidget: _annotationsWidget(context, versesProvider.qtdAnnotations),
            searchPassagesWidget: _searchPassagesWidget(context),
            toggleModeWidget: _toggleModeWidget(context),
            settingsWidget: _settingsWidget(context),
        )
            : _PortraitDrawer(
            readingProgressWidget:_readingProgressWidget(context, readBooks),
            savedVersesWidget: _savedVersesWidget(context, versesProvider.qtdVerses),
            annotationsWidget: _annotationsWidget(context, versesProvider.qtdAnnotations),
            searchPassagesWidget: _searchPassagesWidget(context),
            toggleModeWidget: _toggleModeWidget(context),
            settingsWidget: _settingsWidget(context),
        );
      },
    );
  }

  Widget _readingProgressWidget(BuildContext context, int readBooks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          boxShadow: kElevationToShadow[3],
          borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10)),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 30,
              right: 0,
              child: IconButton(
                  iconSize: 28,
                  tooltip: 'Reportar um bug',
                  onPressed: (() {Navigator.pushNamed(context, 'email_screen');}),
                  icon: const Icon(Icons.bug_report),
                ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 16.0, 0.0, 12.0),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: CircularProgressIndicator(
                          strokeWidth: 8.0,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          color: Theme.of(context).colorScheme.onSurface,
                          value: readBooks / 66,
                        ),
                      ),
                      Text(
                        '    Progresso: ${_formatValue(readBooks / 66)}%',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 0.0, 12.0),
                  child: Text(
                    'Livros Lidos:\n$readBooks / 66',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _savedVersesWidget(BuildContext context, int qtdVerses) {
    return ListTileDrawer(
      onTap: (() {Navigator.pushNamed(context, 'saved_verses');}),
      leading: Icons.bookmark,
      title: 'Versículos Salvos',
      trailing: Text('$qtdVerses', style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  Widget _annotationsWidget(BuildContext context, qtdAnnotations) {
    return ListTileDrawer(
      onTap: (() {Navigator.pushNamed(context, 'annotations_screen');}),
      leading: Icons.create_rounded,
      title: 'Anotações',
      trailing: Text('$qtdAnnotations', style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  Widget _searchPassagesWidget(BuildContext context) {
    return ListTileDrawer(
       onTap: (() {Navigator.popAndPushNamed(context, 'search_screen');}),
       leading: Icons.search,
       title: 'Pesquisar passagens'
    );
  }

  Widget _toggleModeWidget(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.getThemeMode();
    return ListTile(
       onTap: (() => themeProvider.toggleTheme()),
       leading: Consumer<ThemeProvider>(
         builder: (context, themeValue, _) {
           return (themeValue.isOn)
               ? const Icon(
             Icons.light_mode_sharp,
           )
               : const Icon(
             Icons.dark_mode_sharp,
           );
         },
       ),
       titleTextStyle: Theme.of(context).textTheme.bodyMedium,
       title: const Text('Trocar modo do app')
    );
  }

  Widget _settingsWidget(BuildContext context) {
    return ListTileDrawer(
      onTap: (() {Navigator.pushNamed(context, 'settings');}),
      leading: Icons.settings,
      title: 'Configurações'
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
      title: Text(title),
      trailing: trailing,
    );
  }
}


class _PortraitDrawer extends StatelessWidget {
  final Widget readingProgressWidget;
  final Widget savedVersesWidget;
  final Widget annotationsWidget;
  final Widget searchPassagesWidget;
  final Widget toggleModeWidget;
  final Widget settingsWidget;
  const _PortraitDrawer({Key? key, required this.readingProgressWidget, required this.savedVersesWidget, required this.annotationsWidget, required this.searchPassagesWidget, required this.toggleModeWidget, required this.settingsWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      child: Column(
        children: [
          readingProgressWidget,
          savedVersesWidget,
          annotationsWidget,
          searchPassagesWidget,
          toggleModeWidget,
          const Spacer(),
          settingsWidget,
        ],
      ),
    );
  }
}

class _LandscapeDrawer extends StatelessWidget {
  final Widget readingProgressWidget;
  final Widget savedVersesWidget;
  final Widget annotationsWidget;
  final Widget searchPassagesWidget;
  final Widget toggleModeWidget;
  final Widget settingsWidget;
  const _LandscapeDrawer({Key? key, required this.readingProgressWidget, required this.savedVersesWidget, required this.annotationsWidget, required this.searchPassagesWidget, required this.toggleModeWidget, required this.settingsWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width *.5,
        height: MediaQuery.of(context).size.height * 1.5,
        child: Drawer(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          child: Column(
            children: [
              readingProgressWidget,
              savedVersesWidget,
              annotationsWidget,
              searchPassagesWidget,
              toggleModeWidget,
              const Spacer(),
              settingsWidget
            ],
          ),
        ),
      ),
    );
  }
}


