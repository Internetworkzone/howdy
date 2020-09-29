import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:howdy/modals/colorstate.dart';
import 'package:howdy/modals/constants.dart';
import 'package:howdy/modals/userstate.dart';
import 'package:howdy/pages/groupchatroom.dart';
import 'package:provider/provider.dart';

class GroupScreen extends StatefulWidget {
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  String newgroupname;
  String currentUserName;
  String currentUserId;
  bool isJoined = false;

  showGroupDialog() {
    final color = Provider.of<ColorState>(context, listen: false);
    return showDialog(
      context: context,
      child: SimpleDialog(
        title: Text('Add Group'),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  style: TextStyle(fontSize: 25),
                  decoration: InputDecoration(hintText: 'Group Name'),
                  onChanged: (input) {
                    setState(() {
                      newgroupname = input;
                    });
                  },
                ),
                SizedBox(height: 20),
                MaterialButton(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, left: 80, right: 80),
                    child: Text(
                      'Create',
                      style: TextStyle(fontSize: 20),
                    ),
                    color: color.primaryColor,
                    shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    splashColor: color.secondaryColor,
                    onPressed: () {
                      createGroup();
                      Navigator.pop(context);
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  createGroup() async {
    if (currentUserName != null) {
      try {
        await firestore.collection('groups').add({
          'groupName': newgroupname,
          'timestamp': Timestamp.now(),
          'admin': currentUserName,
        });
      } catch (e) {}
    }
  }

  Future<QuerySnapshot> getGroupList() async {
    if (currentUserName != null) {
      try {
        return await firestore
            .collection('groups')
            .orderBy('groupName', descending: false)
            .getDocuments();
      } catch (e) {}
    }
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

  joinGroup({groupName, groupId}) {
    firestore
        .collection('activegroup')
        .document(currentUserId)
        .collection(currentUserName)
        .document(groupId)
        .setData({
      'groupname': groupName,
      'groupid': groupId,
    });
  }

  Future<bool> groupCheck(groupId) async {
    DocumentSnapshot groupDoc = await firestore
        .collection('activegroup')
        .document(currentUserId)
        .collection(currentUserName)
        .document(groupId)
        .get();
    setState(() {
      isJoined = groupDoc.exists;
    });

    print(isJoined);

    return groupDoc.exists;
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    final color = Provider.of<ColorState>(context);
    return Scaffold(
      backgroundColor: color.primaryColor,
      body: Stack(
        children: <Widget>[
          FutureBuilder<QuerySnapshot>(
            future: getGroupList(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  String groupName =
                      snapshot.data.documents[index].data['groupName'];
                  String groupId = snapshot.data.documents[index].documentID;
                  // groupCheck(groupId);

                  bool joined = isJoined;

                  return Card(
                    child: ListTile(
                      title: Text(
                        groupName,
                        style: TextStyle(
                            color: color.secondaryColor, fontSize: 30),
                      ),
                      subtitle: Text(
                        'Admin: ${snapshot.data.documents[index].data['admin']}',
                        style: TextStyle(
                            color: color.secondaryColor, fontSize: 15),
                      ),
                      trailing: joined
                          ? Text(
                              'Joined',
                              style: TextStyle(
                                fontSize: 18,
                                color: color.secondaryColor,
                              ),
                            )
                          : FlatButton(
                              color: color.secondaryColor,
                              child: Text(
                                'join',
                                style: TextStyle(fontSize: 18),
                              ),
                              onPressed: () => joinGroup(
                                groupId: groupId,
                                groupName: groupName,
                              ),
                            ),
                      onTap: () => joined
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GroupChatRoom(
                                  groupName: groupName,
                                  groupId: groupId,
                                  currentUserName: currentUserName,
                                  currentUserId: currentUserId,
                                ),
                              ),
                            )
                          : null,
                    ),
                    color: color.primaryColor,
                    elevation: 0,
                  );
                },
              );
            },
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  // FloatingActionButton(
                  //   backgroundColor: color.secondaryColor,
                  //   child: Icon(Icons.add, color: color.primaryColor),
                  //   onPressed: () => showGroupDialog(),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
