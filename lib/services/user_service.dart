import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:howdy/modals/user.dart';
import 'package:howdy/repository/user_repository.dart';

class UserService extends ChangeNotifier {
  User user;
  User peerUser;
  UserRepository userRepository = UserRepository();

  Future<void> registerNewUser(FirebaseUser firebaseUser, String name) async {
    user = User(
      name: name,
      email: firebaseUser.email,
      uid: firebaseUser.uid,
      profilePicture: firebaseUser.photoUrl,
      timestamp: Timestamp.now(),
    );

    await userRepository.registerUser(user.toMap(), user.uid);
  }

  Future<User> updateUser(String uid) async {
    DocumentSnapshot doc = await userRepository.getUserDetails(uid);
    user = User.fromFirestore(doc);
    notifyListeners();

    return user;
  }

  Future<QuerySnapshot> getUsersList() async {
    return await userRepository.getAllUsers();
  }
}
