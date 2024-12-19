import 'package:aniview_app/pages/subpages/anime_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AnimeGridWidget extends StatefulWidget {
  final List<Map<String, String>> animeList;

  const AnimeGridWidget({
    Key? key,
    required this.animeList,
  }) : super(key: key);

  @override
  State<AnimeGridWidget> createState() => _AnimeGridWidgetState();
}

class _AnimeGridWidgetState extends State<AnimeGridWidget> {
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
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20.0,
          childAspectRatio: 0.55,
        ),
        itemCount: widget.animeList.length,
        itemBuilder: (context, index) {
          final anime = widget.animeList[index];
          return GestureDetector(
            onTap: () {
              if (anime['id'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnimeDetailsPage(
                      animeId: anime['id']!,
                    ),
                  ),
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        anime['img'] ?? '',
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 250,
                            width: double.infinity,
                            color: const Color.fromARGB(255, 21, 21, 33),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                                color: Colors.redAccent,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180,
                          color: Colors.grey,
                          child: const Icon(Icons.broken_image, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: FutureBuilder<bool>(
                        future: isAnimeWatched(anime['id'] ?? ''),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
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
                              : const SizedBox();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  anime['title'] ?? 'No Title',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
