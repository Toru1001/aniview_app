import 'package:aniview_app/accountPages/forgotPassPage.dart';
import 'package:aniview_app/accountPages/signupPage.dart';
import 'package:aniview_app/firebase_auth_implementation/auth.dart';
import 'package:aniview_app/pages/MyHomePage.dart';
import 'package:aniview_app/pages/onBoarding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  bool _passwordVisible = false;
  final Auth _auth = Auth();

 var _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xFFFCCF31),
            Color(0xFFF55555),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,)  
        ),
        child: ListView(
          children: [
            login_Hero(),
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  const Text('Sign In',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 255, 255, 255)
                ),
                ),
                  Login_Form(),
                  const SizedBox(height: 20),
                  signin_Button(),
                const SizedBox(
                  height: 25,
                ),
                signInWith(),
                const SizedBox(
                  height: 50,
                ),
                footerOptions()
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
            child: InkWell(
                onTap: (){
                Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignUpPage()),
        );
                },
                child: const Text('Create Account',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                  decorationThickness: 1.5,
                ),
                
                )
                ),
            
          );
  }

  Column signInWith() {
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
            "Sign In with",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white, 
            ),
          ),
          Expanded(
            child: Divider(
              color: Color.fromARGB(255, 239, 239, 239), 
              thickness: .7,       
              indent: 10,         
            ),
          ),
          ],
      ),

      const SizedBox(height: 25),
              Container(
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ElevatedButton(
                  onPressed: () {
                  },
                  style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255), 
                  shadowColor: const Color.fromARGB(255, 255, 255, 255), 
                  padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  ),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(200), 
                  side: const BorderSide(
                  color: Colors.white, 
                  width: 2.0,
                  ),
                ),
              ),
                  child: const Image(image: AssetImage('assets/icons/google.png',
                  ))
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text('Google',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500
              ),
              ),
                ],
              );
  }

  Container signin_Button() {
    return Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _signIn();
                  },
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, 
                  shadowColor: Colors.transparent, 
                  padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50), 
                  side: const BorderSide(
                  color: Colors.white, 
                  width: 2.0,
                  ),
                ),
              ),
                  child: const Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                ),
                
              );
  }

  Column Login_Form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                const SizedBox(
                  height: 25,
                ),
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
                        bottomRight: Radius.circular(12)
                      ),
                      borderSide: BorderSide.none, 
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12)
                      ),
                      borderSide: BorderSide(color: Colors.orange, width: 2.0),
                    ),
                  ),
                  style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  ),

                const SizedBox(height: 25),
                
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 134, 91, 0).withOpacity(0.5),
                    hintText: 'Password',
                    hintStyle: const TextStyle(color:Color.fromARGB(135, 238, 238, 238)),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
      topLeft: Radius.circular(12),
      bottomRight: Radius.circular(12)
    ),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(12),
      bottomRight: Radius.circular(12)
    ),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0),
                    ),
                    suffixIcon: IconButton(
                      icon:  Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility, color: Color.fromARGB(135, 238, 238, 238)),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                ),
                SizedBox(height: 20,),
                 InkWell(
                onTap: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) {
                        return ForgotPassPage();
                      },),);
                },
                child: const Text('Forgot Password?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                )
                ),
                  ],
                );
  }

  Container login_Hero() {
    return Container(
            height: 150,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset('assets/icons/logoHat.png',
              alignment: Alignment(0.7, 0),
              ),
            ),
          );
  }
  
  Future<void> _signIn() async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (result != null) {
        var userRef = FirebaseFirestore.instance.collection('users').doc(result.uid);
        var userDoc = await userRef.get();
        if (userDoc.exists) {
          var firstSignIn = userDoc.data()?['firstSignIn'] ?? false;

          if (firstSignIn) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OnBoarding()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: "User data not found",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.SNACKBAR,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Incorrect Username or Password",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: const Color.fromARGB(157, 0, 0, 0),
          gravity: ToastGravity.SNACKBAR,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }


  
}