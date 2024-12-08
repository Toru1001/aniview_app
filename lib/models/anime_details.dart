class AnimeDetailsModel {
  final String id;
  final String title;
  final String img;
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
    required this.img,
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

    return AnimeDetailsModel(
      id: json['mal_id'].toString(),
      title: json['title'] ?? 'No title available',
      img: json['trailer']['images']['maximum_image_url'] ?? '',
      alternative_img: json['images']['jpg']['large_image_url'],
      titles: combinedTitles,
      genres: combinedGenres,
      type: json['type'] ?? 'No type available',
      episodes: json['episodes']?.toString() ?? 'N/A',
      status: json['status'] ?? 'No status available',
      aired: json['aired']?['string']?.toString() ?? 'No airing information available',
      synopsis: json['synopsis'] ?? 'No synopsis available',
      studio: json['studios'][0]['name'] ?? 'N/A',
    );
  }
}
