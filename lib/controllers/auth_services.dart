import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
class AuthServices{
  final FirebaseAuth _auth = FirebaseAuth.instance;

/// sing up with email and password
Future<User?> signUp(String email, String password) async{
  try{
    UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return result.user;
  }catch(e){
    if (kDebugMode) {
      print("Sing up error: $e");
    }
    return null;
  }
}

/// sign in with email and password
Future<User?> signIn(String email, String password) async{
  try{
    UserCredential result =await _auth.signInWithEmailAndPassword(email:email, password: password);
    return result.user;
  }catch(e){
    if(kDebugMode){
      print("Sing in error: $e");
      return null;
    }
  }
  return null;
}

/// Sign out
Future<void> signOut() async{
  try{
   await _auth.signOut();
  }catch(e){
    if(kDebugMode){
      print("Sign out error: $e");
    }
  }
}

/// Get current user
User? getCurrentUser(){
  try{
    _auth.currentUser;
  }catch(e){
    if(kDebugMode){
      print("Get current user error: $e");
    }
  }
  return null;
}


}