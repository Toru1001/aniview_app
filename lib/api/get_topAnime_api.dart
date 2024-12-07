import 'dart:convert';
import 'package:aniview_app/models/anime_model.dart';
import 'package:http/http.dart' as http;

Future<List<Anime>> fetchTopAnime(final String filter,final String type, final int limit) async {
  final String baseUrl = "https://api.jikan.moe/v4"; 
  final String url = "$baseUrl/top/anime?limit=$limit&filter=$filter&type=$type";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return Anime.fromJsonList(jsonData['data']);
    } else {
      throw Exception('Failed to fetch anime data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching anime data: $e');
  }
}
