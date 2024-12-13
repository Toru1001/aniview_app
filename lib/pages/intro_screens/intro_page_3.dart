import 'package:flutter/material.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF201F31),
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFF201F31),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: const Color(0xFF201F31),
                          width: 5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[800],
                        child: Icon(
                          Icons.person,
                          color: Colors.grey[400],
                          size: 100,
                        ),
                      ),
                    ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Select Profile Picture',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent),
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
