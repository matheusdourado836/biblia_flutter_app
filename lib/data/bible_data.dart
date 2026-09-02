import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

// Nota: decodificar em `compute` foi testado e piorou o cenario — o resultado
// e um grafo de ~1M de objetos que precisa ser copiado de volta para a isolate
// principal, e o boot travava. O ganho real de startup e de memoria vem de
// carregar apenas as versoes necessarias (ver `initialize`), nao de mover o
// json.decode de isolate.

class BibleData {
  /// Versoes embarcadas no bundle do app.
  static const List<String> assetVersions = ['nvi', 'acf', 'ntlh', 'aa', 'en_kjv'];

  /// Versao de referencia: `data[0]` e usada em todo o app como fonte dos
  /// nomes de livros, abreviacoes e quantidade de capitulos.
  static const String defaultVersion = 'nvi';

  final List<Map<String, dynamic>> _data = [];

  /// Versoes disponiveis para uso (embarcadas + baixadas), independente de
  /// ja estarem decodificadas em memoria.
  final List<String> _downloadedVersions = [...assetVersions];

  /// Metadados (nome e tamanho) das versoes baixadas pelo usuario.
  final List<Map<String, dynamic>> _downloadedFiles = [];

  /// Evita decodificar a mesma versao duas vezes em chamadas concorrentes.
  final Map<String, Future<void>> _pendingLoads = {};

  List<Map<String, dynamic>> get data => _data;

  List<String> get downloadedVersions => _downloadedVersions;

  List<Map<String, dynamic>> get downloadedFiles => _downloadedFiles;

  static final BibleData _singleton = BibleData._internal();

  factory BibleData() => _singleton;

  BibleData._internal();

  bool isLoaded(String version) => _data.any((e) => e["version"] == version);

  /// Carrega apenas o necessario para o app abrir: a versao de referencia e,
  /// quando diferente, a versao preferida do usuario. As demais entram sob
  /// demanda por [ensureVersionLoaded].
  Future<void> initialize({String? preferredVersion}) async {
    await ensureVersionLoaded(defaultVersion);
    await refreshDownloadedFiles();
    if (preferredVersion != null && preferredVersion != defaultVersion) {
      await ensureVersionLoaded(preferredVersion);
    }
  }

  Future<void> ensureVersionLoaded(String version) {
    if (isLoaded(version)) return Future.value();

    final pending = _pendingLoads[version];
    if (pending != null) return pending;

    // O corpo precisa ser um bloco: `=> _pendingLoads.remove(version)` devolve
    // o Future removido (que é este mesmo), e o whenComplete passa a esperar
    // por ele — travando a carga para sempre.
    final future = _load(version).whenComplete(() {
      _pendingLoads.remove(version);
    });
    _pendingLoads[version] = future;

    return future;
  }

  Future<void> ensureVersionsLoaded(List<String> versions) async {
    for (final version in versions) {
      await ensureVersionLoaded(version);
    }
  }

  Future<void> _load(String version) async {
    try {
      if (assetVersions.contains(version)) {
        // cache: false — sem isso o bundle mantem a string bruta em memoria
        // para sempre, dobrando o custo de cada versao.
        final raw = await rootBundle.loadString('assets/json/$version.json', cache: false);
        final decoded = json.decode(raw);
        if (!isLoaded(version)) {
          _data.add({"version": version, "text": decoded});
        }
        return;
      }

      final file = File('${await getVersionsDirectoryPath()}/$version.json');
      if (!file.existsSync()) return;

      final raw = await file.readAsString();
      final decoded = json.decode(raw);
      final sizeMb = (await file.length() / (1024 * 1024)).toStringAsFixed(2);
      if (!isLoaded(version)) {
        _data.add({"version": version, "text": decoded, "size": sizeMb});
      }
    } catch (e, stack) {
      debugPrint('Falha ao carregar a versao $version: $e\n$stack');
    }
  }

  /// Compatibilidade com o fluxo antigo: garante que as versoes informadas
  /// estejam em memoria e reatualiza a lista de arquivos baixados.
  Future<void> loadBibleData(List<String> versions) async {
    await ensureVersionLoaded(defaultVersion);
    await refreshDownloadedFiles();
    await ensureVersionsLoaded(versions.where((v) => v != defaultVersion).toList());
  }

  /// Le apenas nome e tamanho dos arquivos baixados, sem decodificar.
  Future<void> refreshDownloadedFiles() async {
    try {
      final dirPath = await getVersionsDirectoryPath();
      final files = Directory(dirPath).listSync().whereType<File>();

      _downloadedFiles.clear();
      for (final file in files) {
        final name = file.path.split('/').last.split('.').first;
        if (name.isEmpty) continue;
        final sizeMb = (file.lengthSync() / (1024 * 1024)).toStringAsFixed(2);
        _downloadedFiles.add({"version": name, "size": sizeMb});
        if (!_downloadedVersions.contains(name)) {
          _downloadedVersions.add(name);
        }
      }
    } catch (e) {
      debugPrint('Falha ao listar versoes baixadas: $e');
    }
  }

  Future<void> deleteVersions({required List<String> versions}) async {
    final versionsDirPath = await getVersionsDirectoryPath();
    final files = Directory(versionsDirPath).listSync().whereType<File>();

    for (final file in files) {
      final name = file.path.split('/').last.split('.').first;
      if (versions.contains(name)) {
        await file.delete();
        _data.removeWhere((element) => element["version"] == name);
        _downloadedVersions.removeWhere((e) => e == name);
        _downloadedFiles.removeWhere((e) => e["version"] == name);
      }
    }
  }

  Future<String> getVersionsDirectoryPath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String versionsDirPath = '${appDocDir.path}/versions';

    final versionsDir = Directory(versionsDirPath);
    if (!versionsDir.existsSync()) {
      await versionsDir.create(recursive: true);
    }

    return versionsDirPath;
  }
}
