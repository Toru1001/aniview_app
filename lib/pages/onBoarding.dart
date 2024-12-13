import 'package:aniview_app/pages/MyHomePage.dart';
import 'package:aniview_app/pages/intro_screens/intro_page_1.dart';
import 'package:aniview_app/pages/intro_screens/intro_page_2.dart';
import 'package:aniview_app/pages/intro_screens/intro_page_3.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

PageController _controller = PageController();
bool onLastPage = false;

class _OnBoardingState extends State<OnBoarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [
              const IntroPage1(),
              const IntroPage2(),
              const IntroPage3(),
            ],
          ),
          Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              alignment: const Alignment(0, 0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {
                        _controller.previousPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn);
                      },
                      child: const Text(
                        'Back',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      )),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                    effect: const ExpandingDotsEffect(
                      dotColor: Colors.grey,
                      activeDotColor: Colors.redAccent,
                      dotHeight: 15,
                      dotWidth: 15,
                      expansionFactor: 4,
                      spacing: 8,
                    ),
                  ),
                  onLastPage
                      ? ElevatedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const MyHomePage();
                            }));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                color: Colors.redAccent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: const Text(
                            "Done",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            _controller.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn);
                          },
                          child: const Text(
                            'Next',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ))
                ],
              ))
        ],
      ),
    );
  }
}
