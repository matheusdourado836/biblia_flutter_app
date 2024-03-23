import 'package:flutter/material.dart';

class VersionProvider extends ChangeNotifier {
  String _version = 'nvi';
  final List<Widget> _versionsList = [];
  final List<String> _options = [
    'NVI (Nova Versão Internacional)',
    'ACF (Almeida Corrigida Fiel)',
    'RA (Revista e Atualizada)',
    'BBE (Bible in Basic English)',
    'KJV (King James Version)',
    'RVR (Versão Espanhola Reina-Valera)',
    'GREGO'
  ];
  String _selectedOption = 'NVI (Nova Versão Internacional)';

  String get selectedOption => _selectedOption;

  List<String> get options => _options;

  String get version => _version;

  List<Widget> get versionsList => _versionsList;

  set changeSelectedOption(String newOption) {
    _selectedOption = newOption;
  }

  List<Widget> setListItem(String versionOption) {
    _versionsList.add(
      Center(
        child: Text(versionOption.toUpperCase(),),),
    );

    return _versionsList;
  }

  void changeOptionBd(String newOptionBd) {
    _selectedOption = newOptionBd.trim();
    _version = newOptionBd.split(' ')[0].toLowerCase();
    notifyListeners();
  }

  void changeVersion(String newVersion) {
    _selectedOption = newVersion;
    _version = newVersion.split(' ')[0];
    notifyListeners();
  }
}