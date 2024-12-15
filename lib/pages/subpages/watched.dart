import 'package:aniview_app/api/get_seeAll.dart';
import 'package:aniview_app/models/anime_model.dart';
import 'package:aniview_app/widgets/anime_grid.dart';
import 'package:aniview_app/widgets/anime_watchlist_grid.dart';
import 'package:aniview_app/widgets/appBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewWatched extends StatefulWidget {

  const ViewWatched({
    Key? key,
  }) : super(key: key);

  @override
  State<ViewWatched> createState() => _ViewWatchedState();
}

class _ViewWatchedState extends State<ViewWatched> {
  List<Map<String, String>> animeData = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchAnimeData();
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

    final watchedCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('watched');  // Accessing the 'watched' collection

    try {
      final animeSnapshot = await watchedCollection.get();  // Fetch documents in 'watched'
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
        final animeId = doc.id;
        final animeData = doc.data();
        final animeTitle = animeData['animeTitle'] ?? 'Unknown Title'; 
        final animeImg = animeData['animeImg'] ?? '';  

        fetchedAnimeData.add({
          'id': animeId,
          'title': animeTitle,
          'img': animeImg,
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
                Text(
                    'Watched',
                    style: const TextStyle(
                      fontSize: 25,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  ),
              ],
            ),
            const Divider(
              thickness: 0.5,
              color: Colors.grey,
              height: 10,
            ),
            SizedBox(height: 10,),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.redAccent,
                      ),
                    )
                  : hasError
                      ? Center(
                          child: Text(
                            'No anime watched yet!',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                        )
                      : WatchlistGrid(animeList: animeData, showOption: true,),  // Display the fetched anime
            ),
          ],
        ),
      ),
    );
  }
}
