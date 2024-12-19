import 'package:aniview_app/accountPages/forgot_password.dart';
import 'package:aniview_app/accountPages/login_page.dart';
import 'package:aniview_app/accountPages/sign_up.dart';
import 'package:aniview_app/firebase_auth_implementation/auth.dart';
import 'package:aniview_app/pages/MyHomePage.dart';
import 'package:aniview_app/pages/onBoarding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool _passwordVisible = false;
  final Auth _auth = Auth();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201F31),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          padding: EdgeInsets.only(top: 150),
          children: [Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              login_Hero(),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Forgot Password',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Enter your details below',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 21, 21, 33),
                        hintText: 'Email Address',
                        hintStyle: TextStyle(color: Color.fromARGB(135, 238, 238, 238)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          passwordReset();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        ),
                        child: const Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Have an account?",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => const LogInPage()));
                    },
                    child: const Text(
                      "Sign in",
                      style: TextStyle(color: Colors.redAccent, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Container login_Hero() {
    return Container(
      height: 125,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset('assets/icons/Final_Logo.png'),
      ),
    );
  }

  Future<void> passwordReset() async {
  try {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: _emailController.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            "If an account exists, a password reset email has been sent.",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 3),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogInPage()),
    );
  } on FirebaseAuthException catch (e) {
    String errorMessage;
    if (e.code == 'user-not-found') {
      errorMessage = 'No account found with this email address.';
    } else if (e.code == 'invalid-email') {
      errorMessage = 'The email address is invalid.';
    } else {
      errorMessage = 'An error occurred: ${e.message}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMessage,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey,
        duration: Duration(seconds: 3),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "An unexpected error occurred: $e",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey,
        duration: Duration(seconds: 3),
      ),
    );
  }
}


}
