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
    User user = Provider.of<UserService>(context, listen: false).user;
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

  delay() async {
    await Future.delayed(Duration(seconds: 5));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color = Provider.of<ColorService>(context, listen: false);
    User user = Provider.of<UserService>(context).user;

    if (user == null) {
      delay();
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return StreamBuilder(
        stream: chatService.getChatList(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(backgroundColor: purple),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.only(top: 10),
            itemCount: snapshot.data.documents.length,
            separatorBuilder: (_, ind) => Divider(
              thickness: 1,
              indent: MediaQuery.of(context).size.width / 4.3,
            ),
            itemBuilder: (context, index) {
              String name = '';
              String userId = '';
              String id = snapshot.data.documents[index].documentID;
              List<dynamic> membersName =
                  snapshot.data.documents[index].data['membersName'];
              List<dynamic> membersId =
                  snapshot.data.documents[index].data['membersId'];

              if (membersName[0] == user.name) {
                name = membersName[1] ?? '';
                userId = membersId[1];
              } else {
                name = membersName[0] ?? '';
                userId = membersId[0];
              }
              String message =
                  snapshot.data.documents[index].data['lastMessage'];

              return Card(
                elevation: 0,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: white,
                          size: 65,
                        ),
                      ),
                    ),
                    Flexible(
                      child: ListTile(
                        tileColor: white,
                        title: Text(
                          name,
                          style: TextStyle(
                            color: black,
                            fontSize: 30,
                          ),
                        ),
                        subtitle: Text(
                          message,
                          style: TextStyle(
                            color: black,
                            fontSize: 18,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Yesterday'),
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: color.secondaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '17',
                                style: TextStyle(color: white),
                              ),
                            )
                          ],
                        ),
                        onTap: () => goToChat(
                          name: name,
                          id: id,
                          userId: userId,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }
}
