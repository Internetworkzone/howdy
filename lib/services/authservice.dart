import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:howdy/modals/constants.dart';

class CurrentUser extends ChangeNotifier {
  CurrentUser({this.userid});
  String userid;
  String helo;
  String currentUserId;

  getCurrentUserDetails() {
    firestore
        .collection('users')
        .document(userid)
        .get()
        .then((DocumentSnapshot doc) {
      helo = doc.data['name'];
      currentUserId = doc.data['id'].toString();
    });
  }
}

class Authservice extends ChangeNotifier {
  final auth = FirebaseAuth.instance;

  CurrentUser loggedInUser(FirebaseUser user) {
    return user == null ? null : CurrentUser(userid: user.uid);
  }

  Stream<CurrentUser> get onAuthChange {
    return auth.onAuthStateChanged.map(loggedInUser);
  }

  Future<CurrentUser> signUp({email, password}) async {
    final authResult = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return loggedInUser(authResult.user);
  }

  Future<CurrentUser> signIn({email, password}) async {
    final authResult =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    return loggedInUser(authResult.user);
  }

  Future<void> signOut() {
    return auth.signOut();
  }
}
