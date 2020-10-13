import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:howdy/modals/call.dart';
import 'package:howdy/modals/user.dart';
import 'package:howdy/ui/screens/chatscreen.dart';
import 'package:howdy/services/call_service.dart';
import 'package:howdy/services/color_service.dart';
import 'package:howdy/services/user_service.dart';
import 'package:provider/provider.dart';

class CallHistoryScreen extends StatefulWidget {
  @override
  _CallHistoryScreenState createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserService>(context).user;
    ColorService color = Provider.of<ColorService>(context);

    return FutureBuilder<QuerySnapshot>(
      future: CallService().getHistory(user.uid),
      builder: (context, snapshot) {
        int length;
        if (snapshot.hasData) {
          length = snapshot.data.documents.length;
        }
        return !snapshot.hasData
            ? Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: EdgeInsets.only(top: 10),
                separatorBuilder: (_, ind) => Divider(
                      thickness: 1,
                      height: 0,
                      indent: MediaQuery.of(context).size.width / 4.3,
                    ),
                itemCount: length,
                itemBuilder: (_, index) {
                  DocumentSnapshot doc = snapshot.data.documents[index];
                  Call details = Call.fromFirestore(doc);
                  bool isVideoCall = details.calltype == CallType.video;

                  String status = details.callStatus;
                  String name = status == CallStatus.dialled
                      ? details.receiverName
                      : details.callerName;
                  String timestamp;
                  String date;
                  DateTime dateTime = details.timestamp.toDate();
                  bool isPM = dateTime.hour > 12;
                  String meridian = isPM ? 'PM' : 'AM';
                  int day = dateTime.day;
                  int month = dateTime.month;
                  int year = dateTime.year;
                  int hour = isPM ? dateTime.hour - 12 : dateTime.hour;
                  int minute = dateTime.minute;
                  int today = DateTime.now().day;
                  int diff = dateTime.difference(DateTime.now()).inDays;
                  if (diff == 0 && today - day == 0) {
                    date = 'Today';
                  } else if (diff == 0 || diff == 1 && today - day == 1) {
                    date = 'Yesterday';
                  } else {
                    date = '$day/$month/$year';
                  }
                  timestamp = '$date, $hour:$minute $meridian';

                  return CardTile(
                    title: name,
                    subTitle: timestamp,
                    trailing: Icon(
                      isVideoCall ? Icons.videocam : Icons.call,
                      size: 25,
                      color: color.primaryColor,
                    ),
                    subLeading: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        details.callStatus == CallStatus.dialled
                            ? Icons.call_made_outlined
                            : Icons.call_received,
                        size: 16,
                        color: details.callStatus == CallStatus.missed
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  );
                });
      },
    );
  }
}
