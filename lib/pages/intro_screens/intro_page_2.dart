import 'package:flutter/material.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF201F31),
      child: Center(
        child: Text('Page 2', style: TextStyle(color: Colors.white),),
      ),
    );
  }
}