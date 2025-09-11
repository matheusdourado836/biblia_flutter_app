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
    //loadBibleData(['nvi', 'acf', 'ntlh', 'aa', 'en_kjv']);
  }

  Future<void> loadBibleData(List<String> versions) async {
    final List<Map<String, dynamic>> data = [];
    for (final version in versions) {
      final String response = await rootBundle.loadString('assets/json/$version.json');
      data.add({"version": version, "text": json.decode(response)});
    }
    final list = await listDownloadedFilesIOS();
    for(var version in list) {
      data.add(version);
    }

    _data = data;
  }

  Future<void> deleteVersions({required List<String> versions}) async {
    String versionsDirPath = await getVersionsDirectoryPath();

    List<dynamic> files = Directory(versionsDirPath).listSync();
    for(File file in files) {
      for(var version in versions) {
        if(file.path.split('/').last.split('.')[0] == version) {
          await file.delete();
          _data.removeWhere((element) => element["version"] == version);
          _downloadedVersions.removeWhere((e) => e == version);
        }
      }
    }
    return;
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
        final fileName = file.path.split('/').last.split('.')[0];
        int fileSize = await file.length();
        final fileSizeMega = (fileSize / (1024 * 1024)).toStringAsFixed(2);
        if(!_downloadedVersions.contains(fileName)) {
          _downloadedVersions.add(fileName);
        }
        final contents = await file.readAsString();
        data.add({"version": file.path.split('/').last.split('.')[0], "text": json.decode(contents), "size": fileSizeMega});
      }
    }
    return data;
  }
}