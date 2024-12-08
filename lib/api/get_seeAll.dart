import 'dart:convert';
import 'package:aniview_app/models/anime_model.dart';
import 'package:http/http.dart' as http;

Future<List<Anime>> fetchSeeAll(final String filter,final String type) async {
  final String baseUrl = "https://api.jikan.moe/v4";
  final String url = "$baseUrl/top/anime?filter=$filter&type=$type";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      print('Raw JSON Data: ${jsonEncode(jsonData)}');
      return Anime.fromJsonList(jsonData['data']);
    } else {
      throw Exception('Failed to fetch anime data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching anime data: $e');
  }
}
