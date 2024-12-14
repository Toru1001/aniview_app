import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddReviewModal extends StatefulWidget {
  final String img;
  final String title;
  final String id;
  final String genre;

  const AddReviewModal(
      {Key? key,
      required this.img,
      required this.title,
      required this.id,
      required this.genre})
      : super(key: key);

  @override
  State<AddReviewModal> createState() => _AddReviewModalState();
}

class _AddReviewModalState extends State<AddReviewModal> {
  int _rating = 0;
  TextEditingController _reviewController = TextEditingController();

  Future<void> _saveReview() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        await FirebaseFirestore.instance.collection('reviews').add({
          'animeId': widget.id,
          'date': Timestamp.now(),
          'imgUrl': widget.img,
          'rating': _rating,
          'review': _reviewController.text,
          'title': widget.title,
          'userId': currentUser.uid, // Store the userId
        });

        print("Review saved successfully!");

        // Show a snackbar to inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Review added successfully!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.greenAccent,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pop(context); // Close the modal
      }
    } catch (e) {
      print("Error saving review: $e");
      // Show an error snackbar if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add review. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: FractionallySizedBox(
        heightFactor: 0.8,
        widthFactor: 1,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Section
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
                      'Review',
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
                        _saveReview(); // Call the save function
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
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Image.network(
                          widget.img,
                          height: 150,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 25,
                              ),
                            ),
                            Text(
                              widget.genre,
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            )
                          ],
                        )
                      ],
                    )),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rate',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: index < _rating
                                    ? Colors.redAccent
                                    : Colors.grey,
                                size: 50,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const Divider(
                      thickness: .5,
                      color: Colors.grey,
                      height: 30,
                    ),
                    const Text(
                      'Add Review',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 300,
                      padding:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 21, 21, 33),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _reviewController,
                        decoration: InputDecoration(
                          hintText: 'Write a reply...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.white),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
