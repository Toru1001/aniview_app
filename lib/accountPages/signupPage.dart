import 'package:aniview_app/accountPages/loginPage.dart';
import 'package:aniview_app/firebase_auth_implementation/auth.dart';
import 'package:aniview_app/pages/MyHomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>(); 
  final Auth _auth = Auth();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _reconfirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _repasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _reconfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFCCF31),
              Color(0xFFF55555),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: ListView(
          children: [
            signUpHero(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: SignUpForm(),
                  ),
                  const SizedBox(height: 20),
                  signUpButton(),
                  const SizedBox(height: 25),
                  signUpWith(),
                  const SizedBox(height: 20),
                  footerOptions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container footerOptions() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => loginPage()),
            );
          },
          child: const Text(
            'Already have an account? Sign In',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
              decorationThickness: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Column signUpWith() {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(
              child: Divider(
                color: Color.fromARGB(255, 239, 239, 239),
                thickness: 1,
                endIndent: 10,
              ),
            ),
            Text(
              "Sign Up with",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Divider(
                color: Color.fromARGB(255, 239, 239, 239),
                thickness: 0.7,
                indent: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Container(
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              shadowColor: const Color.fromARGB(255, 255, 255, 255),
              padding: const EdgeInsets.symmetric(vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(300),
                side: const BorderSide(
                  color: Colors.white,
                  width: 2.0,
                ),
              ),
            ),
            child: const Image(
              image: AssetImage('assets/icons/google.png'),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Google',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Container signUpButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _signUp();
            
          } else {
            print('Form is invalid');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: const BorderSide(
              color: Colors.white,
              width: 2.0,
            ),
          ),
        ),
        child: const Text(
          'SIGN UP',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Column SignUpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromARGB(255, 134, 91, 0).withOpacity(0.5),
            hintText: 'Email Address',
            hintStyle: const TextStyle(color: Color.fromARGB(135, 238, 238, 238)),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              borderSide: BorderSide.none,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              borderSide: BorderSide(color: Colors.orange, width: 2.0),
            ),
          ),
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required';
            } else if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$").hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 25),
        TextFormField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromARGB(255, 134, 91, 0).withOpacity(0.5),
            hintText: 'Password',
            hintStyle: const TextStyle(color: Color.fromARGB(135, 238, 238, 238)),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              borderSide: BorderSide.none,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              borderSide: BorderSide(color: Colors.orange, width: 2.0),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
          ),
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            } else if (value.length < 6) {
              return 'Password must be at least 6 characters long';
            }
            return null;
          },
        ),
        const SizedBox(height: 25),
        TextFormField(
          controller: _reconfirmPasswordController,
          obscureText: !_repasswordVisible,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromARGB(255, 134, 91, 0).withOpacity(0.5),
            hintText: 'Confirm Password',
            hintStyle: const TextStyle(color: Color.fromARGB(135, 238, 238, 238)),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              borderSide: BorderSide.none,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              borderSide: BorderSide(color: Colors.orange, width: 2.0),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _repasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _repasswordVisible = !_repasswordVisible;
                });
              },
            ),
          ),
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Confirm Password is required';
            } else if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _signUp() async {
    try {
      final User? user = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null) {
        Fluttertoast.showToast(
          msg: "Account Created Successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => loginPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

 Container signUpHero() {
    return Container(
      height: 150,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset(
          'assets/icons/logoHat.png',
          alignment: const Alignment(0.7, 0),
        ),
      ),
    );
 }
}