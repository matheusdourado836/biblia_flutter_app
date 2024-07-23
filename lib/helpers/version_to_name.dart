String versionToName(String version) {
  final formattedVersion = version.toLowerCase().split(' ')[0];
  switch(formattedVersion) {
    case 'bbe':
      return 'en_bbe';
    case 'rvr':
      return 'es_rvr';
    case 'apee':
      return 'fr';
    case 'grego':
      return 'el_greek';
    case 'kjv':
      return 'en_kjv';
    case 'ra':
      return 'aa';
    default:
      return formattedVersion;
  }
}

String nameToVersion(String name) {
  switch(name) {
    case 'el_greek':
      return 'grego';
    case 'en_kjv':
      return 'kjv';
    case 'en_bbe':
      return 'bbe';
    case 'fr':
      return 'apee';
    case 'es_rvr':
      return 'rvr';
    default:
      return name;
  }
}