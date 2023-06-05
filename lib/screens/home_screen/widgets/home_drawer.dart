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
  final versesProvider =
      Provider.of<VersesProvider>(navigatorKey!.currentContext!, listen: false);
  @override
  Widget build(BuildContext context) {
    final screenMode = MediaQuery.of(context).orientation;
    return Consumer<VersesProvider>(
      builder: (context, value, _) {
        return (screenMode == Orientation.landscape)
            ? _LandscapeDrawer(
            readingProgressWidget: _readingProgressWidget(context),
            savedVersesWidget:     _savedVersesWidget(context, versesProvider.qtdVerses),
            annotationsWidget:     _annotationsWidget(context, versesProvider.qtdAnnotations),
            searchPassagesWidget:  _searchPassagesWidget(context),
            toggleModeWidget:      _toggleModeWidget(context),
            reportErrorWidget:     _reportErrorWidget(context)
        )
            : _PortraitDrawer(
            readingProgressWidget:_readingProgressWidget(context),
            savedVersesWidget:    _savedVersesWidget(context, versesProvider.qtdVerses),
            annotationsWidget:    _annotationsWidget(context, versesProvider.qtdAnnotations),
            searchPassagesWidget: _searchPassagesWidget(context),
            toggleModeWidget:     _toggleModeWidget(context),
            reportErrorWidget:    _reportErrorWidget(context)
        );
      },
    );
  }

  Widget _readingProgressWidget(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        boxShadow: kElevationToShadow[3],
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                SizedBox(
                  height: 80,
                  width: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 8.0,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    color: Theme.of(context).colorScheme.onSurface,
                    value: versesProvider.listMap.length / 66,
                  ),
                ),
                Text(
                  '     Progresso: ${formatValue(versesProvider.listMap.length / 66)}%',
                  style: Theme.of(context).textTheme.bodyLarge,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Livros Lidos:\n${versesProvider.listMap.length}/66',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _savedVersesWidget(BuildContext context, int qtdVerses) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, 'saved_verses');
      },
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          top: 32.0,
          right: 16.0,
          bottom: 16.0,
        ),
        child: Row(
          children: [
            Icon(
              Icons.bookmark,
              color: Theme.of(context).colorScheme.primary,
            ),
            const Text('   Versículos Salvos'),
            const Spacer(),
            Text('$qtdVerses')
          ],
        ),
      ),
    );
  }

  Widget _annotationsWidget(BuildContext context, qtdAnnotations) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, 'annotations_screen');
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.create_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const Text('   Anotações'),
            const Spacer(),
            Text('$qtdAnnotations')
          ],
        ),
      ),
    );
  }

  Widget _searchPassagesWidget(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.popAndPushNamed(context, 'search_screen');
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.primary,
            ),
            const Text('   Pesquisar passagens'),
          ],
        ),
      ),
    );
  }

  Widget _toggleModeWidget(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return InkWell(
      onTap: () {
        themeProvider.toggleTheme();
      },
      child: Consumer<ThemeProvider>(
        builder: (context, themeValue, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                (themeValue.isOn)
                    ? Icon(
                  Icons.light_mode_sharp,
                  color: Theme.of(context).colorScheme.primary,
                )
                    : Icon(
                  Icons.dark_mode_sharp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Text('   Trocar modo do app'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _reportErrorWidget(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, 'email_screen');
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.bug_report,
              color: Theme.of(context).colorScheme.primary,
            ),
            const Text('   Reportar um erro'),
          ],
        ),
      ),
    );
  }

  formatValue(double value) {
    value = value * 100;
    var formatedLevel = value.toStringAsFixed(2);

    return double.parse(formatedLevel);
  }
}

class _PortraitDrawer extends StatelessWidget {
  final Widget readingProgressWidget;
  final Widget savedVersesWidget;
  final Widget annotationsWidget;
  final Widget searchPassagesWidget;
  final Widget toggleModeWidget;
  final Widget reportErrorWidget;
  const _PortraitDrawer({Key? key, required this.readingProgressWidget, required this.savedVersesWidget, required this.annotationsWidget, required this.searchPassagesWidget, required this.toggleModeWidget, required this.reportErrorWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      child: Column(
        children: [
          readingProgressWidget,
          savedVersesWidget,
          annotationsWidget,
          searchPassagesWidget,
          toggleModeWidget,
          const Spacer(),
          reportErrorWidget
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
  final Widget reportErrorWidget;
  const _LandscapeDrawer({Key? key, required this.readingProgressWidget, required this.savedVersesWidget, required this.annotationsWidget, required this.searchPassagesWidget, required this.toggleModeWidget, required this.reportErrorWidget}) : super(key: key);

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
              reportErrorWidget
            ],
          ),
        ),
      ),
    );
  }
}


