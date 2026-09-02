import 'package:http/http.dart' as http;

class Webclient {
  static const String imageUrl = "https://api.pexels.com/v1/search?query=nature&per_page=10";
  static const String url = "https://www.abibliadigital.com.br/api/";
  http.Client client = http.Client();
}