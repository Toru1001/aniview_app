import 'package:aniview_app/pages/subpages/anime_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WatchlistGrid extends StatefulWidget {
  final List<Map<String, String>> animeList;
  final bool showOption;

  const WatchlistGrid({
    Key? key,
    required this.animeList,
    this.showOption = false
  }) : super(key: key);

  @override
  State<WatchlistGrid> createState() => _WatchlistGridState();
}

class _WatchlistGridState extends State<WatchlistGrid> {
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

  Future<void> _removeAnimeFromWatchlist(String docId, String watchlistId) async {
  if (userId == null) return;

  try {
    print('Removing anime with docId: $docId');

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(watchlistId)
        .collection('anime')
        .doc(docId)
        .delete();

    print('Anime removed from watchlist successfully!');
  } catch (e) {
    print('Error removing anime: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to remove anime from watchlist')),
    );
  }
}


  Future<void> _confirmRemoveAnime(String docId, String watchlistId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF201F31),
        title: Text('Remove from Watchlist', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to remove this anime from your watchlist?', style: TextStyle(color: Colors.white),),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey),),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes', style: TextStyle(color: Colors.redAccent),),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _removeAnimeFromWatchlist(docId, watchlistId);
      setState(() {
        widget.animeList.removeWhere((anime) => anime['docId'] == docId);
      });
    }
  }

  @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Padding(
    padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
    child: LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: screenWidth < 360 ? 1 : 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10,
            childAspectRatio: constraints.maxWidth < 360 ? 0.8 : 0.55,
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
                          height: screenHeight * 0.3,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: screenHeight * 0.3,
                              width: double.infinity,
                              color: const Color.fromARGB(255, 21, 21, 33),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                  color: Colors.redAccent,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: screenHeight * 0.25,
                            color: Colors.grey,
                            child: const Icon(Icons.broken_image, color: Colors.white),
                          ),
                        ),
                      ),
                      if (!widget.showOption)
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () {
                              _confirmRemoveAnime(anime['docId']!, anime['watchlistId']!);
                            },
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: const Color.fromARGB(174, 85, 85, 85),
                              child: Icon(
                                Icons.close,
                                size: 12,
                                color: Colors.white,
                              ),
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
                              return const SizedBox();
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
        );
      },
    ),
  );
}

}
