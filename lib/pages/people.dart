import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:howdy/modals/colorstate.dart';
import 'package:howdy/modals/constants.dart';
import 'package:howdy/modals/userstate.dart';
import 'package:howdy/pages/chatroom.dart';
import 'package:howdy/pages/loginpage.dart';
import 'package:provider/provider.dart';

class PeopleScreen extends StatefulWidget {
  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  Stream<QuerySnapshot> userList;
  String currentUserId;
  String currentUserName;

  Future getUserList() async {
    try {
      return firestore
          .collection('users')
          .orderBy('name', descending: false)
          .snapshots();
    } catch (e) {}
  }

  getCurrentUserDetails() async {
    final user = Provider.of<UserState>(context, listen: false);
    try {
      if (user.currentUserId != null) {
        await firestore
            .collection('users')
            .document(user.currentUserId)
            .get()
            .then((DocumentSnapshot doc) {
          setState(() {
            currentUserName = doc.data['name'];
            currentUserId = doc.data['id'].toString();
          });
        });
      }
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
    getUserList().then((onValue) {
      setState(() {
        userList = onValue;
      });
    });
  }

  gotoChatRoom({userName, userId}) {
    if (Provider.of<UserState>(context, listen: false).currentUserId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoom(
            toUserName: userName,
            toUserId: userId,
            currentUserName: currentUserName,
            currentUserId: currentUserId,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Provider.of<ColorState>(context, listen: false);

    return StreamBuilder(
      stream: userList,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
              child: CircularProgressIndicator(
            backgroundColor: white,
          ));
        }

        return ListView.builder(
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) {
            String userName = snapshot.data.documents[index].data['name'];
            String userEmail = snapshot.data.documents[index].data['email'];
            String userId = snapshot.data.documents[index].data['id'];

            return Card(
              color: color.primaryColor,
              elevation: 0,
              child: ListTile(
                title: Text(
                  userName,
                  style: TextStyle(color: color.secondaryColor, fontSize: 30),
                ),
                subtitle: Text(
                  userEmail,
                  style: TextStyle(color: color.secondaryColor, fontSize: 15),
                ),
                onTap: () => gotoChatRoom(userName: userName, userId: userId),
              ),
            );
          },
        );
      },
    );
  }
}
