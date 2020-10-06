import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:howdy/modals/chat.dart';

class ChatRepository {
  final Firestore _firestore = Firestore.instance;

  Future<void> sendMessage(String chatId, Chat message) async {
    await _firestore
        .collection('allChats')
        .document(chatId)
        .collection('chat')
        .add(message.toMap());
  }

  Future<void> updateChatDetails(
      String chatId, ChatDetails data, int chatLength) async {
    if (chatLength > 0) {
      await _firestore
          .collection('allChats')
          .document(chatId)
          .updateData(data.toMap());
    } else {
      await _firestore
          .collection('allChats')
          .document(chatId)
          .setData(data.toMap());
    }
  }

  Stream<QuerySnapshot> getChatList(uid) {
    return _firestore.collection('allChats').snapshots();
  }

  Stream<QuerySnapshot> getChatStream(String chatId) {
    return _firestore
        .collection('allChats')
        .document(chatId)
        .collection('chat')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
