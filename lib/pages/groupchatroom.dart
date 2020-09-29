import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:howdy/modals/colorstate.dart';
import 'package:howdy/modals/constants.dart';
import 'package:howdy/services/authservice.dart';
import 'package:provider/provider.dart';

class GroupChatRoom extends StatefulWidget {
  GroupChatRoom({
    @required this.groupName,
    @required this.groupId,
    @required this.currentUserName,
    @required this.currentUserId,
  });
  final String groupName;
  final String groupId;
  final String currentUserName;
  final String currentUserId;

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<GroupChatRoom> {
  String message;
  String author;
  Stream<QuerySnapshot> allMessages;
  TextEditingController controller = TextEditingController();

  Future getChatMessage() async {
    return firestore
        .collection('groupchat')
        .document(widget.groupId)
        .collection(widget.groupName)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  createChat() {
    firestore
        .collection('groupchat')
        .document(widget.groupId)
        .collection(widget.groupName)
        .add({
      'message': message,
      'timestamp': Timestamp.now(),
      'authorName': widget.currentUserName,
    });
  }

  @override
  void initState() {
    super.initState();

    getChatMessage().then((onValue) {
      setState(() {
        allMessages = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Provider.of<ColorState>(context);

    return Scaffold(
      backgroundColor: color.primaryColor,
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: color.primaryColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: allMessages,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: white,
                  ),
                );
              }

              return Expanded(
                child: ListView.builder(
                  reverse: true,
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    bool author = widget.currentUserName ==
                        snapshot.data.documents[index].data['authorName'];
                    return Column(
                      crossAxisAlignment: author
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: author
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: <Widget>[
                              Material(
                                color: color.secondaryColor,
                                child: Padding(
                                  padding: author
                                      ? EdgeInsets.only(
                                          top: 2,
                                          left: 20,
                                          right: 10,
                                          bottom: 8,
                                        )
                                      : EdgeInsets.only(
                                          top: 2,
                                          left: 10,
                                          right: 20,
                                          bottom: 8,
                                        ),
                                  child: Column(
                                    crossAxisAlignment: author
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(author
                                          ? 'You'
                                          : snapshot.data.documents[index]
                                              .data['authorName']),
                                      Text(
                                        snapshot.data.documents[index]
                                            .data['message'],
                                        style: TextStyle(fontSize: 25),
                                      ),
                                    ],
                                  ),
                                ),
                                borderRadius: author
                                    ? BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        bottomRight: Radius.circular(20),
                                        bottomLeft: Radius.circular(30),
                                      )
                                    : BorderRadius.only(
                                        topRight: Radius.circular(30),
                                        bottomRight: Radius.circular(20),
                                        bottomLeft: Radius.circular(20),
                                      ),
                                elevation: 5,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              color: white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: TextField(
                      onChanged: (input) {
                        message = input;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: color.primaryColor,
                        hintText: 'Type your message',
                        hintStyle: TextStyle(
                          color: white,
                        ),
                      ),
                      style: TextStyle(color: white),
                      controller: controller,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      color: color.primaryColor,
                      icon: Icon(
                        Icons.send,
                      ),
                      onPressed: () {
                        controller.clear();
                        createChat();
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
