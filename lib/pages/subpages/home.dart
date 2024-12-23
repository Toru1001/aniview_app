import 'dart:async';

import 'package:aniview_app/api/get_currentSeason_api.dart';
import 'package:aniview_app/models/anime_model.dart';
import 'package:aniview_app/pages/subpages/anime_details.dart';
import 'package:aniview_app/pages/subpages/see_allAnime.dart';
import 'package:aniview_app/widgets/anime_lists.dart';
import 'package:aniview_app/widgets/review_feeds.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:aniview_app/api/get_topAnime_api.dart';

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
  int _requestCount = 0;
  Timer? _timer;
  String _activeTab = "Anime";
  Widget _currentPage = Container();
  bool isLoadingAnime = true;

  @override
  void initState() {
    super.initState();
    _startRequestThrottling();
    fetchAnimeData(6);
    fetchTopAnimeData("", "", 7);
    fetchTopAiringAnimeData("airing", "", 7);
    _startAutoRefresh();
    _currentPage = _animePage();
  }

  Future<void> refreshPage() async {
    setState(() {
      isLoadingAnime = true;
      animeData = [];
    });

    try {
    _startRequestThrottling();
    fetchAnimeData(6);
    fetchTopAnimeData("", "", 7);
    fetchTopAiringAnimeData("airing", "", 7);
    _startAutoRefresh();
    _currentPage = _animePage();
      setState(() {
        hasError = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoadingAnime = false;
      });
    }
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRequestThrottling() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _requestCount = 0;
    });
  }

  void _startAutoRefresh() {
    int elapsedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (elapsedSeconds == 5) {
        timer.cancel();
      } else {
        _executeRequests(elapsedSeconds);
        elapsedSeconds++;
      }
    });
  }

  Future<void> _executeRequests(int time) async {
    if (time <= 3) {
      _currentPage = _animePage();
    }
    List<Function> requests = [
      () => fetchTopMoviesAnimeData("", "movie", 7),
      () => fetchTopMoviesAnimeData("", "movie", 7),
      () => fetchTopOVAAnimeData("", "ova", 7),
      () => fetchTopOVAAnimeData("", "ova", 7),
      () => fetchTopFAVAnimeData("favorite", "", 7),
      () => fetchTopFAVAnimeData("favorite", "", 7),
    ];

    for (int i = 0; i < requests.length; i++) {
      if (_requestCount < 3) {
        _requestCount++;
        requests[i]();
        if (i < requests.length - 1) {
          await Future.delayed(const Duration(milliseconds: 333));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201F31),
      body: RefreshIndicator(
        onRefresh: refreshPage,
        child: Container(
          color: const Color(0xFF201F31),
          height: double.infinity,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Column(
              children: [
                _tabButtons(),
                const SizedBox(height: 20),
                Expanded(
                  child: _currentPage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabButtons() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 21, 21, 33),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10))),
              child: _tabButton("Anime")),
          Container(
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 21, 21, 33),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              child: _tabButton("Reviews")),
        ],
      ),
    );
  }

  Widget _tabButton(String tab) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = tab;
          _currentPage = tab == "Anime" ? _animePage() : _reviewsPage();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: _activeTab == tab ? Colors.redAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          tab,
          style: TextStyle(
            color: _activeTab == tab ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Column _animeList(final String title, List<Map<String, String>> anime,
      String type, String filter) {
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeeAllAnime(
                      title: title,
                      type: type,
                      filter: filter,
                    ),
                  ),
                );
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

  Widget _carousel() {
    return Center(
      child: Column(
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
              onPageChanged: (index, reason) {
                if (activeIndex != index) {
                  // Only update if index changes
                  setState(() {
                    activeIndex = index;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchAnimeData(final int limit) async {
    try {
      List<Anime> animeList = await fetchcurrentSeasonAnime(limit);
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

  Future<void> fetchTopAnimeData(
      final String filter, final String type, final int limit) async {
    try {
      List<Anime> animeList = await fetchTopAnime(filter, type, limit);
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

  Future<void> fetchTopMoviesAnimeData(
      final String filter, final String type, final int limit) async {
    try {
      List<Anime> animeList = await fetchTopAnime(filter, type, limit);
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

  Future<void> fetchTopOVAAnimeData(
      final String filter, final String type, final int limit) async {
    try {
      List<Anime> animeList = await fetchTopAnime(filter, type, limit);
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

  Future<void> fetchTopFAVAnimeData(
      final String filter, final String type, final int limit) async {
    try {
      List<Anime> animeList = await fetchTopAnime(filter, type, limit);
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

  Future<void> fetchTopAiringAnimeData(
      final String filter, final String type, final int limit) async {
    try {
      List<Anime> animeList = await fetchTopAnime(filter, type, limit);
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

  Widget buildImage(String urlImage, String title, int index, String id) {
    return Container(
      height: 250,
      width: 550,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
      ),
      child: GestureDetector(
        onTap: () {
          print(id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnimeDetailsPage(
                animeId: id.toString(),
              ),
            ),
          );
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
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.expectedTotalBytes != null
                                ? (loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1))
                                : null
                            : null,
                        color: Colors.redAccent,
                      ),
                    );
                  }
                },
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

  Widget _animePage() {
    return ListView(
      children: [
        _carousel(),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Column(
            children: [
              _animeList("Top Anime Series", topAnime, "", ""),
              _animeList("Top Airing", topAiringAnime, "", "airing"),
              _animeList("Movies", topMoviesAnime, "movie", ""),
              _animeList("OVA", topOVAAnime, "ova", ""),
              _animeList("Most Favorites", topFAVAnime, "", "favorite"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewsPage() {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  return ListView(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Anime Feed",
            style: TextStyle(
              fontSize: 24,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent));
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return const Center(
                  child: Text("User data not found."),
                );
              }

              final userData = userSnapshot.data!.data() as Map<String, dynamic>?;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('friends')
                    .where('isFriend', isEqualTo: true)
                    .snapshots(),
                builder: (context, friendsSnapshot) {
                  if (friendsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.redAccent));
                  }

                  if (!friendsSnapshot.hasData || friendsSnapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No friends found."),
                    );
                  }

                  final friendIds = friendsSnapshot.data!.docs
                      .map((doc) => doc['friendId'] as String)
                      .toList();
                  friendIds.add(userId!);

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reviews')
                        .where('userId', whereIn: friendIds)
                        .orderBy('date', descending: true)
                        .snapshots(),
                    builder: (context, reviewsSnapshot) {
                      if (reviewsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(color: Colors.redAccent));
                      }

                      if (!reviewsSnapshot.hasData || reviewsSnapshot.data!.docs.isEmpty) {
                        return Container(
                          height: 100,
                          width: double.infinity,
                          child: const Center(
                            child: Text(
                              "No reviews yet.",
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      final reviews = reviewsSnapshot.data!.docs;

                      return Column(
                        children: reviews.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final rawDate = data['date'];
                          String formattedDate;

                          try {
                            if (rawDate is Timestamp) {
                              formattedDate = DateFormat('MM/dd/yyyy hh:mm a')
                                  .format(rawDate.toDate());
                            } else if (rawDate is String) {
                              final parsedDate = DateTime.tryParse(rawDate);
                              if (parsedDate != null) {
                                formattedDate = DateFormat('MM/dd/yyyy hh:mm a')
                                    .format(parsedDate);
                              } else {
                                formattedDate = 'Invalid Date';
                              }
                            } else {
                              formattedDate = 'Unknown Date';
                            }
                          } catch (e) {
                            formattedDate = 'Error Formatting Date';
                          }

                          String reviewId = doc.id;

                          return ReviewCard(
                            reviewId: reviewId,
                            userid: data['userId'] ?? 'Unknown User',
                            rating: data['rating'].toString() ?? '',
                            animeTitle: data['title'] ?? 'Unknown Anime',
                            reviewText: data['review'] ?? '',
                            date: formattedDate,
                            imageUrl: data['imgUrl'] ?? 'https://via.placeholder.com/150',
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    ],
  );
}

}
