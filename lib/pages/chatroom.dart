import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:howdy/modals/chat.dart';
import 'package:howdy/modals/constants.dart';
import 'package:howdy/modals/user.dart';
import 'package:howdy/services/chat_service.dart';
import 'package:howdy/services/color_service.dart';
import 'package:howdy/services/user_service.dart';
import 'package:provider/provider.dart';

class ChatRoom extends StatefulWidget {
  ChatRoom({
    @required this.toUserName,
    @required this.toUserId,
    @required this.currentUserName,
    @required this.currentUserId,
    this.chatId,
  });
  final String toUserName;
  final String toUserId;
  final String currentUserName;
  final String currentUserId;
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

  ChatService chatService = ChatService();

  @override
  void initState() {
    super.initState();

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
    final color = Provider.of<ColorService>(context);
    User user = Provider.of<UserService>(context).user;

    return Scaffold(
      backgroundColor: color.primaryColor,
      appBar: AppBar(
        title: Text(widget.toUserName),
        backgroundColor: color.primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: chatService.getChatMessages(widget.chatId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              chatLength = snapshot.data.documents.length;
              print(chatLength);
            }
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
                          itemCount: chatLength,
                          itemBuilder: (context, index) {
                            Chat chat = Chat.fromFirestore(
                                snapshot.data.documents[index]);

                            bool author = chat.fromUserId == user.uid;
                            //     snapshot.data.documents[index].data['author'];
                            bool isPreviousByAuthor =
                                index == snapshot.data.documents.length - 1
                                    ? false
                                    : chat.fromUserId ==
                                        snapshot.data.documents[index + 1]
                                            .data['fromUserId'];

                            String replyTo = chat.replyTo;
                            String replyFor = chat.replyFor;
                            String authorName = chat.fromUserName;

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
                                        chat.message);
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
                                                      // color: Color(0x22909090),
                                                      border: Border(
                                                          left: BorderSide(
                                                    width: 5,
                                                    color: color.primaryColor,
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
                                                  chat.message,
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

                                      print('from  ${user.uid}');
                                      print('to  ${widget.toUserId}');

                                      chatService.createChat(
                                        Chat(
                                          message: message,
                                          replyFor: replyToMessage,
                                          replyTo: replyToAuthor,
                                          toUserId: widget.toUserId,
                                          fromUserId: user.uid,
                                          toUserName: widget.toUserName,
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
                  );
          }),
    );
  }
}
