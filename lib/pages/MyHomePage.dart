import 'package:aniview_app/accountPages/loginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      );
    
  }
}

AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text('Aniview',
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
            signOut(context);
          },
          
        child: Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        width: 37,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Icon(Icons.logout_rounded,
        size: 28,
        )
      ),
        )
        
      ],
      
    );
    
  }

  void signOut(BuildContext context) {
  FirebaseAuth.instance.signOut();
  Fluttertoast.showToast(
      msg: "Account Logged out Successfully",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
    );
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const loginPage()),
  );
}

 
