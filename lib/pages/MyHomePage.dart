import 'package:aniview_app/pages/subpages/home.dart';
import 'package:aniview_app/pages/subpages/my_watchlist.dart';
import 'package:aniview_app/pages/subpages/notifications.dart';
import 'package:aniview_app/pages/subpages/profile.dart';
import 'package:aniview_app/pages/subpages/search.dart';
import 'package:aniview_app/widgets/appBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyHomePage extends StatefulWidget {
  int currentIndex;
    MyHomePage({
    Key? key,
    this.currentIndex = 0
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with RouteAware {
  bool _hasUnreadNotifications = false;

  final List<Widget> _pages = [
    const Home(),
    const SearchPage(),
    const MyWatchlist(),
    const ProfilePage(),
  ];

  @override
  void didPopNext() {
    super.didPopNext();
    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      widget.currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkUnreadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201F31),
      appBar: appBar(),
      body: IndexedStack(
        index: widget.currentIndex,
        children: _pages,
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
    final bool isSelected = widget.currentIndex == index;
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

  AppBar appBar(){
  return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color.fromARGB(255, 21, 21, 33),
      title: Image.asset(
        'assets/icons/Final_Logo.png',
        width: 120,
        height: 120,
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Notifications()),
            );
          },
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                alignment: Alignment.center,
                width: 37,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 21, 21, 33),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications,
                  size: 28,
                  color: Colors.white70,
                ),
              ),
              if (_hasUnreadNotifications)
                Positioned(
                  top: 11,
                  right: 15,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _checkUnreadNotifications() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          var notifications = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('notifications')
              .where('isOpened', isEqualTo: false)
              .get();

          setState(() {
            _hasUnreadNotifications = notifications.docs.isNotEmpty;
          });
        }
      }
    } catch (e) {
      print("Error checking notifications: $e");
    }
  }
}
