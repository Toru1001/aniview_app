import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aniview_app/widgets/reply_review.dart';

class ReviewWidget extends StatefulWidget {
  final String animeId;
  final String review;
  final String title;
  final String dateTime;
  final int rating;
  final String userFirstName;
  final String userLastName;
  final String userImageUrl;
  final String reviewId;
  final bool isReply;

  const ReviewWidget({
    Key? key,
    required this.animeId,
    required this.review,
    required this.title,
    required this.dateTime,
    required this.rating,
    required this.userFirstName,
    required this.userLastName,
    required this.userImageUrl,
    required this.reviewId,
    this.isReply = false,
  }) : super(key: key);

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  bool showReplyContainer = false;

  @override
  Widget build(BuildContext context) {
    String userFullName = '${widget.userFirstName} ${widget.userLastName}';

    return Align(
      alignment: widget.isReply ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: widget.isReply
            ? MediaQuery.of(context).size.width * 0.8
            : MediaQuery.of(context).size.width,
        margin: widget.isReply
            ? const EdgeInsets.only(top: 8)
            : const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isReply
              ? const Color(0xFF2C2F3E)
              : const Color(0xFF333645),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Display user image or a default icon if userImageUrl is not provided
                widget.userImageUrl.isNotEmpty
                    ? CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(widget.userImageUrl),
                      )
                    : SvgPicture.asset(
                        'assets/icons/circle-user.svg', // Default icon
                        height: 30,
                        width: 30,
                        color: Colors.grey,
                      ),
                const SizedBox(width: 10),
                Text(
                  userFullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Display rating as stars or a number (only for non-replies)
                if (!widget.isReply) ...[
                  const Icon(
                    Icons.star,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${widget.rating} star${widget.rating != 1 ? 's' : ''}",
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.review,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.dateTime,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w300,
              ),
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
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            if (showReplyContainer) ReplyReview(reviewID: widget.reviewId),
          ],
        ),
      ),
    );
  }
}
