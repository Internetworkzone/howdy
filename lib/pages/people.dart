import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:howdy/modals/constants.dart';
import 'package:howdy/modals/user.dart';
import 'package:howdy/pages/chatroom.dart';
import 'package:howdy/services/color_service.dart';
import 'package:howdy/services/user_service.dart';
import 'package:provider/provider.dart';

class PeopleScreen extends StatefulWidget {
  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  Stream<QuerySnapshot> userList;
  String currentUserId;
  String currentUserName;

  @override
  void initState() {
    super.initState();
  }

  gotoChatRoom({User peer, String docId}) {
    Navigator.pushReplacement(
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
  Widget build(BuildContext context) {
    final color = Provider.of<ColorService>(context, listen: false);
    User user = Provider.of<UserService>(context, listen: false).user;

    return Scaffold(
        backgroundColor: white,
        appBar: AppBar(
          backgroundColor: color.primaryColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select contact'),
              Text('10 contacts'),
            ],
          ),
        ),
        body: FutureBuilder<QuerySnapshot>(
          future: UserService().getUsersList(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                backgroundColor: white,
              ));
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomTile(
                    circleColor: color.primaryColor,
                    icon: Icons.group,
                    userName: 'New group'),
                CustomTile(
                    circleColor: color.primaryColor,
                    icon: Icons.person_add,
                    userName: 'New contact'),
                Flexible(
                  child: ListView.builder(
                    // physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      User peerUser =
                          User.fromFirestore(snapshot.data.documents[index]);
                      String userName = peerUser.name;
                      String userEmail = peerUser.email;
                      String docId = snapshot.data.documents[index].documentID;

                      return user.uid == docId
                          ? SizedBox()
                          : CustomTile(
                              userName: userName,
                              userEmail: userEmail,
                              circleColor: Colors.grey[300],
                              onTap: () {
                                gotoChatRoom(
                                  peer: peerUser,
                                  docId: docId,
                                );
                              },
                            );
                    },
                  ),
                ),
                CustomTile(
                  icon: Icons.share,
                  iconColor: Colors.grey[700],
                  userName: 'Invite friends',
                ),
                CustomTile(
                  iconColor: Colors.grey[700],
                  icon: Icons.help_rounded,
                  userName: 'Contacts help',
                ),
              ],
            );
          },
        ));
  }
}

class CustomTile extends StatelessWidget {
  const CustomTile({
    Key key,
    this.userName,
    this.userEmail,
    this.onTap,
    this.icon = Icons.person_rounded,
    this.circleColor = Colors.white12,
    this.iconColor = white,
  }) : super(key: key);

  final String userName;
  final String userEmail;
  final Function onTap;
  final IconData icon;
  final Color circleColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Row(
        children: [
          SizedBox(width: 15),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 30,
            ),
          ),
          Flexible(
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(fontSize: 22),
                  ),
                  userEmail != null
                      ? Text(
                          userEmail,
                          style: TextStyle(fontSize: 18),
                        )
                      : Container(),
                ],
              ),
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
