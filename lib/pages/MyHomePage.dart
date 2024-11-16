import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      );
    
  }
}

AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text('Breakfast',
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      ),
      centerTitle: true,
      leading: GestureDetector(
        onTap: (){
          
        },
        child: Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10)
        ),
        child: SvgPicture.asset('assets/icons/angle-small-left.svg',
        height: 28,
        width: 28,
        ),
        )
        
      ),
      actions: [
        GestureDetector(
          onTap: () {

          },
        child: Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        width: 37,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10)
        ),
        child: SvgPicture.asset('assets/icons/menu-dots.svg',
        height: 28,
        width: 28,
        ),
      ),
        )
        
      ],
    );
  }