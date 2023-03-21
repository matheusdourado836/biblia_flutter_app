import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/intercepted_client.dart';
import 'http_interceptor.dart';

class Webclient {
  static const String url = "https://www.abibliadigital.com.br/api/";
  http.Client client = InterceptedClient.build(
      interceptors: [LogginInterceptor()],
      requestTimeout: const Duration(seconds: 15));
}