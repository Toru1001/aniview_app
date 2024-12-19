import 'package:aniview_app/pages/subpages/notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AniviewAppBar extends StatefulWidget implements PreferredSizeWidget {
  const AniviewAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  _AniviewAppBarState createState() => _AniviewAppBarState();
}

class _AniviewAppBarState extends State<AniviewAppBar> {
  bool _hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    _checkUnreadNotifications();
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

  @override
  Widget build(BuildContext context) {
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
}
