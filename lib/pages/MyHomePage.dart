import 'package:aniview_app/accountPages/loginPage.dart';
import 'package:aniview_app/pages/subpages/home.dart';
import 'package:aniview_app/pages/subpages/profile.dart';
import 'package:aniview_app/pages/subpages/search.dart';
import 'package:aniview_app/widgets/appBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const Home(),
    const SearchPage(),
    const Center(child: Text('My Watchlist Page', style: TextStyle(color: Colors.white))),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201F31),
      appBar: const AniviewAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomAppBar(
          color: const Color.fromARGB(255, 21, 21, 33),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.search, 'Search', 1),
              _buildNavItem(Icons.video_library_rounded, 'Library', 2),
              _buildNavItem(Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 48, 47, 47) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.redAccent : Colors.white,
              size: 30,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.redAccent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
