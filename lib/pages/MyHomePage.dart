import 'package:aniview_app/accountPages/loginPage.dart';
import 'package:aniview_app/pages/subpages/home.dart';
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
    const Center(child: Text('Search Page', style: TextStyle(color: Colors.white))),
    const Center(child: Text('My Watchlist Page', style: TextStyle(color: Colors.white))),
    const Center(child: Text('Profile Page', style: TextStyle(color: Colors.white))),
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
      appBar: appBar(context),
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
            // Show the text next to the icon when selected
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

AppBar appBar(BuildContext context) {
  return AppBar(
    backgroundColor: const Color.fromARGB(255, 21, 21, 33),
    title: Image.asset(
      'assets/icons/ThinBorderLogo.png',
      width: 150,
      height: 150,
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
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.logout_rounded,
            size: 28,
          ),
        ),
      ),
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
