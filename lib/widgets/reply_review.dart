import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReplyReview extends StatefulWidget {
  final String reviewID;

  const ReplyReview({
    Key? key,
    required this.reviewID,
  }) : super(key: key);

  @override
  _ReplyReviewState createState() => _ReplyReviewState();
}

class _ReplyReviewState extends State<ReplyReview> {
  final TextEditingController _replyController = TextEditingController();
  String userImageUrl = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String reviewCreatorId = '';

  @override
  void initState() {
    super.initState();
    _fetchUserImage();
    _fetchReviewCreatorId();
  }

  Future<void> sendNotification({
    required String senderId,
    required String receiverId,
    required String senderName,
    required String message,
    required String type,
    required String senderImg,
  }) async {
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
      'reviewId': widget.reviewID
    });
  }

  Future<void> _fetchUserImage() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            userImageUrl = userData['imageUrl'] ?? '';
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> _fetchReviewCreatorId() async {
    try {
      DocumentSnapshot reviewDoc = await _firestore
          .collection('reviews')
          .doc(widget.reviewID)
          .get();

      if (reviewDoc.exists) {
        Map<String, dynamic> reviewData = reviewDoc.data() as Map<String, dynamic>;
        setState(() {
          reviewCreatorId = reviewData['userId'];  // Get the userId of the review creator
        });
      }
    } catch (e) {
      print('Error fetching review creator data: $e');
    }
  }

  Future<void> _saveReply() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null && _replyController.text.isNotEmpty) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          await FirebaseFirestore.instance
              .collection('reviews')
              .doc(widget.reviewID)
              .collection('replies')
              .add({
            'replyText': _replyController.text,
            'userId': currentUser.uid,
            'userFirstName': userData['firstName'] ?? 'Anonymous',
            'userLastName': userData['lastName'] ?? '',
            'userImageUrl': userData['imageUrl'] ?? '',
            'date': Timestamp.now(),
            'isReply': true,
          });

          if (currentUser.uid != reviewCreatorId) {
            await sendNotification(
              senderId: currentUser.uid,
              receiverId: reviewCreatorId,
              senderName: '${userData['firstName']} ${userData['lastName']}',
              message: 'replied to your review',
              type: 'reply',
              senderImg: userData['imageUrl'] ?? '',
            );
          }

          _replyController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reply added successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User data not found')),
          );
        }
      } catch (e) {
        print("Error saving reply: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please write a reply before sending.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 21, 21, 33),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userImageUrl.isNotEmpty
              ? CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(userImageUrl),
                )
              : const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: InputDecoration(
                hintText: 'Write a reply...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.white),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
          ),
          IconButton(
            onPressed: _saveReply,
            icon: const Icon(Icons.send, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}
