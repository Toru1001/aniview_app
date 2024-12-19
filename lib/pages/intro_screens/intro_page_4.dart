import 'package:flutter/material.dart';

class IntroPage4 extends StatelessWidget {
  const IntroPage4({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF201F31),
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/chika_thumbsup.png',
            height: 300,
            width: 300,
          ),
          SizedBox(height: 20,),
          Text(
            "You're all set",
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.redAccent),
          ),
          Text(
            "Have fun!",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w400, color: Colors.grey),
          )
        ],
      )),
    );
  }
}