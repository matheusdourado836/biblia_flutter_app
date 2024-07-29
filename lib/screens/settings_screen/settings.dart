import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:biblia_flutter_app/data/chapters_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/data/version_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/theme_provider.dart';
import '../../helpers/version_to_name.dart';
import '../../helpers/progress_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Configurações'),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: const SingleChildScrollView(
        child: Options(),
      ),
    );
  }
}

class Options extends StatefulWidget {
  const Options({super.key});

  @override
  State<Options> createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  late VersionProvider _versionProvider;
  String _selectedVersion = 'NVI (Nova Versão Internacional)';
  ValueNotifier<double> _sliderValue = ValueNotifier(16.0);
  //double _sliderValue = 16.0;
  double _savedSliderValue = 16.0;

  @override
  void initState() {
    _versionProvider = Provider.of<VersionProvider>(context, listen: false);
    getPreferences();
    getVersion();
    super.initState();
  }

  void getPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _sliderValue.value = prefs.getDouble('fontsize') ?? 16.0;
    });
  }

  void getVersion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => _selectedVersion = prefs.getString('version') ?? _selectedVersion);
  }

  void setNewPreferredVersion(String newValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => _selectedVersion = newValue);
    prefs.setString('version', _selectedVersion);
    _versionProvider.changeSelectedOption = _selectedVersion;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VersesProvider>(
      builder: (context, versesValue, _) {
        versesValue.getFontSize();
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tamanho da fonte:',
                        style: TextStyle(fontSize: 18)),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: InkWell(
                        onTap: (() {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return ValueListenableBuilder(
                                    valueListenable: _sliderValue,
                                    builder: (context, value, _) {
                                      return AlertDialog(
                                        title: Text(
                                            '"E Simão Pedro, respondendo, disse: Tu és o Cristo, o Filho do Deus vivo"',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: _sliderValue.value)),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _sliderValue.value.toStringAsFixed(0),
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                            Slider(
                                                inactiveColor: Theme.of(context).colorScheme.secondary,
                                                value: _sliderValue.value,
                                                min: 8.0,
                                                max: 40.0,
                                                onChanged: (double value) {
                                                  _sliderValue.value = value;
                                                  versesValue.newFontSize(_sliderValue.value, false);
                                                }),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: (() {
                                              versesValue.newFontSize(_sliderValue.value, true);
                                              setState(() {
                                                _savedSliderValue = _sliderValue.value;
                                              });
                                              Navigator.pop(context);
                                            }),
                                            child: const Text('Salvar'),
                                          ),
                                          TextButton(
                                            onPressed: (() {
                                              setState(() {
                                                _sliderValue.value = _savedSliderValue;
                                              });
                                              Navigator.pop(context);
                                            }),
                                            child: const Text('Cancelar'),
                                          ),
                                        ],
                                      );
                                    });
                              });
                        }),
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(14.0)),
                          child: Center(
                            child: Text(
                              versesValue.fontSize.toStringAsFixed(0),
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ordem dos livros:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Expanded(child: OrderByDropDown())
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Versão preferida:',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Expanded(
                    child: Consumer<VersionProvider>(
                      builder: (context, value, _) {
                        return DropdownButton(
                          underline: Container(
                            height: 0,
                            color: Colors.transparent,
                          ),
                          style: Theme.of(context).dropdownMenuTheme.textStyle,
                          isExpanded: true,
                          itemHeight: 100.0,
                          value: _selectedVersion,
                          items: _versionProvider.options.map((option) {
                            _versionProvider.setListItem(option.split(' ')[0]);
                            if(value.getDownloadedVersion(versionToName(option))) {
                              return DropdownMenuItem(
                                value: option,
                                child: InkWell(
                                  onTap: () => showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => ProgressDialog(versionName: versionToName(option), versionNameRaw: option.split(' ')[0])
                                  ).whenComplete(() {
                                    value.loadBibleData().whenComplete(() {
                                      Navigator.pop(context);
                                      setState(() {});
                                    });
                                  }),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 12, color: Theme.of(context).textTheme.titleSmall!.color!.withOpacity(.5)),
                                        ),
                                      ),
                                      const Icon(Icons.download, size: 16,)
                                    ],
                                  ),
                                ),
                              );
                            }
                            return DropdownMenuItem(
                              value: option,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16.0, left: 4, right: 4),
                                child: Center(
                                    child: Text(
                                      option,
                                      style: Theme.of(context).textTheme.titleSmall,
                                    )
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setNewPreferredVersion(newValue!);
                            _versionProvider.changeVersion(newValue.toString());
                          },
                          selectedItemBuilder: (BuildContext context) {
                            return _versionProvider.versionsList;
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Preferência de tema:',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Consumer<ThemeProvider>(
                    builder: (context, themeValue, _) {
                      return SizedBox(
                        width: 150,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AnimatedToggleSwitch<bool>.dual(
                            current: !themeValue.isOn,
                            first: false,
                            second: true,
                            spacing: 50.0,
                            style: const ToggleStyle(
                              borderColor: Colors.transparent,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(0, 1.5),
                                ),
                              ],
                            ),
                            borderWidth: 5.0,
                            height: 45,
                            onChanged: (b) => themeValue.toggleTheme(),
                            styleBuilder: (b) => ToggleStyle(indicatorColor: b ? Theme.of(context).cardTheme.color : Theme.of(context).colorScheme.primary),
                            iconBuilder: (value) => value
                                ? const Icon(Icons.dark_mode)
                                : const Icon(Icons.light_mode_rounded, color: Colors.white,),
                            textBuilder: (value) => value
                                ? const Center(child: Text('Escuro'))
                                : const Center(child: Text('Claro')),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class OrderByDropDown extends StatefulWidget {
  const OrderByDropDown({super.key});

  @override
  State<OrderByDropDown> createState() => _OrderByDropDownState();
}

class _OrderByDropDownState extends State<OrderByDropDown> {
  String _selectedOption = 'Padrão';
  List<Widget> reducedValues = [];

  @override
  void initState() {
    getOrderStyle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final chaptersProvider = Provider.of<ChaptersProvider>(context, listen: false);
    return DropdownButton<String>(
      underline: Container(
        height: 0,
        color: Colors.transparent,
      ),
      itemHeight: 100,
      style: Theme.of(context).dropdownMenuTheme.textStyle,
      isExpanded: true,
      value: _selectedOption,
      onChanged: (String? newValue) {
        setState(() {
          _selectedOption = newValue!;
        });
        chaptersProvider.setOrderStyle(_selectedOption);
      },
      items: <String>[
        'Padrão',
        'Cronológica',
        'Por estilo\n(pentateuco, históricos, proféticos)',
      ].map<DropdownMenuItem<String>>((String value) {
        reducedValues.add(Center(
          child: (value.startsWith('Por'))
              ? Text(value.substring(0, 10))
              : Text(value),
        ));
        return DropdownMenuItem<String>(
          value: value,
          child: Center(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            )
          ),
        );
      }).toList(),
      selectedItemBuilder: (BuildContext context) {
        return reducedValues;
      },
    );
  }

  void getOrderStyle() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getInt('orderStyle') != null) {
      final orderIndex = prefs.getInt('orderStyle');
      switch (orderIndex) {
        case 0:
          {
            _selectedOption = 'Padrão';
            break;
          }
        case 1:
          {
            _selectedOption = 'Cronológica';
            break;
          }
        case 2:
          {
            _selectedOption =
                'Por estilo\n(pentateuco, históricos, proféticos)';
          }
      }

      setState(() {
        _selectedOption;
      });
    }
  }
}
