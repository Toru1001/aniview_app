import 'package:firebase_auth/firebase_auth.dart';

class Auth{
  final FirebaseAuth _auth = FirebaseAuth.instance;
 
 Future<User?> signInWithEmailAndPassword({
  required String email,
  required String password,
}) async{
  try{
    UserCredential credential = await _auth.signInWithEmailAndPassword(
    email:email,
    password:password,
  );
  return credential.user;
  }catch (e){
    print('An Error occured');
  }
  return null;
  }


Future<User?> createUserWithEmailAndPassword({
  required String email,
  required String password,
}) async{
  try{
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
    email:email,
    password:password,
  );
  return credential.user;
  }catch (e){
    print('An Error occured');
  }
  return null;
  }
}
