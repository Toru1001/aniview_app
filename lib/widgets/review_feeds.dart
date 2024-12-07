import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'reply_review.dart'; 

class ReviewCard extends StatefulWidget {
  final String username;
  final String rating;
  final String animeTitle;
  final String reviewText;
  final String date;
  final String imageUrl;

  const ReviewCard({
    required this.username,
    required this.rating,
    required this.animeTitle,
    required this.reviewText,
    required this.date,
    required this.imageUrl,
    Key? key,
  }) : super(key: key);

  @override
  _ReviewCardState createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool showReplyContainer = false;

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
                    child: SvgPicture.asset(
                      'assets/icons/circle-user.svg',
                      height: 40,
                      width: 40,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.username,
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
                        widget.rating,
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
                  height: 200,
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
                  setState(() {
                    showReplyContainer = !showReplyContainer;
                  });
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
        if (showReplyContainer) const ReplyReview(),
      ],
    );
  }
}
