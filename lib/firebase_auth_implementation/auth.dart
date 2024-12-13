import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in user
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print('An error occurred: $e');
    }
    return null;
  }

  // Create user and store default values in Firestore
  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'firstName': null,
          'lastName': null,
          'username': null,
          'imageUrl': null,
          'firstSignIn': true,
        });
      }

      return user;
    } catch (e) {
      print('An error occurred: $e');
    }
    return null;
  }
}
