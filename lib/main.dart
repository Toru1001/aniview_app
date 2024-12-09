import 'package:aniview_app/accountPages/loginPage.dart';
import 'package:aniview_app/accountPages/signupPage.dart';
import 'package:aniview_app/pages/MyHomePage.dart';
import 'package:aniview_app/pages/flashScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_auth_implementation/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Flashscreen(),
    );
  }
}
