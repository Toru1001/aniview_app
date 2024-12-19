import 'package:aniview_app/api/get_seeAll.dart';
import 'package:aniview_app/models/anime_model.dart';
import 'package:aniview_app/widgets/anime_grid.dart';
import 'package:aniview_app/widgets/anime_watchlist_grid.dart';
import 'package:aniview_app/widgets/appBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewWatchlist extends StatefulWidget {
  final String watchlistId;
  final String watchlistTitle;

  const ViewWatchlist({
    Key? key,
    required this.watchlistId,
    required this.watchlistTitle,
  }) : super(key: key);

  @override
  State<ViewWatchlist> createState() => _ViewWatchlistState();
}

class _ViewWatchlistState extends State<ViewWatchlist> {
  List<Map<String, String>> animeData = [];
  bool isLoading = true;
  bool hasError = false;
  bool isFetchingMore = false;
  int currentPage = 1;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchAnimeData();
    print(widget.watchlistId);
  }

  Future<void> fetchAnimeData() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  
  if (userId == null) {
    print("User is not logged in!");
    setState(() {
      hasError = true;
      isLoading = false;
    });
    return;
  }

  final watchlistDoc = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('watchlist')
      .doc(widget.watchlistId);

  try {
    final animeSnapshot = await watchlistDoc.collection('anime').get();
    print('Anime Snapshot: ${animeSnapshot.docs.length} documents found.');

    if (animeSnapshot.docs.isEmpty) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      return;
    }

    final List<Map<String, String>> fetchedAnimeData = [];
    for (var doc in animeSnapshot.docs) {
      final animeId = doc['animeId'];  
      final animeTitle = doc['animeTitle'];  
      final animeImg = doc['animeImage'];  
      final docId = doc.id;

      fetchedAnimeData.add({
        'id': animeId,
        'title': animeTitle,
        'img': animeImg,
        'docId': docId,
        'watchlistId': widget.watchlistId,
      });
    }

    setState(() {
      animeData = fetchedAnimeData;
      isLoading = false;
    });
  } catch (e) {
    print('Error fetching data: $e');
    setState(() {
      hasError = true;
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201F31),
      appBar: const AniviewAppBar(),
      body: Container(
        margin: const EdgeInsets.all(10),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                
              ],
            ),
            const Divider(
              thickness: 0.5,
              color: Colors.grey,
              height: 10,
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Watchlist: ',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Text(
                    widget.watchlistTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.redAccent,
                      ),
                    )
                  : hasError
                      ?  Center(
                          child: Text(
                            'Watchlist Empty',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                        )
                      : WatchlistGrid(animeList: animeData),
            ),
          ],
        ),
      ),
    );
  }
}
