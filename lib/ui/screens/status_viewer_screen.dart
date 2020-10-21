import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:howdy/modals/status.dart';
import 'package:howdy/services/status_service.dart';
import 'package:howdy/ui/themes/colors.dart';

class StatusViewerScreen extends StatefulWidget {
  StatusViewerScreen(
    this.uid,
    this.count,
    this.width,
  );
  final String uid;
  final int count;
  final double width;

  @override
  _StatusViewerScreenState createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends State<StatusViewerScreen> {
  int index = 0;
  double width = 0.0;
  Timer timer;
  Stopwatch stopwatch = Stopwatch();
  List<Widget> containers = [];
  bool isGenerated = false;
  List<double> widthList;

  startPlaying() {
    if (timer != null && timer.isActive) timer.cancel();

    timer = Timer(Duration(seconds: 5), () {
      nextStatus();
    });
  }

  previousStatus() {
    setState(() {
      index--;
    });
    startPlaying();
  }

  nextStatus() {
    if (index + 1 < widget.count) {
      setState(() {
        index++;
      });
      startPlaying();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    startPlaying();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
        future: StatusService().getStatus(widget.uid),
        builder: (context, snapshot) {
          List<DocumentSnapshot> docList;
          if (snapshot.hasData) {
            docList = snapshot.data.documents;
            print('ff ${snapshot.data.documents.length}');
          }

          return !snapshot.hasData
              ? Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    GestureDetector(
                        child: Image.network(
                          Status.fromFirestore(docList[0]).url,
                        ),
                        onTapDown: (details) {
                          if (details.globalPosition.dx < 30) {
                            if (index != 0) {
                              previousStatus();
                            }
                          } else {
                            nextStatus();
                          }
                        }),
                    Padding(
                      padding: const EdgeInsets.only(top: 38.0),
                      child: Row(
                        children: List.generate(
                          widget.count,
                          (widgetIndex) => Flexible(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2),
                              child: Container(
                                height: 2.5,
                                width: MediaQuery.of(context).size.width /
                                    widget.count,
                                color: widgetIndex <= index
                                    ? ConstantColor.white
                                    : Color(0x77ffffff),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}
