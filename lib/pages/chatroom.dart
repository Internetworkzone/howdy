import 'dart:async';

import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:howdy/modals/colorstate.dart';
import 'package:howdy/modals/constants.dart';
import 'package:provider/provider.dart';

class ChatRoom extends StatefulWidget {
  ChatRoom({
    @required this.toUserName,
    @required this.toUserId,
    @required this.currentUserName,
    @required this.currentUserId,
  });
  final String toUserName;
  final String toUserId;
  final String currentUserName;
  final String currentUserId;

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> with TickerProviderStateMixin {
  String message = '';
  Stream<QuerySnapshot> allMessages;
  TextEditingController controller = TextEditingController();
  TextInputConnection connection;
  bool isRecording = false;
  bool isDeleting = false;
  AnimationController slideController;
  AnimationController rotationController;
  AnimationController scaleController;
  Animation<Offset> slidePosition;
  Animation<double> rotationTurns;
  Animation<double> scale;
  Stopwatch timer;
  String duration = '';
  Animation<Offset> replySlide;
  Animation<Offset> defaultPosition;
  AnimationController replySlideController;
  double dragPosition = 0.0;
  int selectedIndex;
  String replyToMessage;
  String replyToAuthor;
  bool isFocus = false;
  Animation<Offset> iconSlide;
  AnimationController iconSlideController;
  FocusNode focus = FocusNode();
  bool isReplying = false;

  Future getChatMessage() async {
    return firestore
        .collection('chat')
        .document(widget.currentUserId)
        .collection(widget.currentUserName)
        .document(widget.toUserId)
        .collection(widget.toUserName)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> createChat() async {
    await firestore
        .collection('chat')
        .document(widget.currentUserId)
        .collection(widget.currentUserName)
        .document(widget.toUserId)
        .collection(widget.toUserName)
        .add({
      'message': message,
      'author': true,
      'timestamp': Timestamp.now(),
      'authorName': widget.currentUserName,
      'replyTo': replyToAuthor,
      'replyFor': replyToMessage,
    });
    await firestore
        .collection('chat')
        .document(widget.toUserId)
        .collection(widget.toUserName)
        .document(widget.currentUserId)
        .collection(widget.currentUserName)
        .add({
      'message': message,
      'author': false,
      'timestamp': Timestamp.now(),
      'authorName': widget.currentUserName,
      'replyTo': replyToAuthor,
      'replyFor': replyToMessage,
    });

    await firestore
        .collection('chatlist')
        .document(widget.currentUserId)
        .collection(widget.currentUserName)
        .document(widget.toUserId)
        .setData({
      'name': widget.toUserName,
      'timestamp': Timestamp.now(),
      'lastmessage': message,
    });
    await firestore
        .collection('chatlist')
        .document(widget.toUserId)
        .collection(widget.toUserName)
        .document(widget.currentUserId)
        .setData({
      'name': widget.currentUserName,
      'timestamp': Timestamp.now(),
      'lastmessage': message,
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

    slideController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
      reverseDuration: Duration(milliseconds: 1200),
    );
    rotationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900),
    );
    scaleController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    slidePosition = Tween(
      begin: Offset(0.0, 0.0),
      end: Offset(.0, -5.0),
    ).animate(slideController);
    rotationTurns = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(rotationController);
    scale = Tween(
      begin: 1.0,
      end: 1.8,
    ).animate(scaleController);
    replySlideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    );
    defaultPosition = Tween(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(AnimationController(vsync: this));
    updateReplySlideMovement();
    iconSlideController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    iconSlide = Tween(
      begin: Offset(-10, 0),
      end: Offset.zero,
    ).animate(iconSlideController);
  }

  onCancelRecording() async {
    timer.reset();
    setState(() {
      isDeleting = !isDeleting;
    });
    slideController.forward();
    rotationController.forward();
    await Future.delayed(Duration(seconds: 1));
    slideController.reverse();
    scaleController.reverse();
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      isDeleting = !isDeleting;
      isRecording = !isRecording;
    });
    rotationController.reverse();
  }

  startRecord() {
    timer = Stopwatch();
    setState(() {
      timer.start();
    });

    scaleController.forward();
    setState(() {
      isRecording = !isRecording;
    });
  }

  updateReplySlideMovement() {
    replySlide = replySlideController.drive(
      Tween(
        begin: Offset.zero,
        end: Offset(1.0, 0.0),
      ),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final double delta = details.primaryDelta;
    dragPosition += delta;
    if (dragPosition > 0) {
      setState(() {
        updateReplySlideMovement();
      });
      replySlideController.value = dragPosition / context.size.width;
    }
  }

  Future<void> _handleDragEnd(
      DragEndDetails details, String author, String replyMessage) async {
    double prevPosotion = dragPosition;
    dragPosition = 0.0;
    replySlideController.fling(velocity: -1.1);
    print('po is ${context.size.width / 8}');
    if (prevPosotion > context.size.width / 8) {
      setState(() {
        replyToAuthor = author;
        replyToMessage = replyMessage;
        isReplying = true;
      });
      SystemChannels.textInput.invokeMethod('TextInput.show');
      focus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Provider.of<ColorState>(context);

    return Scaffold(
      backgroundColor: color.primaryColor,
      appBar: AppBar(
        title: Text(widget.toUserName),
        backgroundColor: color.primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: allMessages,
          builder: (context, snapshot) {
            return !snapshot.hasData
                ? Center(
                    child: CircularProgressIndicator(
                    backgroundColor: white,
                  ))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          reverse: true,
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            bool author =
                                snapshot.data.documents[index].data['author'];
                            bool isPreviousByAuthor =
                                index == snapshot.data.documents.length - 1
                                    ? false
                                    : snapshot.data.documents[index]
                                            .data['authorName'] ==
                                        snapshot.data.documents[index + 1]
                                            .data['authorName'];
                            String replyTo =
                                snapshot.data.documents[index].data['replyTo'];
                            String replyFor =
                                snapshot.data.documents[index].data['replyFor'];

                            String authorName = snapshot
                                .data.documents[index].data['authorName'];
                            return Padding(
                              padding: EdgeInsets.fromLTRB(
                                  author ? 40 : 5, 2, !author ? 40 : 5, 2),
                              child: GestureDetector(
                                onHorizontalDragStart: (_) {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                onHorizontalDragUpdate: selectedIndex == index
                                    ? _handleDragUpdate
                                    : null,
                                onHorizontalDragEnd: (details) {
                                  if (selectedIndex == index) {
                                    _handleDragEnd(
                                        details,
                                        author ? 'You' : authorName,
                                        snapshot.data.documents[index]
                                            .data['message']);
                                  }
                                },
                                child: SlideTransition(
                                  position: selectedIndex == index
                                      ? replySlide
                                      : defaultPosition,
                                  child: Container(
                                    child: Bubble(
                                      alignment: author
                                          ? Alignment.topRight
                                          : Alignment.topLeft,
                                      nip: isPreviousByAuthor
                                          ? BubbleNip.no
                                          : author
                                              ? BubbleNip.rightTop
                                              : BubbleNip.leftTop,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          replyTo != null
                                              ? Container(
                                                  // width: double.infinity,
                                                  decoration: BoxDecoration(
                                                      color: Color(0x22909090),
                                                      border: Border(
                                                          left: BorderSide(
                                                        width: 5,
                                                        color:
                                                            color.primaryColor,
                                                      ))),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        replyTo,
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color: color
                                                                .primaryColor),
                                                      ),
                                                      Text(
                                                        replyFor,
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              : SizedBox(),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  snapshot.data.documents[index]
                                                      .data['message'],
                                                  style:
                                                      TextStyle(fontSize: 25),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Text(
                                                  '5:30 PM',
                                                ),
                                              ),
                                              author
                                                  ? Icon(
                                                      Icons.done_all_sharp,
                                                      size: 23,
                                                      color: Colors.blue,
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 5, 0, 5),
                        color: color.primaryColor,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              flex: 5,
                              child: Material(
                                borderRadius: BorderRadius.only(
                                  topLeft:
                                      Radius.circular(isReplying ? 15 : 25),
                                  topRight:
                                      Radius.circular(isReplying ? 15 : 25),
                                  bottomLeft: Radius.circular(25),
                                  bottomRight: Radius.circular(25),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Column(
                                    children: [
                                      isReplying
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20.0),
                                              child: Stack(
                                                alignment: Alignment.topRight,
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0x22909090),
                                                        border: Border(
                                                            left: BorderSide(
                                                          width: 5,
                                                          color: color
                                                              .primaryColor,
                                                        ))),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 6),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          replyToAuthor,
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              color: color
                                                                  .primaryColor),
                                                        ),
                                                        Text(
                                                          replyToMessage,
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Icon(
                                                        Icons.close,
                                                        color:
                                                            Color(0xff777777),
                                                        size: 20,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        replyToAuthor = null;
                                                        replyToMessage = null;
                                                        isReplying = false;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      Row(
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: SlideTransition(
                                                  position: slidePosition,
                                                  child: RotationTransition(
                                                    turns: rotationTurns,
                                                    child: Icon(
                                                      isRecording
                                                          ? Icons.mic
                                                          : Icons
                                                              .emoji_emotions_outlined,
                                                      color: isDeleting
                                                          ? white
                                                          : Colors.grey,
                                                      size:
                                                          isDeleting ? 35 : 30,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: isDeleting
                                                    ? Icon(
                                                        Icons.delete,
                                                        size: 35,
                                                        color: Colors.grey,
                                                      )
                                                    : Container(),
                                              ),
                                            ],
                                          ),
                                          Flexible(
                                            child: TextField(
                                              maxLines: null,
                                              focusNode: focus,
                                              controller: controller,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                filled: true,
                                                fillColor: white,
                                                hintText: 'Type your message',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                              onChanged: (input) {
                                                setState(() {
                                                  message = input;
                                                });
                                              },
                                            ),
                                          ),
                                          GestureDetector(
                                            child: isRecording
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'Tap to cancel',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 25,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10,
                                                                right: 25),
                                                        child: Icon(
                                                          Icons.close,
                                                          color: Colors.red,
                                                          size: 35,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Icon(
                                                    Icons.camera_alt,
                                                    color: isRecording
                                                        ? Colors.red
                                                        : Colors.grey,
                                                    size: 30,
                                                  ),
                                            onTap: () {
                                              if (isRecording) {
                                                onCancelRecording();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: ScaleTransition(
                                scale: scale,
                                child: InkWell(
                                  child: Material(
                                    color: isRecording ? Colors.grey : white,
                                    shape: CircleBorder(
                                        side: BorderSide(
                                      style: BorderStyle.none,
                                    )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Icon(
                                        message.length >= 1
                                            ? Icons.send
                                            : Icons.mic,
                                        size: 35,
                                        color: isRecording
                                            ? white
                                            : color.primaryColor,
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    if (message.length >= 1) {
                                      controller.clear();
                                      setState(() {
                                        isReplying = false;
                                      });
                                      await createChat();
                                      setState(() {
                                        message = '';
                                        replyToMessage = null;
                                        replyToAuthor = null;
                                      });
                                    }
                                  },
                                  onLongPress: startRecord,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
          }),
    );
  }
}
