class CarouselAnime {
  int id;
  String title;
  String img;

  CarouselAnime({
    required this.id,
    required this.title,
    required this.img
  });

  factory CarouselAnime.fromJson(Map<String, dynamic> json){
    return CarouselAnime(
      id: json['node']['id'], 
      title: json['node']['title'], 
      img: json['node']['main_picture']['medium'],);
  }

  static List<CarouselAnime> fromJsonList(List<dynamic> jsonList){
    return jsonList.map((json) => CarouselAnime.fromJson(json)).toList();
  }
}