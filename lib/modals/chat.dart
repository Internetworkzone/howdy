import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String message;
  final String fromUserId;
  final String toUserId;
  final String fromUserName;
  final String toUserName;
  final String replyTo;
  final String replyFor;
  final String type;
  final bool isRead;
  final bool isReceived;
  final Timestamp timestamp;

  Chat({
    this.message,
    this.fromUserId,
    this.toUserId,
    this.fromUserName,
    this.toUserName,
    this.replyTo,
    this.replyFor,
    this.type,
    this.isReceived,
    this.isRead,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': this.message,
      'fromUserId': this.fromUserId,
      'toUserId': this.toUserId,
      'fromUserName': this.fromUserName,
      'toUserName': this.toUserName,
      'replyTo': this.replyTo,
      'replyFor': this.replyFor,
      'type': this.type,
      'isReceived': this.isReceived,
      'isRead': this.isRead,
      'timestamp': this.timestamp,
    };
  }

  factory Chat.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data;
    return Chat(
      message: data['message'],
      fromUserId: data['fromUserId'],
      toUserId: data['toUserId'],
      fromUserName: data['fromUserName'],
      toUserName: data['toUserName'],
      replyTo: data['replyTo'],
      replyFor: data['replyFor'],
      type: data['type'],
      isReceived: data['isReceived'],
      isRead: data['isRead'],
      timestamp: data['timestamp'],
    );
  }
}

class ChatDetails {
  final String lastMessage;
  final Timestamp lastMessageTimestamp;
  final List<String> membersId;
  final List<String> membersName;
  final Map<String, int> unseenCounts;
  final Map<String, bool> isTyping;

  ChatDetails({
    this.lastMessage,
    this.membersId,
    this.membersName,
    this.lastMessageTimestamp,
    this.unseenCounts,
    this.isTyping,
  });

  factory ChatDetails.formFirestore(DocumentSnapshot doc) {
    var data = doc.data;
    return ChatDetails(
      lastMessage: data['lastMessage'],
      lastMessageTimestamp: data['lastMessageTimestamp'],
      membersId: data['members'],
      membersName: data['membersName'],
      unseenCounts: data['unseenCounts'],
      isTyping: data['isTyping'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'lastMessage': this.lastMessage,
      'lastMessageTimestamp': this.lastMessageTimestamp,
      'membersId': this.membersId,
      'membersName': this.membersName,
      'unseenCounts': this.unseenCounts,
      'isTyping': this.isTyping,
    };
  }
}
