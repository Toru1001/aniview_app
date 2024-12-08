
import 'package:aniview_app/accountPages/loginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AniviewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AniviewAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
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
              color: const Color.fromARGB(255, 21, 21, 33),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications,
              size: 28,
              color: Colors.white70,
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
}
