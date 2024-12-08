import 'package:aniview_app/widgets/reply_review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ReviewWidget extends StatefulWidget {
  final String username;
  final int rating;
  final String comment;
  final String dateTime;
  final bool isReply;

  const ReviewWidget({
    Key? key,
    required this.username,
    this.rating = 0,
    required this.comment,
    required this.dateTime,
    this.isReply = false,
  }) : super(key: key);

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  bool showReplyContainer = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isReply ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: widget.isReply ? MediaQuery.of(context).size.width * 0.8 : MediaQuery.of(context).size.width,
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
                Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/circle-user.svg',
                    height: 30,
                    width: 30,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!widget.isReply) ...[
                  const Icon(
                    Icons.star,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${widget.rating} star",
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
              widget.comment,
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
              if (showReplyContainer) const ReplyReview(),
          ],
        ),
      ),
    );
  }
}
