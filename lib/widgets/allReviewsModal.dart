import 'package:aniview_app/widgets/addReviewModal.dart';
import 'package:aniview_app/widgets/reply.dart';
import 'package:aniview_app/widgets/review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllReviewsModal extends StatefulWidget {
  final String img;
  final String title;
  final String id;
  final String genre;

  const AllReviewsModal({
    Key? key,
    required this.img,
    required this.title,
    required this.id,
    required this.genre,
  }) : super(key: key);

  @override
  State<AllReviewsModal> createState() => _AllReviewsModalState();
}

class _AllReviewsModalState extends State<AllReviewsModal> {
  Map<String, bool> replyVisibility = {};

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
                  'Reviews',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: Colors.white),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: const Color(0xFF2A2940),
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => AddReviewModal(
                        genre: widget.genre,
                        id: widget.id,
                        img: widget.img,
                        title: widget.title,
                      ),
                    );
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 19,
                        color: Colors.redAccent),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reviews')
                        .where('animeId', isEqualTo: widget.id)
                        .orderBy('date', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error loading reviews'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Column(
                          children: [
                            SizedBox(height: 20,),
                             Center(
                              child: Text(
                                'No reviews yet',
                                style: TextStyle(color: Colors.grey, fontSize: 20),
                              ),
                            ),
                          ],
                        );
                      }

                      List<Widget> reviewWidgets = [];
                      for (var reviewDoc in snapshot.data!.docs) {
                        var reviewData =
                            reviewDoc.data() as Map<String, dynamic>;
                        String userId = reviewData['userId'];
                        String reviewId = reviewDoc.id;

                        Timestamp timestamp = reviewData['date'];
                        DateTime dateTime = timestamp.toDate();
                        String formattedDate =
                            DateFormat('MM/dd/yyyy HH:mm').format(dateTime);

                        reviewWidgets.add(
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .get(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.hasError) {
                                return const Center(
                                    child: Text('Error loading user data'));
                              }

                              if (!userSnapshot.hasData ||
                                  !userSnapshot.data!.exists) {
                                return const Center(child: Text(''));
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
                                            child:
                                                Text('Error loading replies'));
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
                                        String replyText =
                                            replyData['replyText'] ?? '';
                                        String replyFirstName =
                                            replyData['userFirstName'] ??
                                                'Unknown';
                                        String replyLastName =
                                            replyData['userLastName'] ?? 'User';
                                        String replyImageUrl =
                                            replyData['userImageUrl'] ?? '';

                                        Timestamp replyTimestamp =
                                            replyData['date'];
                                        DateTime replyDateTime =
                                            replyTimestamp.toDate();
                                        String formattedReplyDate =
                                            DateFormat('MM/dd/yyyy HH:mm')
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                // Toggle reply visibility and change the text accordingly
                                                replyVisibility[reviewId] =
                                                    !(replyVisibility[
                                                            reviewId] ??
                                                        false);
                                              });
                                            },
                                            child: Text(
                                              replyVisibility[reviewId] ?? false
                                                  ? 'Show Less'
                                                  : '${replySnapshot.data!.docs.length} replies',
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          if (replyVisibility[reviewId] ??
                                              false)
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
                          ),
                        );
                      }

                      return Column(children: reviewWidgets);
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
