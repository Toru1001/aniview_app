import 'package:aniview_app/pages/MyHomePage.dart';
import 'package:aniview_app/pages/intro_screens/intro_page_1.dart';
import 'package:aniview_app/pages/intro_screens/intro_page_4.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final PageController _controller = PageController();
  final List<String> imageUrls = [
    'https://i.pinimg.com/736x/06/b8/45/06b8454a2ce7a8270c26ee70d0ebfd16.jpg',
    'https://i.pinimg.com/736x/8e/d8/28/8ed828d79c3ebe987177a16da535e9cb.jpg',
    'https://i.pinimg.com/736x/8c/08/bc/8c08bccd5c20fa27d0fb8300b29369fe.jpg',
    'https://i.pinimg.com/736x/1e/cf/aa/1ecfaa7ad81dffd2952321cdf3763725.jpg',
    'https://i.pinimg.com/736x/af/5c/0b/af5c0bff5273af1d8f944a3a6347d6a5.jpg',
    'https://i.pinimg.com/736x/2e/a2/68/2ea2683e67f28283431f5f9b8d0b2f8d.jpg',
    'https://i.pinimg.com/736x/6f/4e/ad/6f4eaddfb45810ecfbbefab432d77fd8.jpg',
    'https://i.pinimg.com/736x/68/df/3f/68df3f3cab27704fbd7dfd0edfbcda58.jpg',
  ];
  String? selectedImage;
  bool onLastPage = false;
  bool onPage3 = false;
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 3);
                onPage3 = (index == 2);
              });
            },
            children: [
              const IntroPage1(),
              page2(),
              page3(),
              const IntroPage4(),
            ],
          ),

          // Navigation Controls
          if (!onLastPage)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              alignment: const Alignment(0, 0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                      );
                    },
                    child: const Text(
                      'Back',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),

                  // Page Indicator
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 4,
                    effect: const ExpandingDotsEffect(
                      dotColor: Colors.grey,
                      activeDotColor: Colors.redAccent,
                      dotHeight: 15,
                      dotWidth: 15,
                      expansionFactor: 4,
                      spacing: 8,
                    ),
                  ),

                  if (onPage3)
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Color(0xFF201F31),
                              title: const Text('Confirm', style: TextStyle(color: Colors.white)),
                              content: const Text(
                                  'Do you want to save this information?', style: TextStyle(color: Colors.white)),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: const Text('Save', style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          if (_firstnameController.text.isEmpty ||
                              _lastnameController.text.isEmpty ||
                              _usernameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please fill in all the required fields.',
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          } else {
                            updateUserData();
                          }
                        }
                      },
                      child: const Text(
                        'Next',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        );
                      },
                      child: const Text(
                        'Next',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                ],
              ),
            ),

          // Done Button (on the last page at the bottom)
          if (onLastPage)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const MyHomePage();
                  }));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(
                      color: Colors.redAccent,
                      width: 2,
                    ),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> updateUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User is not logged in');
      }

      final username = _usernameController.text;

      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Username already exists. Please choose another one.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userDoc.update({
        'firstName': _firstnameController.text.trim(),
        'lastName': _lastnameController.text.trim(),
        'username': _usernameController.text.trim(),
        'imageUrl': selectedImage,
        'firstSignIn': false,
      });

      print('User data updated successfully');
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    } catch (e) {
      print('Error updating user data: $e');
      throw Exception('Failed to update user data');
    }
  }

  Container page2() {
    return Container(
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      color: const Color(0xFF201F31),
      child: ListView(
        children: [
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
              const SizedBox(height: 20),
              const Text(
                'Personal Information',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent),
              ),
              const Text(
                "Let's set-up your account",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Text(
                "First Name",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 21, 21, 33),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _firstnameController,
                  decoration: const InputDecoration(
                    hintText: 'First Name',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Last Name",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 21, 21, 33),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _lastnameController,
                  decoration: const InputDecoration(
                    hintText: 'Last Name',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Username",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Container(
                height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 21, 21, 33),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.alternate_email,
                      size: 35,
                      color: Colors.grey,
                    ),
                    hintText: 'Username',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }

  Container page3() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      color: const Color(0xFF201F31),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF201F31),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: Colors.grey.shade800,
                  width: 5,
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[800],
                backgroundImage:
                    selectedImage != null ? NetworkImage(selectedImage!) : null,
                child: selectedImage == null
                    ? Icon(
                        Icons.person,
                        color: Colors.grey[400],
                        size: 100,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Profile Picture',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 5,
              ),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImage = imageUrls[index];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedImage == imageUrls[index]
                            ? Colors.red
                            : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(imageUrls[index]),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
