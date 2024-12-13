import 'package:aniview_app/widgets/editProfileModal.dart';
import 'package:aniview_app/widgets/review_feeds.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201F31),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              _profileHero(),
              _divider(),
              _top4(),
              _myReviews()
            ],
          ),
        ),
      ),
    );
  }

  Column _myReviews() {
    return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Anime Reviews",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Column(
                  children: [
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
                    SizedBox(
                      height: 20,
                    ),
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
                ),
                SizedBox(height: 10),
              ],
            );
  }

  Column _top4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "My Top 4",
              style: TextStyle(
                fontSize: 24,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector.new(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => SeeAllAnime(
                //       title: title,
                //       type: type,
                //       filter: filter,
                //     ),
                //   ),
                // );
              },
              child: const Text(
                "Edit",
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
        // AnimeListWidget(animeList: anime),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            height: 180,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
          ),
        ),

        const SizedBox(height: 10),
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

  Column _profileHero() {
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
            // Logout icon
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                onPressed: () {
                  // Add logout functionality here
                },
              ),
            ),
            // Overlapping CircleAvatar (Centered)
            Positioned(
              bottom: -50, // Position the avatar to overlap the gradient
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFF201F31),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: const Color(0xFF201F31),
                    width: 5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[800],
                  child: Icon(
                    Icons.person,
                    color: Colors.grey[400],
                    size: 60,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        const Text(
          "John Doe",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          "@johnDoe",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
            isScrollControlled: true,
            backgroundColor: Color(0xFF2A2940),
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => EditProfileModal()
          );
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
            _buildStatItem("Reviews", "8.3 K"),
            const Text(
              "|",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 30,
                  fontWeight: FontWeight.w200),
            ),
            _buildStatItem("Watched", "78"),
            const Text(
              "|",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 30,
                  fontWeight: FontWeight.w200),
            ),
            _buildStatItem("Friends", "200"),
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
}
