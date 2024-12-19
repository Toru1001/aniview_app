import 'dart:convert';
import 'package:aniview_app/models/anime_model.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchSearch(final String searchText, {int page = 1}) async {
  final String baseUrl = "https://api.jikan.moe/v4";
  final String url = "$baseUrl/anime?q=$searchText&page=$page&sfw=true";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      
      final List<Anime> animeList = Anime.fromJsonList(jsonData['data']);
      final bool hasNextPage = jsonData['pagination']['has_next_page'] ?? false;

      return {
        'data': animeList,
        'hasNextPage': hasNextPage,
      };
    } else {
      throw Exception('Failed to fetch anime data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching anime data: $e');
  }
}
