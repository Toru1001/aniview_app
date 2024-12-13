import 'package:aniview_app/api/get_animeDetails.dart';
import 'package:aniview_app/api/get_animeSuggestion.dart';
import 'package:aniview_app/models/anime_details.dart';
import 'package:aniview_app/models/anime_model.dart';
import 'package:aniview_app/widgets/addReviewModal.dart';
import 'package:aniview_app/widgets/allReviewsModal.dart';
import 'package:aniview_app/widgets/anime_lists.dart';
import 'package:aniview_app/widgets/appBar.dart';
import 'package:aniview_app/widgets/review.dart';
import 'package:flutter/material.dart';

class AnimeDetailsPage extends StatefulWidget {
  final String animeId;

  const AnimeDetailsPage({
    Key? key,
    required this.animeId,
  }) : super(key: key);

  @override
  State<AnimeDetailsPage> createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  @override
  void initState() {
    super.initState();
    fetchAnimeData(widget.animeId);
    fetchAnimeSuggestion();
    print(widget.animeId);
  }

  List<Map<String, String>> animeSuggestion = [];
  List<Map<String, String>> animeData = [];
  bool isLoading = true;
  bool hasError = false;
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201F31),
      appBar: const AniviewAppBar(),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.redAccent)
            : hasError
                ? GestureDetector(
                    onTap: () {
                      fetchAnimeData(widget.animeId);
                    },
                    child: const Text(
                      "An error occurred. Please try again.",
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : animeData.isNotEmpty
                    ? ListView(
                        children: animeData.map((anime) {
                          return Column(
                            children: [
                              _header(anime),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _cards(anime),
                                    _divider(),
                                    _detailsGroup(anime),
                                    _divider(),
                                    _synopsis(anime),
                                    _divider(),
                                    _reviewsSection(anime),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    _suggestedSection()
                                  ],
                                ),
                              )
                            ],
                          );
                        }).toList(),
                      )
                    : const Text(
                        "",
                        style: TextStyle(color: Colors.white),
                      ),
      ),
    );
  }

  Column _suggestedSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Suggested Anime",
          style: TextStyle(
            fontSize: 24,
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        AnimeListWidget(animeList: animeSuggestion)
      ],
    );
  }

  Future<void> fetchAnimeSuggestion() async {
    try {
      List<Anime> animeList = await fetchSuggestion(widget.animeId);
      if (animeList.isNotEmpty) {
        setState(() {
          animeSuggestion = animeList
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

  Column _reviewsSection(Map<String, String> anime) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reviews',
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500),
            ),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Color(0xFF2A2940),
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => AllReviewsModal(
                    genre: anime['genres'] ?? '',
                    id: anime['id'] ?? '',
                    img: anime['alternative'] ?? '',
                    title: anime['title'] ?? '',
                  ),
                );
              },
              child: const Text(
                'See All >>',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w300),
              ),
            )
          ],
        ),
        Container(
          child: const Column(
            children: [
              ReviewWidget(
                username: "User1024",
                dateTime: "12/06/2024",
                rating: 5,
                comment: "I like the series overall <3. Hoping for season 2!",
              ),
              ReviewWidget(
                username: "User1024",
                dateTime: "12/06/2024",
                comment: "I like the series overall <3. Hoping for season 2!",
                isReply: true,
              )
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        _button(anime),
      ],
    );
  }

  Center _button(Map<String, String> anime) {
    return Center(
      child: OutlinedButton(
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            backgroundColor: Color(0xFF2A2940),
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => AddReviewModal(
              genre: anime['genres'] ?? '',
              id: anime['id'] ?? '',
              img: anime['alternative'] ?? '',
              title: anime['title'] ?? '',
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Colors.redAccent,
            width: 2, // Border width
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 24,
          ),
        ),
        child: const Text(
          "Add Review",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Column _synopsis(Map<String, String> anime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Synopsis',
          style: TextStyle(
              fontSize: 20,
              color: Colors.redAccent,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          child: Column(
            children: [
              Text(
                anime['synopsis'] ?? '',
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w300),
                maxLines: isExpanded ? null : 4,
                overflow:
                    isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isExpanded ? 'Read Less' : 'Read More',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Column _detailsGroup(Map<String, String> anime) {
    return Column(
      children: [
        _details('Titles: ', 'titles', anime),
        const SizedBox(
          height: 10,
        ),
        _details('Aired: ', 'aired', anime),
        const SizedBox(
          height: 10,
        ),
        _details('Studio: ', 'studio', anime),
        const SizedBox(
          height: 10,
        ),
        _details('Type: ', 'type', anime),
      ],
    );
  }

  Row _details(
      final String text, final String details, Map<String, String> anime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
              fontSize: 16,
              color: Colors.redAccent,
              fontWeight: FontWeight.w500),
        ),
        Container(
          width: 320,
          child: Text(
            anime[details] ?? '',
            style: const TextStyle(
                fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w400),
            softWrap: true,
          ),
        )
      ],
    );
  }

  Divider _divider() {
    return const Divider(
      thickness: .5,
      color: Colors.grey,
      height: 40,
    );
  }

  Column _cards(Map<String, String> anime) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 330,
                  child: Text(
                    anime['title'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
                Text(
                  anime['genres'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Colors.grey),
                )
              ],
            ),
            GestureDetector(
              child: const Icon(
                Icons.bookmark_add_outlined,
                color: Colors.redAccent,
                size: 35,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                children: [
                  Text(
                    'Rating',
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w400,
                        fontSize: 18),
                  ),
                  Text(
                    '8.4',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 15),
                  )
                ],
              ),
              const SizedBox(
                width: 20,
              ),
              const Text(
                '|',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w200,
                    fontSize: 38),
              ),
              const SizedBox(
                width: 20,
              ),
              Column(
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w400,
                        fontSize: 18),
                  ),
                  Text(
                    anime['status'] ?? '',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
              const SizedBox(
                width: 20,
              ),
              const Text(
                '|',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w200,
                    fontSize: 38),
              ),
              const SizedBox(
                width: 20,
              ),
              Column(
                children: [
                  const Text(
                    'Episodes',
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w400,
                        fontSize: 18),
                  ),
                  Text(
                    anime['episodes'] ?? '',
                    style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 15),
                  )
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Stack _header(Map<String, String> anime) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 299.9,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(anime['alternative'] ?? ''),
              fit: BoxFit.cover,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF201F31),
                offset: Offset(0, 10),
                blurRadius: 15,
              ),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment(0, .9),
                colors: [
                  Colors.transparent,
                  Color(0xFF201F31),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(.5),
              borderRadius: BorderRadius.circular(100),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget verticalDivider() {
    return const VerticalDivider(
      width: 20,
      thickness: 1,
      color: Colors.redAccent,
      indent: 10,
      endIndent: 10,
    );
  }

  Future<void> fetchAnimeData(final String animeId) async {
    try {
      AnimeDetailsModel anime = await fetchAnimeDetails(widget.animeId);
      setState(() {
        animeData = [
          {
            'id': anime.id ?? '',
            'alternative': anime.alternative_img ?? '',
            'title': anime.title ?? '',
            'titles': anime.titles ?? 'No titles available',
            'genres': anime.genres ?? 'No genres available',
            'type': anime.type ?? 'N/A',
            'episodes': anime.episodes?.toString() ?? 'N/A',
            'status': anime.status ?? 'N/A',
            'aired': anime.aired ?? 'N/A',
            'synopsis': anime.synopsis ?? 'No synopsis available',
            'studio': anime.studio ?? 'N/A',
          }
        ];
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      debugPrint('Error fetching anime data: $e');
      showErrorMessage(e.toString());
    }
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
