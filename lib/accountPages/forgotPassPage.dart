import 'package:aniview_app/accountPages/loginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPassPage extends StatefulWidget {
   ForgotPassPage({super.key});
 

  @override
  State<ForgotPassPage> createState() => _forgotPassPageState();
}

class _forgotPassPageState extends State<ForgotPassPage> {
   final _emailForgotPassController = TextEditingController();

   @override
   void dispose(){
    _emailForgotPassController.dispose();
    super.dispose();
   }



Future<void> passwordReset() async {
  try {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: _emailForgotPassController.text.trim());

    Fluttertoast.showToast(
      msg: "If an account exists, a password reset email has been sent.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
    );
    Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => loginPage()),
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
    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
    );
  } catch (e) {
    Fluttertoast.showToast(
      msg: "An unexpected error occurred: $e",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
    );
  }
}


  @override
  Widget build(BuildContext context) {
    
    return  Scaffold(
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
              child: Container(
                height: 500,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    const Text('Forgot Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 255, 255, 255)
                  ),
                  ),
                  SizedBox(height: 50,),
                  Text('Enter email to send you a password reset link.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  ),
                    email_Form(),
                    reset_Button(),
                  const SizedBox(
                    height: 100,
                  ),
                  SignInOptions()
                  ],
                ),
                
              ),
            ),
          ],
        ),
      ),
      
    );
  }

  Container SignInOptions() {
    return Container(
            child: InkWell(
                onTap: (){
                  Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => loginPage()),
        );
                },
                child: const Text('Sign In',
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
                fontWeight: FontWeight.w200
              ),
              ),
                ],
              );
  }

  Container reset_Button() {
    return Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    passwordReset();
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
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                ),
                
              );
  }

  Column email_Form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                TextFormField(
                  controller: _emailForgotPassController,
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

                SizedBox(height: 15,),
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
}