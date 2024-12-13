import 'package:aniview_app/widgets/changePic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileModal extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String imgUrl;
  final Function() onProfileUpdated;

  const EditProfileModal({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.imgUrl,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.firstName;
    _lastNameController.text = widget.lastName;
    _usernameController.text = widget.username;
    _emailController.text = widget.email;
    selectedImage = widget.imgUrl;
  }

  Future<void> _saveProfile() async {
    final String newFirstName = _firstNameController.text.isNotEmpty
        ? _firstNameController.text
        : widget.firstName;
    final String newLastName = _lastNameController.text.isNotEmpty
        ? _lastNameController.text
        : widget.lastName;
    final String newUsername = _usernameController.text.isNotEmpty
        ? _usernameController.text
        : widget.username;
    final String newEmail =
        _emailController.text.isNotEmpty ? _emailController.text : widget.email;

    final bool confirmSave = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Changes'),
              content: const Text('Are you sure you want to save the changes?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmSave) {
      return;
    }

    try {
      final user = _auth.currentUser;

      if (newEmail != widget.email) {
        final cred = EmailAuthProvider.credential(
          email: user?.email ?? '',
          password:
              'userPassword', 
        );

        await user?.reauthenticateWithCredential(cred);
        await user?.updateEmail(newEmail);
      }

      await _firestore.collection('users').doc(user?.uid).update({
        'firstName': newFirstName,
        'lastName': newLastName,
        'username': newUsername,
        'imageUrl':
            selectedImage ?? widget.imgUrl, 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      widget.onProfileUpdated();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    ),
                  ),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _saveProfile();
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
            Container(
              width: double.infinity,
              height: 130,
              color: const Color.fromARGB(255, 21, 21, 33),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
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
                        backgroundImage: selectedImage != null
                            ? NetworkImage(selectedImage!)
                            : null,
                        child: selectedImage == null
                            ? Icon(
                                Icons.person,
                                color: Colors.grey[400],
                                size: 60,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedImage = imageUrls[index];
                              });
                            },
                            child: Container(
                              width:
                                  95, // Same width as the main image's CircleAvatar
                              height:
                                  95, // Same height as the main image's CircleAvatar
                              margin: const EdgeInsets.symmetric(horizontal: 5),
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
                                radius:
                                    40,
                                backgroundImage: NetworkImage(imageUrls[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField(
                      'First Name', widget.firstName, _firstNameController),
                  const SizedBox(height: 10),
                  _buildField(
                      'Last Name', widget.lastName, _lastNameController),
                  const SizedBox(height: 10),
                  _buildField('Username', widget.username, _usernameController,
                      prefixIcon: Icons.alternate_email),
                  const SizedBox(height: 10),
                  _buildField('Email', widget.email, _emailController,
                      readOnly: true),
                  const SizedBox(height: 10),
                  const Text(
                    "Password",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Change Password Functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF201F31),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(
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
          ],
        ),
      ),
    );
  }

  Widget _buildField(
      String label, String initialValue, TextEditingController _controller,
      {IconData? prefixIcon, final bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 50,
          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 21, 21, 33),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: initialValue,
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, size: 20, color: Colors.grey)
                  : null,
            ),
            style: TextStyle(color: readOnly ? Colors.grey : Colors.white),
          ),
        ),
      ],
    );
  }
}
