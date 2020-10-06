import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:howdy/modals/constants.dart';
import 'package:howdy/modals/user.dart';
import 'package:howdy/pages/chatroom.dart';
import 'package:howdy/services/chat_service.dart';
import 'package:howdy/services/color_service.dart';
import 'package:howdy/services/user_service.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Stream<QuerySnapshot> chatList;
  String currentUserName;
  String currentUserId;
  ChatService chatService = ChatService();

  goToChat({name, id, userId}) {
    User user = Provider.of<UserService>(context).user;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoom(
          currentUserId: user.uid,
          currentUserName: currentUserName,
          toUserId: userId,
          toUserName: name,
          chatId: id,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color = Provider.of<ColorService>(context, listen: false);
    User user = Provider.of<UserService>(context).user;

    if (user.uid == null) {
      return Center(
          child: Text('Log in to see your chat',
              style: TextStyle(color: color.secondaryColor, fontSize: 20)));
    } else {
      return StreamBuilder(
        stream: chatService.getChatList(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(backgroundColor: purple),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              String name;
              String userId;
              String id = snapshot.data.documents[index].documentID;
              List<dynamic> membersName =
                  snapshot.data.documents[index].data['membersName'];
              List<dynamic> membersId =
                  snapshot.data.documents[index].data['membersId'];

              if (membersName[0] == user.name) {
                name = membersName[1];
                userId = membersId[1];
              } else {
                name = membersName[0];
                userId = membersId[0];
              }
              String message =
                  snapshot.data.documents[index].data['lastMessage'];

              return Card(
                color: color.primaryColor,
                child: ListTile(
                  title: Text(
                    name,
                    style: TextStyle(
                      color: color.secondaryColor,
                      fontSize: 30,
                    ),
                  ),
                  subtitle: Text(
                    message,
                    style: TextStyle(
                      color: color.secondaryColor,
                      fontSize: 18,
                    ),
                  ),
                  onTap: () => goToChat(
                    name: name,
                    id: id,
                    userId: userId,
                  ),
                ),
                elevation: 0,
              );
            },
          );
        },
      );
    }
  }
}
