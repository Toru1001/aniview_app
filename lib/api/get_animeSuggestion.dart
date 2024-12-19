import 'dart:convert';
import 'package:aniview_app/models/anime_model.dart';
import 'package:http/http.dart' as http;

Future<List<Anime>> fetchSuggestion(final String id) async {
  final String baseUrl = "https://api.jikan.moe/v4";
  final String url = "$baseUrl/anime/$id/recommendations";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      List<dynamic> entries = jsonData['data']; 

      List<dynamic> limitedEntries = entries.take(20).toList();
      return limitedEntries.map((entry) => Anime.fromJson(entry['entry'])).toList();
    } else {
      throw Exception('Failed to fetch anime data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching anime data: $e');
  }
}
