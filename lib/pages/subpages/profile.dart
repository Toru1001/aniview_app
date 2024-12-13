import 'package:aniview_app/widgets/editProfileModal.dart';
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
  

  String? getUserEmail() {
    final User? user = _auth.currentUser; 
    if (user != null) {
      return user.email; 
    }
    return null;
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("No user logged in");
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      throw Exception("User document not found");
    }

    return doc.data()!;
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFF201F31),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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
    );
  }

  

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
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
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
          userData['firstName'] + " " + userData['lastName'] ?? "Unknown",
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
          onPressed: () {
            showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Color(0xFF2A2940),
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => EditProfileModal(
                  email:  getUserEmail() ?? "Unknown",
                  firstName: userData['firstName'],
                  lastName: userData['lastName'],
                  imgUrl: userData['imageUrl'],
                  username: userData['username'],
                  onProfileUpdated: (){
                    setState(() {}); 
                  },
                ));
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
            _buildStatItem("Reviews", userData['reviewsCount']??0.toString()),
            const Text(
              "|",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 30,
                  fontWeight: FontWeight.w200),
            ),
            _buildStatItem("Watched", userData['watchedCount']??0.toString()),
            const Text(
              "|",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 30,
                  fontWeight: FontWeight.w200),
            ),
            _buildStatItem("Friends", userData['friendsCount'] ?? 0.toString()),
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
            GestureDetector(
              onTap: () {
                // Handle edit action
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
            // Example reviews
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
