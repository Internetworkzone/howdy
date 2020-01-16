import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:howdy/modals/colorstate.dart';
import 'package:howdy/modals/constants.dart';
import 'package:howdy/modals/userstate.dart';
import 'package:howdy/pages/chatroom.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Stream<QuerySnapshot> chatList;
  String currentUserName;
  String currentUserId;

  goToChat({name, id}) {
    final user = Provider.of<UserState>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoom(
          currentUserId: user.currentUserId,
          currentUserName: currentUserName,
          toUserId: id,
          toUserName: name,
        ),
      ),
    );
  }

  Future getChatlist() async {
    final user = Provider.of<UserState>(context, listen: false);
    if (user.currentUserId != null) {
      try {
        return firestore
            .collection('chatlist')
            .document(user.currentUserId)
            .collection(currentUserName)
            .orderBy('timestamp', descending: true)
            .snapshots();
      } catch (e) {
        print(e);
      }
    }
  }

  getCurrentUserDetails() async {
    final user = Provider.of<UserState>(context, listen: false);
    if (user.currentUserId != null) {
      await firestore
          .collection('users')
          .document(user.currentUserId)
          .get()
          .then((DocumentSnapshot doc) {
        setState(() {
          currentUserName = doc.data['name'];
        });
      });
    }
    try {
      getChatlist().then((onValue) {
        setState(() {
          chatList = onValue;
        });
      });
    } catch (e) {
      print(e);
    }

    print('name $currentUserName');
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    final color = Provider.of<ColorState>(context, listen: false);

    if (Provider.of<UserState>(context, listen: false).currentUserId == null) {
      return Center(child: Text('Log in to see your chat'));
    } else {
      return StreamBuilder(
        stream: chatList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(backgroundColor: purple),
            );
          }
          print(snapshot.data.documents.length);
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              String name = snapshot.data.documents[index].data['name'];
              String id = snapshot.data.documents[index].documentID;
              String message =
                  snapshot.data.documents[index].data['lastmessage'];

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
                  onTap: () => goToChat(name: name, id: id),
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
