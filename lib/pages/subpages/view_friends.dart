import 'package:aniview_app/pages/subpages/user_profile.dart';
import 'package:aniview_app/widgets/appBar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewFriends extends StatefulWidget {
  final String userId;

  const ViewFriends({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ViewFriends> createState() => _ViewFriendsState();
}

class _ViewFriendsState extends State<ViewFriends> {
  List<Map<String, dynamic>> friendsList = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchFriends();
    print(widget.userId);
  }

  Future<void> fetchFriends() async {
    try {
      final friendsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('friends')
          .get();

      if (friendsSnapshot.docs.isEmpty) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        return;
      }

      final List<Map<String, dynamic>> fetchedFriends = [];

      for (var doc in friendsSnapshot.docs) {
        final friendId = doc.id;

        final friendSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .get();

        if (friendSnapshot.exists) {
          fetchedFriends.add({
            'id': friendId,
            'fullName': friendSnapshot['firstName'] +
                    ' ' +
                    friendSnapshot['lastName'] ??
                'Unknown Name',
            'username': friendSnapshot['username'] ?? 'unknown',
            'profilePicture': friendSnapshot['imageUrl'],
          });
        }
      }

      setState(() {
        friendsList = fetchedFriends;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching friends: $e');
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Friends',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(
              thickness: 0.5,
              color: Colors.grey,
              height: 10,
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.redAccent,
                    ),
                  )
                : hasError
                    ? const Center(
                        child: Text(
                          "Failed to load friends.",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: friendsList.length,
                          itemBuilder: (context, index) {
                            final friend = friendsList[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserProfilePage(
                                      userId: friend['id'] ?? '',
                                    ),
                                  ),
                                );
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: friend['profilePicture'] !=
                                          null
                                      ? NetworkImage(friend['profilePicture'])
                                      : const AssetImage(
                                              'assets/icons/circle-user.svg')
                                          as ImageProvider,
                                  backgroundColor: Colors.grey[800],
                                ),
                                title: Text(
                                  friend['fullName'],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '@${friend['username']}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
