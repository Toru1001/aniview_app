import 'package:aniview_app/api/get_animeDetails.dart';
import 'package:aniview_app/models/anime_details.dart';
import 'package:aniview_app/widgets/anime_lists.dart';
import 'package:aniview_app/widgets/editProfileModal.dart';
import 'package:aniview_app/widgets/review_feeds.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, String>> animeData = [];
  bool isLoadingUser = true; 
  bool isLoadingAnime = true; 
  bool hasError = false;
  Map<String, dynamic>? cachedUserData;

  @override
  void initState() {
    super.initState();
    refreshPage();
  }

  Future<void> refreshPage() async {
    setState(() {
      isLoadingUser = true;
      isLoadingAnime = true; 
      animeData = []; 
    });

    try {
      await getTop3(); 
      cachedUserData = null; 
      await _getUserData(); 
      setState(() {
        hasError = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoadingUser = false; 
        isLoadingAnime = false;
      });
    }
  }

  Future<Map<String, dynamic>> _getUserData() async {
    if (cachedUserData != null) {
      return cachedUserData!;
    }

    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) throw Exception("User document not found");

    cachedUserData = doc.data();
    return cachedUserData!;
  }

  Future<void> getTop3() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User is not logged in");

      final userRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) throw Exception("User document not found");

      List<String> topAnime = List<String>.from(userDoc.data()?['top3'] ?? []);
      List<Map<String, String>> fetchedAnimeData = [];

      for (String animeId in topAnime) {
        try {
          AnimeDetailsModel anime = await fetchAnimeDetails(animeId);
          fetchedAnimeData.add({
            'id': anime.id ?? '',
            'title': anime.title ?? 'No title available',
            'img': anime.alternative_img ?? '',
          });
        } catch (animeError) {
          debugPrint("Failed to fetch details for Anime ID: $animeId");
        }
      }

      setState(() {
        animeData = fetchedAnimeData;
        isLoadingAnime = false;
      });
    } catch (e) {
      setState(() {
        isLoadingAnime = false;
        hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching Top 3 anime: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String? getUserEmail() {
    final User? user = _auth.currentUser;
    return user?.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201F31),
      body: RefreshIndicator(
        onRefresh: refreshPage,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && isLoadingUser) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  "No user data found",
                  style: TextStyle(color: Colors.redAccent),
                ),
              );
            }

            final userData = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    _profileHero(userData),
                    _divider(),
                    _top4(),
                    _myReviews(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Profile Hero Section
  Column _profileHero(Map<String, dynamic> userData) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.redAccent, Colors.red.shade300],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  _auth.signOut();
                  Navigator.pop(context);
                },
              ),
            ),
            Positioned(
              bottom: -50,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: const Color(0xFF201F31),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: userData['imageUrl'] != null
                      ? NetworkImage(userData['imageUrl'])
                      : null,
                  child: userData['imageUrl'] == null
                      ? Icon(Icons.person, color: Colors.grey[400], size: 60)
                      : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        Text(
          "${userData['firstName']} ${userData['lastName']}" ?? "Unknown",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          "@${userData['username'] ?? 'unknown'}",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final updated = await showModalBottomSheet<bool>(
              isScrollControlled: true,
              backgroundColor: const Color(0xFF2A2940),
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => EditProfileModal(
                email: getUserEmail() ?? "Unknown",
                firstName: userData['firstName'],
                lastName: userData['lastName'],
                imgUrl: userData['imageUrl'],
                username: userData['username'],
              ),
            );

            if (updated == true) {
              await refreshPage(); 
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            "Edit Profile",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem("Reviews", userData['reviewsCount'] ?? "0"),
            const Text(
              "|",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 30,
                  fontWeight: FontWeight.w200),
            ),
            _buildStatItem("Watched", userData['watchedCount'] ?? "0"),
            const Text(
              "|",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 30,
                  fontWeight: FontWeight.w200),
            ),
            _buildStatItem("Friends", userData['friendsCount'] ?? "0"),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Divider _divider() {
    return const Divider(
      thickness: .5,
      color: Colors.grey,
      height: 40,
    );
  }

  Column _top4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "My Top 3",
          style: TextStyle(
            fontSize: 24,
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        isLoadingAnime
            ? const Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              )
            : animeData.isEmpty
                ? const Center(
                    child: Text(
                      "No anime found in your Top 3 list!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  )
                : AnimeListWidget(animeList: animeData),
        const SizedBox(height: 10),
      ],
    );
  }

  Column _myReviews() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Anime Reviews",
          style: TextStyle(
            fontSize: 24,
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        ReviewCard(
                username: "User1024",
                rating: "5 star",
                animeTitle: "Sousou no Frieren",
                reviewText:
                    "I like the series overall <3. Hoping for season 2!",
                date: "12/03/2024",
                imageUrl:
                    "https://cdn.myanimelist.net/images/anime/1015/138006.jpg",
              ),
      ],
    );
  }
}
