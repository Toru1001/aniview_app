class AnimeDetailsModel {
  final String id;
  final String title;
  final String titles;
  final String genres;
  final String type;
  final String episodes;
  final String status;
  final String aired;
  final String synopsis;
  final String alternative_img;
  final String studio;

  AnimeDetailsModel({
    required this.id,
    required this.title,
    required this.titles,
    required this.genres,
    required this.type,
    required this.episodes,
    required this.status,
    required this.aired,
    required this.synopsis,
    required this.alternative_img,
    required this.studio,
  });

  factory AnimeDetailsModel.fromJson(Map<String, dynamic> json) {
    List<String> titleList = [];
    if (json.containsKey('title') && json['title'] != null) {
      titleList.add(json['title']);
    }
    if (json.containsKey('titles') && json['titles'] is List) {
      titleList.addAll(
        (json['titles'] as List)
            .map((item) => item['title']?.toString() ?? '')
            .toList(),
      );
    }
    String combinedTitles = titleList.where((title) => title.isNotEmpty).join(', ');

    List<String> genreList = [];
    if (json.containsKey('genres') && json['genres'] is List) {
      genreList.addAll(
        (json['genres'] as List)
            .map((genre) => genre['name']?.toString() ?? '')
            .toList(),
      );
    }
    String combinedGenres = genreList.where((genre) => genre.isNotEmpty).join(', ');

    String studioName = 'N/A';
    if (json.containsKey('studios') && json['studios'] is List && json['studios'].isNotEmpty) {
      studioName = json['studios'][0]['name'] ?? 'N/A';
    }

    return AnimeDetailsModel(
      id: json['mal_id'].toString(),
      title: json['title'] ?? 'No title available',
      alternative_img: json['images']['jpg']['large_image_url'] ?? '',
      titles: combinedTitles,
      genres: combinedGenres,
      type: json['type'] ?? 'No type available',
      episodes: json['episodes']?.toString() ?? 'N/A',
      status: json['status'] ?? 'No status available',
      aired: json['aired']?['string']?.toString() ?? 'No airing information available',
      synopsis: json['synopsis'] ?? 'No synopsis available',
      studio: studioName,
    );
  }
}
