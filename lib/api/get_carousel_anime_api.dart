import 'dart:convert';
import 'package:aniview_app/models/carouselAnime.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<List<CarouselAnime>> fetchRankingAnime(final String type,final int limit) async {
  
  final String url = "https://api.myanimelist.net/v2/anime/ranking?ranking_type=$type&limit=$limit";
  
  final String? clientId = dotenv.env["API_KEY"];
  
  if (clientId == null || clientId.isEmpty) {
    throw Exception('API_KEY is not set in .env');
  }

  final response = await http.get(
    Uri.parse(url),
    headers: {'X-MAL-CLIENT-ID': clientId},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return CarouselAnime.fromJsonList(data['data']);
  } else {
    throw Exception('Failed to fetch anime data');
  }
}
