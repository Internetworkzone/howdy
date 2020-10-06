import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:howdy/modals/chat.dart';
import 'package:howdy/repository/chat_repository.dart';

Firestore firestore = Firestore.instance;

class ChatService {
  ChatRepository chatRepository = ChatRepository();
  Chat chatMessage;
  ChatDetails chatDetails;

  Future<void> createChat(Chat chat, int length) async {
    String chatId = chat.fromUserId.hashCode > chat.toUserId.hashCode
        ? '${chat.fromUserId}_${chat.toUserId}'
        : '${chat.toUserId}_${chat.fromUserId}';

    chatDetails = ChatDetails(
      lastMessage: chat.message,
      lastMessageTimestamp: Timestamp.now(),
      membersId: [chat.fromUserId, chat.toUserId],
      membersName: [chat.fromUserName, chat.toUserName],
    );

    chatRepository.updateChatDetails(
      chatId,
      chatDetails,
      length,
    );

    chatMessage = Chat(
      message: chat.message,
      fromUserId: chat.fromUserId,
      toUserId: chat.toUserId,
      fromUserName: chat.fromUserName,
      toUserName: chat.toUserName,
      replyTo: chat.replyTo,
      replyFor: chat.replyFor,
      type: chat.type,
      isReceived: false,
      isRead: false,
      timestamp: Timestamp.now(),
    );

    chatRepository.sendMessage(chatId, chatMessage);
  }

  Stream<QuerySnapshot> getChatList(uid) {
    return chatRepository.getChatList(uid);
  }

  Stream<QuerySnapshot> getChatMessages(fromUserId, toUserId) {
    String chatId = fromUserId.hashCode > toUserId.hashCode
        ? '${fromUserId}_$toUserId'
        : '${toUserId}_$fromUserId';

    return chatRepository.getChatStream(chatId);
  }
}
