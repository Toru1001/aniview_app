import 'package:flutter/material.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF201F31),
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/helloLuffy.png',
            height: 300,
            width: 300,
          ),
          SizedBox(height: 20,),
          Text(
            'Welcome to Aniview!',
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.redAccent),
          ),
          Text(
            "Let's Get Started",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w400, color: Colors.grey),
          )
        ],
      )),
    );
  }
}
