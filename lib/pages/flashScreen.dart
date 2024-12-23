import 'package:aniview_app/accountPages/login_page.dart';
import 'package:aniview_app/pages/MyHomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Flashscreen extends StatefulWidget {
  const Flashscreen({super.key});

  @override
  State<Flashscreen> createState() => _FlashscreenState();
}

class _FlashscreenState extends State<Flashscreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Future.delayed(const Duration(seconds: 5), () {
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => LogInPage()),);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: splashScreen(),
    );
  }

  Container splashScreen() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF201F31),
            const Color.fromARGB(255, 21, 21, 33),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/icons/Final_Logo.png',
          width: 250, 
          height: 250,
  ),
        ],
      ),
    );
  }
}
