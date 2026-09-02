import 'package:biblia_flutter_app/helpers/version_to_name.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('versionToName', () {
    test('mapeia os rótulos do seletor para o nome do arquivo', () {
      expect(versionToName('NVI (Nova Versão Internacional)'), 'nvi');
      expect(versionToName('ACF (Almeida Corrigida Fiel)'), 'acf');
      expect(versionToName('RA (Revista e Atualizada)'), 'aa');
      expect(versionToName('KJV (King James Version)'), 'en_kjv');
      expect(versionToName('BBE (Bible in Basic English)'), 'en_bbe');
      expect(versionToName('RVR (Espanhol)'), 'es_rvr');
      expect(versionToName('APEE (Francês)'), 'fr');
      expect(versionToName('GREGO'), 'el_greek');
    });

    test('é insensível a maiúsculas e ignora o texto após o primeiro espaço', () {
      expect(versionToName('nvi'), 'nvi');
      expect(versionToName('KJV'), 'en_kjv');
    });

    test('faz o caminho de volta sem perder informação', () {
      for (final label in ['nvi', 'acf', 'ntlh', 'aa', 'en_kjv', 'en_bbe', 'es_rvr', 'fr', 'el_greek']) {
        expect(versionToName(nameToVersion(label)), label,
            reason: 'ida e volta deveria ser estável para $label');
      }
    });
  });
}
