import 'package:aniview_app/widgets/addReviewModal.dart';
import 'package:aniview_app/widgets/reply.dart';
import 'package:aniview_app/widgets/review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewReviewsModal extends StatefulWidget {
  final String reviewId;

  const ViewReviewsModal({
    Key? key,
    required this.reviewId,
  }) : super(key: key);

  @override
  State<ViewReviewsModal> createState() => _ViewReviewsModalState();
}

class _ViewReviewsModalState extends State<ViewReviewsModal> {
  Map<String, bool> replyVisibility = {};

  @override
  void initState() {
    super.initState();

    // Set the default visibility for the replies to true (expanded by default)
    replyVisibility[widget.reviewId] = true;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.8,
      widthFactor: 1,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 19,
                        color: Colors.grey),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
                const Text(
                  'Review',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: Colors.white),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                GestureDetector(
                  onTap: () {
                    //Test
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 19,
                        color: const Color(0xFF2A2940)),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reviews')
                        .doc(widget.reviewId) 
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error loading review'));
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Center(
                          child: Text('Review not found'),
                        );
                      }

                      var reviewData = snapshot.data!.data() as Map<String, dynamic>;
                      String userId = reviewData['userId'];
                      String reviewId = snapshot.data!.id;

                      Timestamp timestamp = reviewData['date'];
                      DateTime dateTime = timestamp.toDate();
                      String formattedDate =
                          DateFormat('MM/dd/yyyy hh:mm a').format(dateTime);

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.hasError) {
                            return const Center(child: Text('Error loading user data'));
                          }

                          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                            return const Center(child: Text('User not found'));
                          }

                          var userData = userSnapshot.data!;
                          String userFirstName = userData['firstName'];
                          String userLastName = userData['lastName'];
                          String userImageUrl = userData['imageUrl'] ?? '';

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ReviewWidget(
                                animeId: reviewData['animeId'],
                                review: reviewData['review'],
                                title: reviewData['title'],
                                dateTime: formattedDate,
                                rating: reviewData['rating'],
                                userFirstName: userFirstName,
                                userLastName: userLastName,
                                userImageUrl: userImageUrl,
                                reviewId: reviewId,
                              ),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('reviews')
                                    .doc(reviewId)
                                    .collection('replies')
                                    .where('isReply', isEqualTo: true)
                                    .orderBy('date', descending: true)
                                    .snapshots(),
                                builder: (context, replySnapshot) {
                                  if (replySnapshot.hasError) {
                                    return const Center(
                                        child: Text('Error loading replies'));
                                  }

                                  if (!replySnapshot.hasData ||
                                      replySnapshot.data!.docs.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  List<Widget> replyWidgets = [];
                                  for (var replyDoc
                                      in replySnapshot.data!.docs) {
                                    var replyData = replyDoc.data()
                                        as Map<String, dynamic>;
                                    String replyText = replyData['replyText'] ?? '';
                                    String replyFirstName =
                                        replyData['userFirstName'] ?? 'Unknown';
                                    String replyLastName =
                                        replyData['userLastName'] ?? 'User';
                                    String replyImageUrl =
                                        replyData['userImageUrl'] ?? '';

                                    Timestamp replyTimestamp = replyData['date'];
                                    DateTime replyDateTime = replyTimestamp.toDate();
                                    String formattedReplyDate =
                                        DateFormat('MM/dd/yyyy hh:mm a')
                                            .format(replyDateTime);

                                    replyWidgets.add(
                                      ReplyWidget(
                                        replyText: replyText,
                                        userFirstName: replyFirstName,
                                        userLastName: replyLastName,
                                        userImageUrl: replyImageUrl,
                                        dateTime: formattedReplyDate,
                                      ),
                                    );
                                  }

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Column(
                                        children: replyWidgets,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
