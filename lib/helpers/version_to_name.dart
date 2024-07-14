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