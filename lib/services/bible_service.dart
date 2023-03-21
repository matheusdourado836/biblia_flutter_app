import 'dart:convert';
import 'dart:io';
import 'package:biblia_flutter_app/services/webclient.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../models/chapter.dart';

class BibleService {
  static String? token = dotenv.env['API_TOKEN'];
      String url = Webclient.url;
  http.Client client = Webclient().client;

  Future<List<Book>> getAllBooks() async {
    http.Response response = await client.get(Uri.parse('${url}books'),
        headers: {"Authorization": "Bearer $token"});
    if (response.statusCode != 200) {
      throw HttpException(response.body);
    }

    List<Book> list = [];

    List<dynamic> listDynamic = json.decode(response.body);

    for (var newList in listDynamic) {
      list.add(Book.fromMap(newList));
    }

    return list;
  }

  Future<Map<String, dynamic>> getBookDetail(String abbrev) async {
    http.Response response = await client.get(
        Uri.parse('${url}books/$abbrev'),
        headers: {"Authorization": "Bearer $token"});
    if (response.statusCode != 200) {
      throw HttpException(response.body);
    }

    return json.decode(response.body);
  }

  Future<List<Chapter>> getVerses(String abbrev, String chapter, {String version = 'nvi'}) async {
    http.Response response = await client.get(
        Uri.parse('${url}verses/$version/$abbrev/$chapter'),
        headers: {"Authorization": "Bearer $token"});
    if (response.statusCode != 200) {
      throw HttpException(response.body);
    }

    List<Chapter> list = [];

    Map<String, dynamic> decodedJson = json.decode(response.body);
    List<dynamic> listDynamic = decodedJson["verses"];

    for (var newList in listDynamic) {
      list.add(Chapter.fromMap(newList));
    }

    return list;
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

  Future<List<Chapter>> searchByWord(String text) async {
    http.Response response = await client.post(Uri.parse('${url}verses/search'),
        headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"},
        body: json.encode({"version": "nvi", "search": text}
        ));
    if (response.statusCode != 200) {
      throw HttpException(response.statusCode.toString());
    }

    List<Chapter> list = [];
    Map<String, dynamic> decodedJson = json.decode(response.body);
    List<dynamic> listDynamic = decodedJson["verses"];

    for (var newList in listDynamic) {
      list.add(Chapter.fromMap(newList));
    }

    return list;
  }
}
