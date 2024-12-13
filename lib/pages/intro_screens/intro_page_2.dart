import 'package:flutter/material.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      width: double.infinity,
      color: Color(0xFF201F31),
      child: ListView(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              child: Center(
                child: Image.asset(
                  'assets/icons/yourname.png',
                  height: 300,
                  width: 300,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Personal Information',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent),
            ),
            Text(
              "Let's set-up your account",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "First Name",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 21, 21, 33),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'First Name',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Last Name",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 21, 21, 33),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Last Name',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Username",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 21, 21, 33),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.alternate_email,
                    size: 35,
                  ),
                  hintText: 'Username',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ]),
    );
  }
}
