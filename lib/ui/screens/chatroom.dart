import 'dart:math';
import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:howdy/modals/call.dart';
import 'package:howdy/modals/chat.dart';
import 'package:howdy/modals/user.dart';
import 'package:howdy/ui/screens/call_screen.dart';
import 'package:howdy/services/call_service.dart';
import 'package:howdy/services/chat_service.dart';
import 'package:howdy/services/color_service.dart';
import 'package:howdy/services/user_service.dart';
import 'package:howdy/ui/themes/colors.dart';
import 'package:howdy/ui/themes/font_style.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ChatRoom extends StatefulWidget {
  ChatRoom({
    this.peerUser,
    this.chatId,
  });
  final User peerUser;
  final String chatId;

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> with TickerProviderStateMixin {
  String message = '';
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
  int chatLength;
  bool isFocus = false;
  Animation<Offset> iconSlide;
  AnimationController iconSlideController;
  FocusNode focus = FocusNode();
  bool isReplying = false;
  ScrollController scrollController;
  bool isScrolled = false;

  ChatService chatService = ChatService();

  scrollControl() {
    setState(() {
      if (scrollController.offset > 10.0) {
        isScrolled = true;
      } else {
        isScrolled = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setPeerUser();
    scrollController = ScrollController();
    scrollController.addListener(() {
      scrollControl();
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

  setPeerUser() {
    Provider.of<UserService>(context, listen: false).peerUser = widget.peerUser;
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

  Future<void> startCalling(User user, String type) async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CallScreen(
                  call: Call(
                    callerName: user.name,
                    callerUid: user.uid,
                    receiverName: widget.peerUser.name,
                    receiverUid: widget.peerUser.uid,
                    calltype: type,
                    callStatus: CallStatus.dialled,
                    channelName: Random().nextInt(100000).toString(),
                  ),
                  isCaller: true,
                )));
  }

  @override
  Widget build(BuildContext context) {
    final color = Provider.of<ColorService>(context);
    User user = Provider.of<UserService>(context).user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.primaryColor,
        leadingWidth: 20,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person_rounded,
                color: ConstantColor.white,
                size: 40,
              ),
            ),
            SizedBox(width: 10),
            Text(widget.peerUser.name),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: GestureDetector(
              child: Icon(Icons.videocam, size: 30),
              onTap: () => startCalling(user, CallType.video),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              child: Icon(Icons.call, size: 30),
              onTap: () => startCalling(user, CallType.voice),
            ),
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, size: 30),
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            itemBuilder: (_) {
              return [];
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: chatService.getChatMessages(user.uid, widget.peerUser.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              chatLength = snapshot.data.documents.length;
            }
            return !snapshot.hasData
                ? Center(
                    child: CircularProgressIndicator(
                    backgroundColor: ConstantColor.white,
                  ))
                : Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                              child: FittedBox(
                            fit: BoxFit.cover,
                            child: Image.asset('assets/bg.png'),
                          )),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Expanded(
                            child: Scrollbar(
                              controller: scrollController,
                              child: ListView.builder(
                                controller: scrollController,
                                reverse: true,
                                scrollDirection: Axis.vertical,
                                itemCount: chatLength,
                                itemBuilder: (context, index) {
                                  Chat chat = Chat.fromFirestore(
                                      snapshot.data.documents[index]);
                                  Chat previousChat;
                                  int previousDay;
                                  int previousMonth;
                                  if (index + 1 != chatLength) {
                                    previousChat = Chat.fromFirestore(
                                        snapshot.data.documents[index + 1]);
                                    previousDay =
                                        previousChat.timestamp.toDate().day;
                                    previousMonth =
                                        previousChat.timestamp.toDate().month;
                                  }

                                  bool isAuthor = chat.fromUserId == user.uid;
                                  //     snapshot.data.documents[index].data['author'];
                                  bool isPreviousByAuthor =
                                      index == chatLength - 1
                                          ? false
                                          : chat.fromUserId ==
                                              snapshot.data.documents[index + 1]
                                                  .data['fromUserId'];

                                  String replyTo = chat.replyTo;
                                  String replyFor = chat.replyFor;
                                  String authorName = chat.fromUserName;
                                  DateTime dateTime = chat.timestamp.toDate();
                                  int hour = dateTime.hour;
                                  int minute = dateTime.minute;
                                  int day = dateTime.day;
                                  int month = dateTime.month;
                                  int year = dateTime.year;

                                  bool isPm = hour > 12;
                                  String meridian = isPm ? 'PM' : "AM";

                                  String timeStamp =
                                      '${isPm ? hour - 12 : hour}:$minute $meridian';

                                  bool isDateChanged = index == chatLength - 1
                                      ? true
                                      : day != previousDay ||
                                          month != previousMonth;

                                  return Column(
                                    children: [
                                      isDateChanged
                                          ? Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 12.0,
                                                  horizontal: 100),
                                              child: Bubble(
                                                  color: Colors.lightBlue[100],
                                                  child: BlackText(
                                                      '$day/$month/$year')),
                                            )
                                          : SizedBox(),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            isAuthor ? 40 : 13,
                                            2,
                                            !isAuthor ? 40 : 13,
                                            2),
                                        child: GestureDetector(
                                          onHorizontalDragStart: (_) {
                                            setState(() {
                                              selectedIndex = index;
                                            });
                                          },
                                          onHorizontalDragUpdate:
                                              selectedIndex == index
                                                  ? _handleDragUpdate
                                                  : null,
                                          onHorizontalDragEnd: (details) {
                                            if (selectedIndex == index) {
                                              _handleDragEnd(
                                                  details,
                                                  isAuthor ? 'You' : authorName,
                                                  chat.message);
                                            }
                                          },
                                          child: SlideTransition(
                                            position: selectedIndex == index
                                                ? replySlide
                                                : defaultPosition,
                                            child: Container(
                                              child: Bubble(
                                                color: isAuthor
                                                    ? color.bubbleColor
                                                    : ConstantColor.white,
                                                alignment: isAuthor
                                                    ? Alignment.topRight
                                                    : Alignment.topLeft,
                                                nip: isPreviousByAuthor
                                                    ? BubbleNip.no
                                                    : isAuthor
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
                                                                // color: Color(0x22909090),
                                                                border: Border(
                                                                    left: BorderSide(
                                                              width: 5,
                                                              color: color
                                                                  .primaryColor,
                                                            ))),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        6),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                StyledText(
                                                                  replyTo,
                                                                  color: color
                                                                      .primaryColor,
                                                                  size: 16,
                                                                ),
                                                                BlackText(
                                                                    replyFor),
                                                              ],
                                                            ),
                                                          )
                                                        : SizedBox(),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Flexible(
                                                          child: BlackText(
                                                            chat.message,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      8.0),
                                                          child: StyledText(
                                                            timeStamp,
                                                            color: Color(
                                                                0xff909090),
                                                            size: 12,
                                                          ),
                                                        ),
                                                        isAuthor
                                                            ? Icon(
                                                                Icons
                                                                    .done_all_sharp,
                                                                size: 17,
                                                                color:
                                                                    Colors.blue,
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
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(5, 5, 0, 5),
                            // color: Color(0xfffafafa),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  flex: 5,
                                  child: Material(
                                    color: ConstantColor.white,
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 20.0),
                                                  child: Stack(
                                                    alignment:
                                                        Alignment.topRight,
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Colors
                                                                    .grey[100],
                                                                border: Border(
                                                                    left:
                                                                        BorderSide(
                                                                  width: 5,
                                                                  color: color
                                                                      .primaryColor,
                                                                ))),
                                                        padding: EdgeInsets
                                                            .symmetric(
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
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: Icon(
                                                            Icons.close,
                                                            color: Color(
                                                                0xff777777),
                                                            size: 20,
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          setState(() {
                                                            replyToAuthor =
                                                                null;
                                                            replyToMessage =
                                                                null;
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
                                                    alignment:
                                                        Alignment.centerLeft,
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
                                                              ? Colors.red
                                                              : Colors.grey,
                                                          size: isDeleting
                                                              ? 35
                                                              : 30,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
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
                                                    fillColor:
                                                        ConstantColor.white,
                                                    hintText:
                                                        'Type your message',
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
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            'Tap to cancel',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
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
                                        color: color.primaryColor,
                                        shape: CircleBorder(
                                            side: BorderSide(
                                          style: BorderStyle.none,
                                        )),
                                        child: Padding(
                                          padding: const EdgeInsets.all(13.0),
                                          child: Icon(
                                            message.length >= 1
                                                ? Icons.send
                                                : Icons.mic,
                                            size: 25,
                                            color: ConstantColor.white,
                                          ),
                                        ),
                                      ),
                                      onTap: () async {
                                        if (message.length >= 1) {
                                          controller.clear();
                                          setState(() {
                                            isReplying = false;
                                          });

                                          chatService.createChat(
                                            Chat(
                                              message: message,
                                              replyFor: replyToMessage,
                                              replyTo: replyToAuthor,
                                              toUserId: widget.peerUser.uid,
                                              fromUserId: user.uid,
                                              toUserName: widget.peerUser.name,
                                              fromUserName: user.name,
                                              type: 'text',
                                            ),
                                            chatLength,
                                          );
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
                      ),
                      isScrolled
                          ? Positioned(
                              right: 10,
                              bottom: 80,
                              child: GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xccffffff),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 30,
                                  ),
                                ),
                                onTap: () {
                                  scrollController.jumpTo(0);
                                },
                              ),
                            )
                          : SizedBox(),
                    ],
                  );
          }),
    );
  }
}
