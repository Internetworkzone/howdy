import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:howdy/modals/status.dart';
import 'package:howdy/modals/user.dart';
import 'package:howdy/services/color_service.dart';
import 'package:howdy/services/status_service.dart';
import 'package:howdy/services/user_service.dart';
import 'package:howdy/ui/screens/chatscreen.dart';
import 'package:howdy/ui/screens/status_viewer_screen.dart';
import 'package:howdy/ui/themes/colors.dart';
import 'package:howdy/ui/themes/font_style.dart';
import 'package:provider/provider.dart';

class StatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserService>(context).user;
    ColorService color = Provider.of<ColorService>(context);
    return StreamBuilder<QuerySnapshot>(
        stream: StatusService().getAllStatus(),
        builder: (context, snapshot) {
          StatusSummary myStatus;
          int length = 0;
          if (snapshot.hasData && snapshot.data.documents.isNotEmpty) {
            length = snapshot.data.documents.length;

            for (int i = 0; i < length; i++) {
              if (snapshot.data.documents[i].documentID == user.uid) {
                myStatus =
                    StatusSummary.fromFirestore(snapshot.data.documents[i]);
              }
            }
          }
          return !snapshot.hasData
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: myStatus == null
                          ? CircleAvatar(
                              radius: 30,
                              child: Icon(
                                Icons.person,
                              ),
                            )
                          : CustomPaint(
                              painter: StatusCircle(
                                totalStatus: myStatus.totalStatus,
                                color: color.primaryColor,
                              ),
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30.0)),
                                    border: Border.all(
                                        width: 2, color: ConstantColor.white),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        myStatus.lastStatusUrl,
                                      ),
                                      fit: BoxFit.cover,
                                    )),
                              ),
                            ),
                      title: BlackText('My status'),
                      subtitle: StyledText(
                        '23 minutes ago',
                        color: ConstantColor.grey,
                      ),
                      onTap: () {
                        if (myStatus != null)
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => StatusViewerScreen(
                                      user.uid,
                                      myStatus.totalStatus,
                                      MediaQuery.of(context).size.width)));
                      },
                    ),
                    Container(
                      padding: EdgeInsets.all(7),
                      color: Colors.grey[200],
                      child: BlackText('Recent updates'),
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: length,
                        itemBuilder: (context, index) {
                          StatusSummary statusSummary;
                          String docID =
                              snapshot.data.documents[index].documentID;
                          if (length > 0) {
                            statusSummary = StatusSummary.fromFirestore(
                                snapshot.data.documents[index]);
                          }

                          return myStatus != null &&
                                  statusSummary.user == myStatus.user
                              ? SizedBox()
                              : ListTile(
                                  leading: statusSummary == null
                                      ? CircleAvatar(
                                          radius: 30,
                                          child: Icon(
                                            Icons.person,
                                          ),
                                        )
                                      : CustomPaint(
                                          painter: StatusCircle(
                                            totalStatus:
                                                statusSummary.totalStatus,
                                            color: color.primaryColor,
                                          ),
                                          child: Container(
                                            height: 60,
                                            width: 60,
                                            decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30.0)),
                                                border: Border.all(
                                                    width: 2,
                                                    color: ConstantColor.white),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    statusSummary.lastStatusUrl,
                                                  ),
                                                  fit: BoxFit.cover,
                                                )),
                                          ),
                                        ),
                                  title: BlackText(statusSummary.user),
                                  subtitle: StyledText(
                                    '23 minutes ago',
                                    color: ConstantColor.grey,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => StatusViewerScreen(
                                                docID,
                                                statusSummary.totalStatus,
                                                MediaQuery.of(context)
                                                    .size
                                                    .width)));
                                  },
                                );
                        }),
                  ],
                );
        });
  }
}

class StatusCircle extends CustomPainter {
  StatusCircle({
    this.totalStatus,
    this.color,
  });
  final int totalStatus;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 4;
    double degree = -90;
    double gap = totalStatus > 1 ? 8.0 : 0.0;
    double arc = 360 / totalStatus;
    degreeToRad(degree) => degree * pi / 180;
    for (int i = 0; i < totalStatus; i++) {
      canvas.drawArc(Rect.fromLTWH(0.0, 0.0, size.width, size.height),
          degreeToRad(degree + 4), degreeToRad(arc - gap), false, paint);
      degree += arc;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
