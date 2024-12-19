import 'package:aniview_app/widgets/viewReview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'reply_review.dart';

class ReviewCard extends StatefulWidget {
  final String userid;
  final String rating;
  final String animeTitle;
  final String reviewText;
  final String date;
  final String imageUrl;
  final String reviewId;

  const ReviewCard({
    required this.userid,
    required this.rating,
    required this.animeTitle,
    required this.reviewText,
    required this.date,
    required this.imageUrl,
    required this.reviewId,
    Key? key,
  }) : super(key: key);

  @override
  _ReviewCardState createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool showReplyContainer = false;
  String firstName = '';
  String lastName = '';
  String userImageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userid)
          .get();

      if (userDoc.exists) {
        setState(() {
          firstName = userDoc['firstName'] ?? '';
          lastName = userDoc['lastName'] ?? '';
          userImageUrl = userDoc['imageUrl'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF25283D),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: userImageUrl.isNotEmpty
                        ? CircleAvatar(
                            radius: 35,
                            backgroundImage: NetworkImage(userImageUrl),
                          )
                        : SvgPicture.asset(
                            'assets/icons/circle-user.svg',
                            height: 35,
                            width: 35,
                            color: Colors.grey,
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstName + ' ' + lastName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "Anime: ${widget.animeTitle}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        widget.rating + ' stars',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.reviewText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.imageUrl,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.date,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 10),
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
                  builder: (context) => ViewReviewsModal(
                    reviewId: widget.reviewId,
                  ),
                );
                },
                child: const Text(
                  "Reply",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        )
        // if (showReplyContainer) const ReplyReview(),
      ],
    );
  }
}
