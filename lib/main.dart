import 'package:aniview_app/accountPages/login_page.dart';
import 'package:aniview_app/pages/flashScreen.dart';
import 'package:flutter/material.dart';
import 'package:aniview_app/pages/subpages/home.dart';
import 'package:aniview_app/pages/subpages/my_watchlist.dart';
import 'package:aniview_app/pages/subpages/notifications.dart';
import 'package:aniview_app/pages/subpages/profile.dart';
import 'package:aniview_app/pages/subpages/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aniview App',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      home: const Flashscreen(),
    );
  }
}
