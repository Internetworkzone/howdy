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
  Stream<QuerySnapshot> results;
  String userName;
  String userEmail;
  String userId;
  String currentUserId;
  String currentUserName;

  Future getUserList() async {
    return firestore
        .collection('users')
        .orderBy('name', descending: false)
        .snapshots();
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
          currentUserId = doc.data['id'].toString();
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();

    getUserList().then((onValue) {
      setState(() {
        results = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Provider.of<ColorState>(context, listen: false);

    return StreamBuilder<QuerySnapshot>(
      stream: results,
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
            userName = snapshot.data.documents[index].data['name'];
            userEmail = snapshot.data.documents[index].data['email'];
            userId = snapshot.data.documents[index].data['id'];

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
                onTap: () {
                  if (auth.currentUser() != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoom(
                          toUserName:
                              snapshot.data.documents[index].data['name'],
                          toUserId: snapshot.data.documents[index].data['id'],
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
                },
              ),
            );
          },
        );
      },
    );
  }
}
