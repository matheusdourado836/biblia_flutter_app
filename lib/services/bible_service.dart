import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:biblia_flutter_app/helpers/alert_dialog.dart';
import 'package:biblia_flutter_app/services/webclient.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BibleService {
  static String? token = dotenv.env['API_TOKEN'];
  static String? imageToken = dotenv.env['IMAGES_API_TOKEN'];
  static String url = Webclient.url;
  static String imageUrl = Webclient.imageUrl;
  http.Client client = Webclient().client;

  Future<bool> checkInternetConnectivity() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.mobile)||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        return true;
      } else {
        return false;
      }
    } on PlatformException catch (e) {
      return alertDialog(content: e.toString());
    }
  }

  Future<Map<String, dynamic>> getRandomVerse() async {
    http.Response response = await client.get(
        Uri.parse('${url}verses/nvi/random'),
        headers: {"Authorization": "Bearer $token"});
    if (response.statusCode != 200) {
      throw HttpException(response.statusCode.toString());
    }

    return json.decode(response.body);
  }

  Future<String> getRandomImage() async {
    http.Response response = await client.get(
        Uri.parse('${imageUrl}verses/nvi/random'),
        headers: {"Authorization": "$imageToken"});

    if (response.statusCode != 200) {
      throw HttpException(response.statusCode.toString());
    }
    final List<dynamic> photos = jsonDecode(response.body)['photos'];
    final Map<String, dynamic> randomPhoto =
        photos[Random().nextInt(photos.length)];
    final String url = randomPhoto['src']['large2x'];

    return url;
  }

  Future<Map<String, dynamic>> getOnlyImage() async {
    http.Response response = await client.get(
        Uri.parse(imageUrl),
        headers: {"Authorization": "$imageToken"});

    if (response.statusCode != 200) {
      throw HttpException(response.statusCode.toString());
    }
    final List<dynamic> photos = jsonDecode(response.body)['photos'];
    final Map<String, dynamic> randomPhoto =
    photos[Random().nextInt(photos.length)];
    final String url = randomPhoto['src']['large2x'];

    return {"url": url, "bodyBytes": response.bodyBytes};
  }
}
