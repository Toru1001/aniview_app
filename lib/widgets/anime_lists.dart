import 'package:aniview_app/pages/subpages/anime_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AnimeListWidget extends StatefulWidget {
  final List<Map<String, String>> animeList;

  const AnimeListWidget({
    Key? key,
    required this.animeList,
  }) : super(key: key);

  @override
  State<AnimeListWidget> createState() => _AnimeListWidgetState();
}

class _AnimeListWidgetState extends State<AnimeListWidget> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<bool> isAnimeWatched(String animeId) async {
    if (userId == null) return false;
    try {
      final watchedDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('watched')
          .doc(animeId)
          .get();
      return watchedDoc.exists;
    } catch (e) {
      print('Error checking watched status: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.animeList.length,
        itemBuilder: (context, index) {
          final anime = widget.animeList[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnimeDetailsPage(
                    animeId: anime['id']!,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          anime['img']!,
                          height: 180,
                          width: 120,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return SizedBox(
                                height: 180,
                                width: 120,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            (loadingProgress.expectedTotalBytes ??
                                                1)
                                        : null,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              );
                            }
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 180,
                            width: 120,
                            color: Colors.grey,
                            child: const Icon(Icons.broken_image,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: FutureBuilder<bool>(
                          future: isAnimeWatched(anime['id'] ?? ''),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(); // No overlay while loading
                            }

                            final isWatched = snapshot.data ?? false;

                            return isWatched
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 8),
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(228, 255, 82, 82),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(5),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Watched',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const SizedBox(); // No overlay if not watched
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 120,
                    child: Text(
                      anime['title']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
