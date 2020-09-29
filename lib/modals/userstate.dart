import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  String currentUserId;
  String currentUserName;
  String currentUserEmailId;
  FirebaseAuth auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;

  signout() async {
    await auth.signOut();
  }

  signUpUser({email, password, name}) async {
    try {
      final signupUser = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (signupUser.user.uid != null) {
        firestore.collection('users').document(signupUser.user.uid).setData({
          'id': signupUser.user.uid,
          'name': name,
          'email': email,
          'timestamp': Timestamp.now(),
        });
      }
    } catch (e) {}
  }

  signInUser({email, password}) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {}
  }

  getUserDetail() async {
    if (currentUserId != null && currentUserEmailId != null) {
      try {
        await firestore
            .collection('users')
            .document(currentUserId)
            .get()
            .then((DocumentSnapshot doc) {
          currentUserName = doc.data['name'];
          print(currentUserName);
          notifyListeners();
        });
      } catch (e) {}
    }
  }
}
