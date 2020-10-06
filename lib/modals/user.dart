import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final String email;
  final String uid;
  final String profilePicture;
  final Timestamp timestamp;
  User({
    this.name,
    this.email,
    this.uid,
    this.profilePicture,
    this.timestamp,
  });
  factory User.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data;
    return User(
      name: data['name'],
      email: data['email'],
      uid: data['id'],
      profilePicture: data['profilePicture'],
      timestamp: data['timestamp'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'email': this.email,
      'id': this.uid,
      'profilePicture': this.profilePicture,
      'timestamp': this.timestamp,
    };
  }
}
