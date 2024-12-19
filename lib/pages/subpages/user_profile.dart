import 'package:aniview_app/api/get_animeDetails.dart';
import 'package:aniview_app/models/anime_details.dart';
import 'package:aniview_app/widgets/anime_lists.dart';
import 'package:aniview_app/widgets/appBar.dart';
import 'package:aniview_app/widgets/editProfileModal.dart';
import 'package:aniview_app/widgets/review_feeds.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({required this.userId});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, String>> animeData = [];
  bool isLoadingUser = true;
  bool isLoadingAnime = true;
  bool hasError = false;
  Map<String, dynamic>? cachedUserData;
  String currentUserId = '';
  int friendsCount = 0;
  int reviewsCount = 0;
  int watchedCount = 0;

  @override
  void initState() {
    super.initState();
    refreshPage();
    _countFriends();
    _countReviews();
    _countWatchedAnime();
    currentUserId = _auth.currentUser!.uid;
  }

  Future<void> unfriend(String currentUserId, String friendId) async {
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .doc(friendId)
          .delete();

      await _firestore
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .doc(currentUserId)
          .delete();

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('friendRequests')
          .doc(friendId)
          .delete();

      await _firestore
          .collection('users')
          .doc(friendId)
          .collection('friendRequests')
          .doc(currentUserId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have unfriended this user.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error unfriending user: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _countWatchedAnime() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("No user logged in");

      final snapshot = await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('watched')
          .get();

      setState(() {
        watchedCount = snapshot.size;
      });
    } catch (e) {
      debugPrint("Error fetching watched anime count: $e");
      setState(() {
        watchedCount = 0;
      });
    }
  }

  Future<void> _countFriends() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("No user logged in");

      final snapshot = await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('friends')
          .get();

      setState(() {
        friendsCount = snapshot.size;
      });
    } catch (e) {
      debugPrint("Error fetching friends count: $e");
      setState(() {
        friendsCount = 0;
      });
    }
  }

  Future<void> refreshPage() async {
    setState(() {
      isLoadingUser = true;
      isLoadingAnime = true;
      _countFriends();
      _countReviews();
      _countWatchedAnime();
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

  Future<void> sendNotification({
    required String senderId,
    required String receiverId,
    required String senderName,
    required String message,
    required String type,
    required String senderImg,
  }) async {
    print(senderId + " " + receiverId + " " + senderName + " " + " " + message + " " + type + " " + senderImg);
    await _firestore
        .collection('users')
        .doc(receiverId)
        .collection('notifications')
        .add({
      'date': FieldValue.serverTimestamp(),
      'type': type,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'isOpened': false,
      'message': message,
      'senderImg': senderImg,
    });
  }

  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    await _firestore
        .collection('users')
        .doc(receiverId)
        .collection('friendRequests')
        .doc(senderId)
        .set({
      'senderId': senderId,
      'receiverId': receiverId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    final senderDoc = await _firestore.collection('users').doc(senderId).get();
    final senderData = senderDoc.data();
    final senderName =
        "${senderData?['firstName'] ?? 'Unknown'} ${senderData?['lastName'] ?? ''}"
            .trim();
    final senderImg = senderData?['imageUrl'] ?? '';

    await sendNotification(
      senderId: senderId,
      receiverId: receiverId,
      senderName: senderName,
      message: "has sent you a friend request.",
      type: "friend request",
      senderImg: senderImg,
    );
  }

  Future<void> acceptFriendRequest(String senderId, String receiverId) async {
    await _firestore
        .collection('users')
        .doc(receiverId)
        .collection('friendRequests')
        .doc(senderId)
        .update({
      'status': 'accepted',
    });

    await _firestore
        .collection('users')
        .doc(senderId)
        .collection('friends')
        .doc(receiverId)
        .set({
      'friendId': receiverId,
      'isFriend': true,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    final senderDoc = await _firestore.collection('users').doc(receiverId).get();
    final senderData = senderDoc.data();
    final senderName =
        "${senderData?['firstName'] ?? 'Unknown'} ${senderData?['lastName'] ?? ''}"
            .trim();
    final senderImg = senderData?['imageUrl'] ?? '';

    await sendNotification(
      senderId: receiverId,
      receiverId: senderId,
      senderName: senderName,
      message: "has accepted your friend request.",
      type: "friend request",
      senderImg: senderImg,
    );

    await _firestore
        .collection('users')
        .doc(receiverId)
        .collection('friends')
        .doc(senderId)
        .set({
      'friendId': senderId,
      'isFriend': true,
      'timestamp': FieldValue.serverTimestamp(),
    });

  }

  Future<void> cancelFriendRequest(String senderId, String receiverId) async {
    await _firestore
        .collection('users')
        .doc(receiverId)
        .collection('friendRequests')
        .doc(senderId)
        .delete();
  }

  Future<String> getFriendStatus(
      String currentUserId, String profileUserId) async {
    final receivedRequestDoc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friendRequests')
        .doc(profileUserId)
        .get();

    if (receivedRequestDoc.exists &&
        receivedRequestDoc['status'] == 'pending') {
      return 'Accept Request';
    }

    final sentRequestDoc = await _firestore
        .collection('users')
        .doc(profileUserId)
        .collection('friendRequests')
        .doc(currentUserId)
        .get();

    if (sentRequestDoc.exists && sentRequestDoc['status'] == 'pending') {
      return 'Pending';
    }

    final friendDoc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(profileUserId)
        .get();

    if (friendDoc.exists && friendDoc['isFriend'] == true) {
      return 'Friends';
    }

    return 'Add Friend';
  }

  Future<Map<String, dynamic>> _getUserData() async {
    if (cachedUserData != null) {
      return cachedUserData!;
    }

    final doc = await _firestore.collection('users').doc(widget.userId).get();
    if (!doc.exists) throw Exception("User document not found");

    cachedUserData = doc.data();
    return cachedUserData!;
  }

  Future<void> getTop3() async {
    try {
      final userRef =
          _firestore.collection('users').doc(widget.userId); // Change here
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201F31),
      appBar: AniviewAppBar(),
      body: RefreshIndicator(
        onRefresh: refreshPage,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                isLoadingUser) {
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
                padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
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
        FutureBuilder<String>(
          future: getFriendStatus(currentUserId, widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(color: Colors.redAccent);
            }

            if (snapshot.hasError) {
              return const Text("Error fetching friend status");
            }

            String status = snapshot.data ?? '';

            if (status == 'Accept Request') {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await acceptFriendRequest(widget.userId, currentUserId);
                      setState(() {
                        status = 'Friends';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Confirm",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: const Color(0xFF201F31),
                            title: const Text('Confirm', style: TextStyle(color: Colors.white)),
                            content: const Text(
                                'Are you sure you want to delete friend request?', style: TextStyle(color: Colors.white)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Yes', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        await cancelFriendRequest(widget.userId, currentUserId);
                        setState(() {
                          status = 'Add Friend';
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(129, 158, 158, 158),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        "X",
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 25,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  )
                ],
              );
            } else if (status == 'Pending') {
              return ElevatedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Color(0xFF201F31),
                        title: const Text('Confirm', style: TextStyle(color: Colors.white)),
                        content: const Text(
                            'Are you sure you want to cancel the friend request?', style: TextStyle(color: Colors.white)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Yes', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    await cancelFriendRequest(currentUserId, widget.userId);
                    setState(() {
                      status = 'Add Friend';
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade900,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Pending",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              );
            } else if (status == 'Friends') {
              return ElevatedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Color(0xFF201F31),
                        title: const Text('Unfriend', style: TextStyle(color: Colors.white)),
                        content: const Text(
                            'Are you sure you want to unfriend this user?', style: TextStyle(color: Colors.white)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Unfriend', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    await unfriend(currentUserId, widget.userId);
                    setState(() {
                      status = 'Add Friend';
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.redAccent)),
                ),
                child: const Text(
                  "Friends",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              );
            } else {
              return ElevatedButton(
                onPressed: () async {
                  await sendFriendRequest(currentUserId, widget.userId);
                  setState(() {
                    status = 'Pending';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Add Friend",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem("Reviews", reviewsCount.toString() ?? "0"),
            const Text(
              "|",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 30,
                  fontWeight: FontWeight.w200),
            ),
            GestureDetector(
                onTap: () {},
                child:
                    _buildStatItem("Watched", watchedCount.toString() ?? "0")),
            const Text(
              "|",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 30,
                  fontWeight: FontWeight.w200),
            ),
            _buildStatItem("Friends", friendsCount.toString() ?? "0"),
          ],
        ),
      ],
    );
  }

  Future<void> _countReviews() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("No user logged in");

      final snapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: widget.userId)
          .get();

      setState(() {
        reviewsCount = snapshot.size;
      });
    } catch (e) {
      debugPrint("Error fetching reviews count: $e");
      setState(() {
        reviewsCount = 0;
      });
    }
  }

  Column _myReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          "Anime Reviews",
          style: TextStyle(
            fontSize: 24,
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reviews')
              .where('userId',
                  isEqualTo: widget.userId) // Change here to widget.userId
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.redAccent));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                height: 100,
                width: double.infinity,
                child: Center(
                  child: const Text(
                    "No reviews yet.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              );
            }

            final reviews = snapshot.data!.docs;

            return Column(
              children: reviews.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final rawDate = data['date'];
                String formattedDate;

                try {
                  if (rawDate is Timestamp) {
                    formattedDate = DateFormat('MM/dd/yyyy hh:mm a')
                        .format(rawDate.toDate());
                  } else if (rawDate is String) {
                    final parsedDate = DateTime.tryParse(rawDate);
                    if (parsedDate != null) {
                      formattedDate =
                          DateFormat('MM/dd/yyyy hh:mm a').format(parsedDate);
                    } else {
                      formattedDate = 'Invalid Date';
                    }
                  } else {
                    formattedDate = 'Unknown Date';
                  }
                } catch (e) {
                  formattedDate = 'Error Formatting Date';
                }

                String reviewId = doc.id;
                final userId = FirebaseAuth.instance.currentUser?.uid;
                return ReviewCard(
                  reviewId: reviewId,
                  userid: data['userId'] ?? 'Unknown User',
                  rating: data['rating'].toString() ?? '',
                  animeTitle: data['title'] ?? 'Unknown Anime',
                  reviewText: data['review'] ?? '',
                  date: formattedDate,
                  imageUrl: data['imgUrl'] ?? 'https://via.placeholder.com/150',
                  currentUserId: userId!.toString(),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Column _top4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Top 3",
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
                ? Container(
                    height: 100,
                    child: const Center(
                      child: Text(
                        "Did not add Top 3 yet",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                : AnimeListWidget(animeList: animeData),
        const SizedBox(height: 10),
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
}
