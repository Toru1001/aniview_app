class Anime {
  String id;
  String title;
  String img;

  Anime({
    required this.id,
    required this.title,
    required this.img,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['mal_id'].toString(),
      title: json['title'],
      img: json['images']['jpg']['large_image_url'],
    );
  }

  static List<Anime> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Anime.fromJson(json)).toList();
  }
}
