import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:howdy/modals/chat.dart';
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

  goToChat({User peer, String docId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoom(
          peerUser: peer,
          chatId: docId,
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

    return StreamBuilder(
      stream: chatService.getChatList(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
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
            User peerUser;
            String name = '';
            String userId = '';
            ChatDetails details =
                ChatDetails.fromFirestore(snapshot.data.documents[index]);
            String docId = snapshot.data.documents[index].documentID;
            List<dynamic> membersName = details.membersName;
            List<dynamic> membersId = details.membersId;
            String timestamp;
            DateTime dateTime = details.lastMessageTimestamp.toDate();
            int diff = dateTime.difference(DateTime.now()).inDays;

            int day = dateTime.day;
            int month = dateTime.month;
            int year = dateTime.year;
            int hour = dateTime.hour;
            bool isPM = hour > 12;

            int minute = dateTime.minute;
            String meridian = isPM ? 'PM' : 'Am';
            if (diff == 0) {
              timestamp = '${isPM ? hour - 12 : hour}:$minute $meridian';
            } else if (diff == 1) {
              timestamp = 'Yesterday';
            } else {
              timestamp = '$day/$month/${year.toString().substring(2, 4)}';
            }

            if (membersName[0] == user.name) {
              name = membersName[1] ?? '';
              userId = membersId[1];
            } else {
              name = membersName[0] ?? '';
              userId = membersId[0];
            }
            String message = details.lastMessage;
            peerUser = User(
              name: name,
              uid: userId,
            );

            return CardTile(
              title: name,
              subTitle: message,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(timestamp),
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
              onPressed: () => goToChat(
                peer: peerUser,
                docId: docId,
              ),
            );
          },
        );
      },
    );
  }
}

class CardTile extends StatelessWidget {
  const CardTile({
    Key key,
    @required this.title,
    @required this.subTitle,
    this.onPressed,
    this.trailing,
    this.subLeading,
  }) : super(key: key);

  final String title;
  final String subTitle;
  final Function onPressed;
  final Widget trailing;
  final Widget subLeading;

  @override
  Widget build(BuildContext context) {
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
                title,
                style: TextStyle(
                  color: black,
                  fontSize: 30,
                ),
              ),
              subtitle: Row(
                children: [
                  subLeading ?? SizedBox(),
                  Text(
                    subTitle,
                    style: TextStyle(
                      color: black,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              trailing: trailing,
              onTap: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
