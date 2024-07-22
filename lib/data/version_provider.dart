import 'dart:io';
import 'package:biblia_flutter_app/data/bible_data.dart';
import 'package:biblia_flutter_app/services/bible_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VersionProvider extends ChangeNotifier {
  final BibleData _data = BibleData();
  final List<Widget> _versionsList = [];
  final List<String> _options = [
    'NVI (Nova Versão Internacional)',
    'ACF (Almeida Corrigida Fiel)',
    'NTLH (Nova Tradução na Linguagem de Hoje)',
    'RA (Revista e Atualizada)',
    'KJV (King James Version)',
    'BBE (Bible in Basic English)',
    'RVR (Espanhol)',
    'APEE (Francês)',
    'GREGO'
  ];

  String _selectedOption = 'NVI (Nova Versão Internacional)';

  String get selectedOption => _selectedOption;

  List<String> get options => _options;

  List<Widget> get versionsList => _versionsList;

  double _downloadProgress = 0.0;

  double get downloadProgress => _downloadProgress;

  bool _downloadCompleted = false;

  bool get downloadCompleted => _downloadCompleted;

  String downloadError = '';

  set changeSelectedOption(String newOption) {
    _selectedOption = newOption;
  }

  set setDownloadProgress(bool newValue) {
    _downloadCompleted = newValue;
  }

  void getPreferredVersion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedOption = prefs.getString('version') ?? _selectedOption;
  }

  List<Widget> setListItem(String versionOption) {
    _versionsList.add(
      Center(
        child: Text(versionOption.toUpperCase().replaceAll(' ', '\n'),),),
    );

    return _versionsList;
  }

  void changeOptionBd(String newOptionBd) {
    _selectedOption = newOptionBd.trim();
    notifyListeners();
  }

  void changeVersion(String newVersion) {
    _selectedOption = newVersion;
    notifyListeners();
  }

  bool getDownloadedVersion(String version) {
    return !_data.downloadedVersions.contains(version);
  }

  Future<String> getVersionsDirectoryPath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String versionsDirPath = '${appDocDir.path}/versions';

    final versionsDir = Directory(versionsDirPath);
    if (!await versionsDir.exists()) {
      await versionsDir.create(recursive: true);
    }

    return versionsDirPath;
  }

  Future<void> loadBibleData() async {
    return await BibleData().loadBibleData(['nvi', 'acf', 'ntlh', 'aa', 'en_kjv']);
  }

  void downloadVersion({required String versionName}) async {
    try {
      _downloadProgress = 0;
      downloadError = '';
      _downloadCompleted = false;
      await BibleService().checkInternetConnectivity().then((res) async {
        if(res) {
          notifyListeners();
          Dio dio = Dio();
          String appDocDirPath = await getVersionsDirectoryPath();
          final storage = FirebaseStorage.instance;
          storage.setMaxDownloadRetryTime(const Duration(seconds: 10));
          final ref = storage.ref().child('bible_versions/$versionName.json');
          final downloadUrl = await ref.getDownloadURL().catchError((err) {
            print('OLHA O ERRO AEEEE $err');
          });
          final Response response = await dio.download(
              downloadUrl,
              '$appDocDirPath/$versionName.json',
              onReceiveProgress: (received, total) {
                if (total != -1) {
                  _downloadProgress = (received / total) * 100;
                  notifyListeners();
                }
              });

          if (response.statusCode == 200) {
            _downloadCompleted = true;
            await loadBibleData();
            _downloadProgress = 0;
            downloadError = '';
            notifyListeners();
          } else {
            downloadError = 'Erro ao baixar a versão: ${response.statusCode}';
            notifyListeners();
          }
        }else {
          downloadError = 'Você parece não estar conectado à internet. Verifique sua conexão e tente novamente.';
          notifyListeners();
        }
      });
    }catch (e) {
      downloadError = 'Erro ao baixar versão: ${e.toString()}';
      notifyListeners();
    }
  }
}