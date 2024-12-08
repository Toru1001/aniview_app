import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ReplyReview extends StatelessWidget {
  const ReplyReview({Key? key}) : super(key: key);

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
          Container(
                    height: 35,
                    width: 35,
                    margin: EdgeInsets.only(top: 5),
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
          const Expanded(
            child: TextField(
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
            onPressed: () {
              // Handle sending the reply
            },
            icon: const Icon(Icons.send, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}
