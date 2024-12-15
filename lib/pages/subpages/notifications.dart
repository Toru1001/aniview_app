import 'package:aniview_app/pages/MyHomePage.dart';
import 'package:aniview_app/pages/subpages/user_profile.dart';
import 'package:aniview_app/widgets/appBar.dart';
import 'package:aniview_app/widgets/viewReview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("No user is logged in");

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .orderBy('date', descending: true)
          .get();

      final data = snapshot.docs.map((doc) {
      final docData = doc.data();
      docData['id'] = doc.id; 
      return docData;
    }).toList();

      setState(() {
        notifications = data.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> refreshPage() async {
    await _fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201F31),
      appBar: AniviewAppBar(),
      body: RefreshIndicator(
        onRefresh: refreshPage,
        color: Colors.redAccent,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
                  },
                ),
                const Expanded(
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Divider(
                thickness: 0.5,
                color: Colors.grey,
                height: 10,
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.redAccent,
                      ),
                    )
                  : notifications.isEmpty
                      ? const Center(
                          child: Text(
                            "No Notifications Yet!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 10),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return _buildNotificationItem(notification);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final isOpened = notification['isOpened'] ?? false;
    final profilePictureUrl = notification['senderImg'] ?? "";
    final type = notification['type'] ?? '';
    final senderId = notification['senderId'] ?? '';
    final notificationId = notification['id'] ?? '';
    final reviewId = notification['reviewId'] ?? '';

    return GestureDetector(
      onTap: (){
        markNotificationAsRead(notificationId);
        if(type == 'friend request'){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(
                userId: senderId,
              ),
            ),
          );
        }else if(type == 'reply'){
          showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: const Color(0xFF2A2940),
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => ViewReviewsModal(
                    reviewId: reviewId,
                  ),
                );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isOpened ? const Color.fromARGB(255, 40, 39, 55) : const Color(0xFF393851),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: profilePictureUrl.isNotEmpty
                  ? NetworkImage(profilePictureUrl)
                  : const AssetImage('assets/images/default_profile.png') as ImageProvider,
              backgroundColor: Colors.grey.shade800,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${notification['senderName'] ?? 'Unknown User'} ",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: notification['message'] ?? 'No message',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatTimestamp(notification['date']),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> markNotificationAsRead(String notificationId) async {
  try {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user is logged in");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notificationId)
        .update({
      'isOpened': true,
    });

    _fetchNotifications();
  } catch (e) {
    debugPrint("Error updating notification: $e");
  }
}

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "Unknown time";
    final date = (timestamp as Timestamp).toDate();
    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) return "Just now";
    if (difference.inMinutes < 60) return "${difference.inMinutes} minute(s) ago";
    if (difference.inHours < 24) return "${difference.inHours} hour(s) ago";
    return "${difference.inDays} day(s) ago";
  }
}
