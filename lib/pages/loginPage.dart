import 'package:flutter/material.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: ListView(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/icons/hdluffy.png'),
                  fit: BoxFit.fitHeight,
                  alignment: Alignment(1, 0),
                  //colorFilter: ColorFilter.mode(Color.fromARGB(255, 255, 122, 40).withOpacity(.1), BlendMode.darken)
                  ),
                  
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  
                  ),
              gradient: LinearGradient(colors: [
            Color(0xFFFCCF31),
            Color(0xFFF55555),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,)  
              ),
              
              child: Padding(
                padding: const EdgeInsets.all(60.0),
                child: Image.asset('assets/icons/PlainLogo.png',
                ),
              ),
            ),
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
                    height: 20,
                  ),
                  const Text('Sign In',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black
                  ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: const Color.fromARGB(255, 237, 237, 237).withOpacity(0.5),
    hintText: 'Email Address',
    hintStyle: const TextStyle(color: Color.fromARGB(137, 101, 101, 101)),
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
      borderSide: BorderSide(color: Colors.orange, width: 2.0), // Border color when focused with thicker width
    ),
  ),
  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
),

                  const SizedBox(height: 16),
                  
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 237, 237, 237).withOpacity(0.5),
                      hintText: 'Password',
                      hintStyle: const TextStyle(color:Color.fromARGB(137, 101, 101, 101)),
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
                        icon: const Icon(Icons.visibility, color: Color.fromARGB(137, 82, 82, 82)),
                        onPressed: () {

                        },
                      ),
                    ),
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        
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
                ),
                const SizedBox(
                  height: 20,
                ),
                const Row(
          children: [
            Expanded(
              child: Divider(
                color: Colors.grey, // Line color
                thickness: 1,       // Line thickness
                endIndent: 10,      // Space between line and text
              ),
            ),
            Text(
              "Sign In With",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54, // Text color
              ),
            ),
            Expanded(
              child: Divider(
                color: Colors.grey, 
                thickness: .7,       
                indent: 10,         
              ),
            ),
          ],
        ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}