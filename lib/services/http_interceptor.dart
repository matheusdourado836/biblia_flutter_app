import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';

class LogginInterceptor implements InterceptorContract {
  Logger logger = Logger();

  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    // logger.i(
    //     'Request de ${data.baseUrl}\nCabeçalho ${data.headers}\nBody ${data.body}');
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required data}) async {
    // logger.i(
    //     'Resposta de ${data.url}\nCabeçalho ${data.headers}\nBody ${data.body}');
    return data;
  }
}