import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  User? getCurrentUser(){
    return _auth.currentUser;
  }
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email
      }, SetOptions(merge: true));
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuth Error: ${e.code} - ${e.message}");
      throw Exception("Error: ${e.message}");
    }
  }

  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuth Error: ${e.code} - ${e.message}");
      throw Exception("Error: ${e.message}");
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("SignOut Error: $e");
    }
  }
}