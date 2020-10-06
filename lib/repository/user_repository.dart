import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final Firestore firestore = Firestore.instance;

  Future<void> registerUser(
      Map<String, dynamic> userDetails, String uid) async {
    await firestore.collection('users').document(uid).setData(userDetails);
  }

  Future<DocumentSnapshot> getUserDetails(String uid) async {
    return await firestore.collection('users').document(uid).get();
  }

  Future<QuerySnapshot> getAllUsers() async {
    return await firestore.collection('users').getDocuments();
  }
}
