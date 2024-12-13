import 'package:flutter/material.dart';

class EditProfileModal extends StatefulWidget {
  const EditProfileModal({super.key});

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 19,
                        color: Colors.grey,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  GestureDetector(
                    onTap: () {
                      // Function
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 19,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 130,
              color: const Color.fromARGB(255, 21, 21, 33),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF201F31),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: const Color(0xFF201F31),
                          width: 5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[800],
                        child: Icon(
                          Icons.person,
                          color: Colors.grey[400],
                          size: 60,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Select Picture',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 25,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.redAccent),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          prefixIcon: Icon(Icons.alternate_email, size: 35,),
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
                    Text(
                      "Email",
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
                          hintText: 'Email',
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
                      "Password",
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF201F31),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.redAccent,
                            width: 2, 
                          ),
                        ),
                      ),
                      child: const Text(
                        "Change Password",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
