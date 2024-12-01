import 'package:aniview_app/widgets/anime_lists.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:aniview_app/api/get_carousel_anime_api.dart';
import 'package:aniview_app/models/carouselAnime.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int activeIndex = 0;
  final _controller = CarouselSliderController();
  List<Map<String, String>> animeData = [];
  List<Map<String, String>> topAnime = [];
  List<Map<String, String>> topAiringAnime = [];
  List<Map<String, String>> topFAVAnime = [];
  List<Map<String, String>> topOVAAnime = [];
  List<Map<String, String>> topMoviesAnime = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchAnimeData("airing", 6);
    fetchTopAnimeData("all", 10);
    fetchTopAiringAnimeData("airing", 10);
    fetchTopFAVAnimeData("favorite", 10);
    fetchTopOVAAnimeData("ova", 10);
    fetchTopMoviesAnimeData("movie", 10);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF201F31),
      height: double.infinity,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: ListView(
          children: [
            _carousel(),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Column(
                children: [
                  _animeList("Top Anime Series", topAnime, "all"),
                  _animeList("Top Airing", topAiringAnime, "airing"),
                  _animeList("Movies", topMoviesAnime, "movie"),
                  _animeList("OVA", topOVAAnime, "ova"),
                  _animeList("Most Favorites", topFAVAnime, "favorite"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Column _animeList(final String title, List<Map<String, String>> anime, String type) {
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "$title",
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector.new(
                      onTap: (){

                      },
                      child: const Text(
                        "See All >>",
                        style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.none,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AnimeListWidget(animeList: anime),
                const SizedBox(height: 10),
              ],
            );
  }

  Center _carousel() {
    return Center(
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.redAccent)
          : hasError
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.redAccent, size: 50),
                    SizedBox(height: 8),
                    Text(
                      "Failed to load anime data",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CarouselSlider.builder(
                      carouselController: _controller,
                      itemCount: animeData.length,
                      itemBuilder: (context, index, realIndex) {
                        final id = animeData[index]['id'].toString();
                        final urlImage = animeData[index]['img'].toString();
                        final title = animeData[index]['title'].toString();
                        return buildImage(urlImage, title, index, id);
                      },
                      options: CarouselOptions(
                        height: 200,
                        autoPlay: true,
                        enableInfiniteScroll: false,
                        autoPlayAnimationDuration: const Duration(seconds: 2),
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) =>
                            setState(() => activeIndex = index),
                      ),
                    ),
                    const SizedBox(height: 12),
                    buildIndicator(),
                  ],
                ),
    );
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(
        onDotClicked: animateToSlide,
        effect: const ExpandingDotsEffect(
          dotWidth: 15,
          dotHeight: 10,
          activeDotColor: Colors.redAccent,
        ),
        activeIndex: activeIndex,
        count: animeData.length,
      );

  void animateToSlide(int index) => _controller.animateToPage(index);

  Future<void>  fetchAnimeData(final String type, final int limit) async {
    try {
      List<CarouselAnime> animeList = await fetchRankingAnime(type, limit);
      if (animeList.isNotEmpty) {
        setState(() {
          animeData = animeList
              .map((anime) =>
                  {'id': anime.id, 'img': anime.img, 'title': anime.title})
              .toList();
          isLoading = false;
          hasError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Error fetching anime data: $e');
    }
  }

  Future<void>  fetchTopAnimeData(final String type, final int limit) async {
    try {
      List<CarouselAnime> animeList = await fetchRankingAnime(type, limit);
      if (animeList.isNotEmpty) {
        setState(() {
          topAnime = animeList
              .map((anime) =>
                  {'id': anime.id, 'img': anime.img, 'title': anime.title})
              .toList();
          isLoading = false;
          hasError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Error fetching anime data: $e');
    }
  }

  Future<void>  fetchTopMoviesAnimeData(final String type, final int limit) async {
    try {
      List<CarouselAnime> animeList = await fetchRankingAnime(type, limit);
      if (animeList.isNotEmpty) {
        setState(() {
          topMoviesAnime = animeList
              .map((anime) =>
                  {'id': anime.id, 'img': anime.img, 'title': anime.title})
              .toList();
          isLoading = false;
          hasError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Error fetching anime data: $e');
    }
  }

  Future<void>  fetchTopOVAAnimeData(final String type, final int limit) async {
    try {
      List<CarouselAnime> animeList = await fetchRankingAnime(type, limit);
      if (animeList.isNotEmpty) {
        setState(() {
          topOVAAnime = animeList
              .map((anime) =>
                  {'id': anime.id, 'img': anime.img, 'title': anime.title})
              .toList();
          isLoading = false;
          hasError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Error fetching anime data: $e');
    }
  }

  Future<void>  fetchTopFAVAnimeData(final String type, final int limit) async {
    try {
      List<CarouselAnime> animeList = await fetchRankingAnime(type, limit);
      if (animeList.isNotEmpty) {
        setState(() {
          topFAVAnime = animeList
              .map((anime) =>
                  {'id': anime.id, 'img': anime.img, 'title': anime.title})
              .toList();
          isLoading = false;
          hasError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Error fetching anime data: $e');
    }
  }

  Future<void>  fetchTopAiringAnimeData(final String type, final int limit) async {
    try {
      List<CarouselAnime> animeList = await fetchRankingAnime(type, limit);
      if (animeList.isNotEmpty) {
        setState(() {
          topAiringAnime = animeList
              .map((anime) =>
                  {'id': anime.id, 'img': anime.img, 'title': anime.title})
              .toList();
          isLoading = false;
          hasError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Error fetching anime data: $e');
    }
  }

  Widget buildImage(String urlImage, String title, int index, String id) => Container(
        height: 250,
        width: 550,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: GestureDetector(
          onTap: (){
            print(id);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.network(
                  urlImage,
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                  alignment: const Alignment(0, -0.5),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.5),
                        spreadRadius: 10,
                        blurRadius: 20,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 10),
                    child: Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
