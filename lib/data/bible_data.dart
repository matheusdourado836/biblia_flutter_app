import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class BibleData {
  List<Map<String, dynamic>> _data = [];

  List<Map<String, dynamic>> get data => _data;

  final List<String> _downloadedVersions = ['nvi', 'acf', 'en_kjv', 'ntlh', 'aa'];

  List<String> get downloadedVersions => _downloadedVersions;

  static final BibleData _singleton = BibleData._internal();

  factory BibleData() {
    return _singleton;
  }

  BibleData._internal() {
    loadBibleData(['nvi', 'acf', 'ntlh', 'aa', 'en_kjv']);
  }

  Future<void> loadBibleData(List<String> versions) async {
    final List<Map<String, dynamic>> data = [];
    for (final version in versions) {
      final String response = await rootBundle.loadString('assets/json/$version.json');
      data.add({"version": version, "text": json.decode(response)});
    }
    if(Platform.isAndroid) {
      final list = await getDownloadedVersions();
      for(var version in list) {
        data.add(version);
      }
    }else {
      final list = await listDownloadedFilesIOS();
      for(var version in list) {
        data.add(version);
      }
    }

    _data = data;
  }

  Future<List<dynamic>> getDownloadedVersions() async {
    final externalStorageDirectory = await getExternalStorageDirectory();
    if (externalStorageDirectory != null) {
      final specificDirectoryPath = '${externalStorageDirectory.path}/data/user/0/com.bibleWise.biblia_flutter_app/files';
      final specificDirectory = Directory(specificDirectoryPath);
      if (await specificDirectory.exists()) {
        final List<dynamic> downloadedVersions = specificDirectory.listSync();
        final pathList = [];
        for (File file in downloadedVersions) {
          pathList.add(file.path);
        }
        return await loadFromBd(pathList);
      } else {
        print('Diretório não encontrado: $specificDirectoryPath');
        return [];
      }
    } else {
      print('Falha ao obter o diretório de armazenamento externo.');
      return [];
    }
  }

  Future<List<dynamic>> listDownloadedFilesIOS() async {
  String versionsDirPath = await getVersionsDirectoryPath();

  List<dynamic> files = Directory(versionsDirPath).listSync();
  final pathList = [];
  for(File file in files) {
    pathList.add(file.path);
  }

  return await loadFromBd(pathList);
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


  Future<List<dynamic>> loadFromBd(List<dynamic> paths) async {
    List<dynamic> data = [];
    for(var path in paths) {
      final file = File(path);
      if (await file.exists()) {
        _downloadedVersions.add(file.path.split('/').last.split('.')[0]);
        final contents = await file.readAsString();
        data.add({"version": file.path.split('/').last.split('.')[0], "text": json.decode(contents)});
        await addVersionToList(path);
      } else {
        print('Arquivo não encontrado: $path');
      }
    }
    return data;
  }

  Future<void> addVersionToList(String path) async {
    final file = File(path);
    if (await file.exists()) {
      final fileName = file.path.split('/').last.split('.')[0];
      final contents = await file.readAsString();
      _data.add({"version": fileName, "text": json.decode(contents)});
      _downloadedVersions.add(fileName);
    } else {
      print('Arquivo não encontrado: $path');
    }
  }
}