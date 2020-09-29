import 'package:cloud_firestore/cloud_firestore.dart';

Firestore firestore = Firestore.instance;

Stream<QuerySnapshot> getChatMessage(
  currentUserId,
  currentUserName,
  toUserId,
) {
  return firestore
      .collection('chat')
      .document(currentUserId)
      .collection(currentUserName)
      .document(toUserId)
      .collection(toUserId)
      .orderBy('timestamp', descending: true)
      .snapshots();
}

Future<void> createChat(
    currentUserId, currentUserName, toUserId, toUserName, message) async {
  await firestore
      .collection('chat')
      .document(currentUserId)
      .collection(currentUserName)
      .document(toUserId)
      .collection(toUserName)
      .add({
    'message': message,
    'author': true,
    'timestamp': Timestamp.now(),
    'authorName': currentUserName,
  });
  await firestore
      .collection('chat')
      .document(toUserId)
      .collection(toUserName)
      .document(currentUserId)
      .collection(currentUserName)
      .add({
    'message': message,
    'author': false,
    'timestamp': Timestamp.now(),
    'authorName': currentUserName,
  });

  await firestore
      .collection('chatlist')
      .document(currentUserId)
      .collection(currentUserName)
      .document(toUserId)
      .setData({
    'name': toUserName,
    'timestamp': Timestamp.now(),
    'lastmessage': message,
  });
  await firestore
      .collection('chatlist')
      .document(toUserId)
      .collection(toUserName)
      .document(currentUserId)
      .setData({
    'name': currentUserName,
    'timestamp': Timestamp.now(),
    'lastmessage': message,
  });
}
