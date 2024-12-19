import 'dart:convert';
import 'package:aniview_app/models/anime_details.dart';
import 'package:http/http.dart' as http;

Future<AnimeDetailsModel> fetchAnimeDetails(String animeId) async {
  final String baseUrl = "https://api.jikan.moe/v4";
  final String url = "$baseUrl/anime/$animeId/full";

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return AnimeDetailsModel.fromJson(data['data']);
    } else {
      throw Exception('Failed to load anime details');
    }
  } catch (e) {
    print('Error fetching anime data: $e');
    throw e;
  }
}
