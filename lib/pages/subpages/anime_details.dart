import 'package:aniview_app/api/get_animeDetails.dart';
import 'package:aniview_app/api/get_animeSuggestion.dart';
import 'package:aniview_app/models/anime_details.dart';
import 'package:aniview_app/models/anime_model.dart';
import 'package:aniview_app/widgets/addReviewModal.dart';
import 'package:aniview_app/widgets/allReviewsModal.dart';
import 'package:aniview_app/widgets/anime_lists.dart';
import 'package:aniview_app/widgets/appBar.dart';
import 'package:aniview_app/widgets/reply.dart';
import 'package:aniview_app/widgets/review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double animeRating = 0.0;
  @override
  void initState() {
    super.initState();
    fetchAnimeData(widget.animeId);
    fetchAnimeSuggestion();
    fetchAnimeRating(widget.animeId);
  }

  Future<void> fetchAnimeRating(String animeId) async {
    try {
      QuerySnapshot reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('animeId', isEqualTo: animeId)
          .get();

      int totalRatings = 0;
      double sumRatings = 0.0;

      for (var doc in reviewsSnapshot.docs) {
        Map<String, dynamic> reviewData = doc.data() as Map<String, dynamic>;
        if (reviewData.containsKey('rating')) {
          sumRatings += reviewData['rating'];
          totalRatings++;
        }
      }

      double averageRating = totalRatings > 0 ? sumRatings / totalRatings : 0.0;

      setState(() {
        animeRating = averageRating;
      });
    } catch (e) {
      debugPrint('Error fetching anime rating: $e');
    }
  }

  List<Map<String, String>> animeSuggestion = [];
  List<Map<String, String>> animeData = [];
  bool isLoading = true;
  bool hasError = false;
  bool isExpanded = false;
  bool isTop3 = false;

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
        const SizedBox(
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
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500),
            ),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: const Color(0xFF2A2940),
                  context: context,
                  shape: const RoundedRectangleBorder(
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
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .where('animeId', isEqualTo: anime['id'])
                  .orderBy('date', descending: true)
                  .limit(2)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading reviews'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No reviews yet',
                      style: TextStyle(color: Colors.grey, fontSize: 20),
                    ),
                  );
                }

                List<Widget> reviewWidgets = [];
                for (var reviewDoc in snapshot.data!.docs) {
                  var reviewData = reviewDoc.data() as Map<String, dynamic>;
                  String userId = reviewData['userId'];
                  String reviewId = reviewDoc.id;

                  Timestamp timestamp = reviewData['date'];
                  DateTime dateTime = timestamp.toDate();
                  String formattedDate =
                      DateFormat('MM/dd/yyyy hh:mm a').format(dateTime);

                  reviewWidgets.add(FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (userSnapshot.hasError) {
                        return const Center(
                            child: Text('Error loading user data'));
                      }

                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return const Center(child: Text('User not found'));
                      }

                      var userData = userSnapshot.data!;
                      String userFirstName = userData['firstName'];
                      String userLastName = userData['lastName'];
                      String userImageUrl = userData['imageUrl'] ?? '';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ReviewWidget(
                            animeId: reviewData['animeId'],
                            review: reviewData['review'],
                            title: reviewData['title'],
                            dateTime: formattedDate,
                            rating: reviewData['rating'],
                            userFirstName: userFirstName,
                            userLastName: userLastName,
                            userImageUrl: userImageUrl,
                            reviewId: reviewId,
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('reviews')
                                .doc(reviewId)
                                .collection('replies')
                                .where('isReply', isEqualTo: true)
                                .orderBy('date', descending: true)
                                .limit(1)
                                .snapshots(),
                            builder: (context, replySnapshot) {
                              if (replySnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (replySnapshot.hasError) {
                                return const Center(
                                    child: Text('Error loading reply'));
                              }

                              if (!replySnapshot.hasData ||
                                  replySnapshot.data!.docs.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              var replyDoc = replySnapshot.data!.docs.first;
                              var replyData =
                                  replyDoc.data() as Map<String, dynamic>;
                              String replyText = replyData['replyText'] ?? '';
                              String replyFirstName =
                                  replyData['userFirstName'] ?? 'Unknown';
                              String replyLastName =
                                  replyData['userLastName'] ?? 'User';
                              String replyImageUrl =
                                  replyData['userImageUrl'] ?? '';

                              Timestamp replyTimestamp = replyData['date'];
                              DateTime replyDateTime = replyTimestamp.toDate();
                              String formattedReplyDate =
                                  DateFormat('MM/dd/yyyy hh:mm a')
                                      .format(replyDateTime);

                              return ReplyWidget(
                                replyText: replyText,
                                userFirstName: replyFirstName,
                                userLastName: replyLastName,
                                userImageUrl: replyImageUrl,
                                dateTime: formattedReplyDate,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ));
                }

                return Column(children: reviewWidgets);
              },
            ),
          ],
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
            backgroundColor: const Color(0xFF201F31),
            context: context,
            shape: const RoundedRectangleBorder(
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
            width: 2,
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
        Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                      softWrap: true,
                    ),
                    Text(
                      anime['genres'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalDialog(anime);
                    },
                    child: const Icon(
                      Icons.bookmark_add_outlined,
                      color: Colors.redAccent,
                      size: 35,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Text(
                    'Rating',
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w400,
                        fontSize: 18),
                  ),
                  Text(
                    animeRating.toString(),
                    style: const TextStyle(
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

  Future<void> fetchAnimeData(final String animeId) async {
    try {
      AnimeDetailsModel anime = await fetchAnimeDetails(widget.animeId);
      final user = _auth.currentUser;
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user?.uid);
      final userDoc = await userRef.get();

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

        if (userDoc.exists) {
          List<String> topAnime =
              List<String>.from(userDoc.data()?['top3'] ?? []);
          isTop3 = topAnime.contains(animeId);
        }
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

  Future<void> addFavoriteAnime(String animeId) async {
    try {
      final user = _auth.currentUser;
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user?.uid);
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        List<String> topAnime =
            List<String>.from(userDoc.data()?['top3'] ?? []);

        if (topAnime.contains(animeId)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Anime already exists in your Top 3 list!",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.grey,
            ),
          );
          return;
        }

        if (topAnime.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Top 3 Limit Reached! You can't add more anime.",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.grey,
            ),
          );
          return;
        }

        topAnime.add(animeId);
        await userRef.update({'top3': topAnime});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text(
              "Anime added successfully.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else {
        await userRef.set({
          'top3': [animeId],
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Anime added successfully.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }

  Future<void> removeFromTop3(String animeId) async {
    try {
      final user = _auth.currentUser;
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user?.uid);
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        List<String> topAnime =
            List<String>.from(userDoc.data()?['top3'] ?? []);

        topAnime.remove(animeId);

        await userRef.update({'top3': topAnime});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Anime removed from Top 3.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }

  Future<void> refreshPage() async {
    _updateLoadingState(true);
    try {
      await fetchAnimeData(widget.animeId);
      await fetchAnimeSuggestion();
      _updateErrorState(false);
    } catch (error) {
      _updateErrorState(true);
    } finally {
      _updateLoadingState(false);
    }
  }

  void _updateLoadingState(bool state) {
    setState(() {
      isLoading = state;
    });
  }

  void _updateErrorState(bool state) {
    setState(() {
      hasError = state;
    });
  }

  void showModalDialog(Map<String, String> anime) async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final String animeId = anime['id'] ?? '';
    final String animeImg = anime['alternative'] ?? '';
    final String animeTitle = anime['title'] ?? '';
    bool isWatched = await checkIfAnimeIsWatched(userId, animeId);
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final watchlistsSnapshot = await userDoc.collection('watchlist').get();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.all(20),
          backgroundColor: const Color(0xFF201F31),
          child: Container(
            height: 500,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Add to',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          isTop3
                              ? GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title:
                                              const Text('Remove from Top 3'),
                                          content: const Text(
                                              'Are you sure you want to remove this anime from your Top 3?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                await removeFromTop3(
                                                    anime['id'] ?? '');
                                                refreshPage();
                                              },
                                              child: const Text('Remove'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Transform.rotate(
                                    angle: -90 * (3.14 / 180),
                                    child: const Icon(
                                      Icons.double_arrow_sharp,
                                      color: Colors.redAccent,
                                      size: 60,
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    addFavoriteAnime(anime['id'] ?? '');
                                    Navigator.of(context).pop();
                                    refreshPage();
                                  },
                                  child: Transform.rotate(
                                    angle: -90 * (3.14 / 180),
                                    child: const Icon(
                                      Icons.double_arrow_sharp,
                                      color: Colors.grey,
                                      size: 60,
                                    ),
                                  ),
                                ),
                          const Text(
                            'Top 3',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (isWatched) {
                                bool shouldRemove = await showConfirmDialog(
                                    'Remove Watched',
                                    'Are you sure you want to remove this anime from your Watched list?');
                                if (shouldRemove) {
                                  await removeAnimeFromWatched(userId, animeId);
                                  isWatched = false;
                                  refreshPage();
                                }
                              } else {
                                await addAnimeToWatched(
                                    userId, animeId, animeImg, animeTitle);
                                isWatched = true;
                                refreshPage();
                              }
                              Navigator.of(context).pop();
                            },
                            child: Icon(
                              Icons.remove_red_eye_outlined,
                              color: isWatched ? Colors.redAccent : Colors.grey,
                              size: 60,
                            ),
                          ),
                          const Text(
                            'Watched',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Watchlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const Divider(
                    thickness: .5,
                    color: Colors.grey,
                    height: 10,
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: watchlistsSnapshot.docs.length,
                      itemBuilder: (context, index) {
                        final watchlist = watchlistsSnapshot.docs[index];
                        final watchlistName = watchlist['name'];

                        return ListTile(
                          leading: Icon(
                            Icons.video_library_outlined,
                            size: 35,
                            color: Colors.redAccent,
                          ),
                          title: Text(
                            watchlistName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w300),
                          ),
                          onTap: () async {
                            final animeInWatchlist = await FirebaseFirestore
                                .instance
                                .collection('users')
                                .doc(userId)
                                .collection('watchlist')
                                .doc(watchlist.id)
                                .collection('anime')
                                .where('animeId', isEqualTo: animeId)
                                .get();

                            if (animeInWatchlist.docs.isEmpty) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .collection('watchlist')
                                  .doc(watchlist.id)
                                  .collection('anime')
                                  .add({
                                'animeId': animeId,
                                'animeImage': anime['alternative'] ?? '',
                                'animeTitle': anime['title'] ?? '',
                                'addedAt': Timestamp.now(),
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Anime added to $watchlistName'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );

                              Navigator.of(context).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Anime is already in $watchlistName',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.grey,
                                ),
                              );
                            }
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          thickness: 0.5,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> addAnimeToWatched(
      String userId, String animeId, String animeImg, String animeTitle) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('watched')
          .doc(animeId)
          .set({
        'addedAt': FieldValue.serverTimestamp(),
        'animeTitle': animeTitle,
        'animeImg': animeImg,
        'animeId': animeId
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              'Anime added to Watched!',
              style: TextStyle(color: Colors.white),
            )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.grey,
            content: Text(
              'Failed to add to Watched: $e',
              style: TextStyle(color: Colors.white),
            )),
      );
    }
  }

  Future<void> removeAnimeFromWatched(String userId, String animeId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('watched')
          .doc(animeId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              'Anime removed from Watched!',
              style: TextStyle(color: Colors.white),
            )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.grey,
            content: Text(
              'Failed to remove from Watched: $e',
              style: TextStyle(color: Colors.white),
            )),
      );
    }
  }

  Future<bool> checkIfAnimeIsWatched(String userId, String animeId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('watched')
          .doc(animeId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
