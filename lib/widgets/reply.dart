import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ReplyWidget extends StatelessWidget {
  final String replyText;
  final String userFirstName;
  final String userLastName;
  final String userImageUrl;
  final String dateTime;

  const ReplyWidget({
    Key? key,
    required this.replyText,
    required this.userFirstName,
    required this.userLastName,
    required this.userImageUrl,
    required this.dateTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String userFullName = '$userFirstName $userLastName';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 38, 40, 53),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              userImageUrl.isNotEmpty
                  ? CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(userImageUrl),
                    )
                  : SvgPicture.asset(
                      'assets/icons/circle-user.svg',
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
            ],
          ),
          const SizedBox(height: 10),
          Text(
            replyText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            dateTime,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
