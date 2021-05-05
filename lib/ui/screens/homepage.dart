import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:howdy/modals/call.dart';
import 'package:howdy/modals/user.dart';
import 'package:howdy/ui/screens/call_history_screen.dart';
import 'package:howdy/ui/screens/call_screen.dart';
import 'package:howdy/ui/screens/camera_screen.dart';
import 'package:howdy/ui/screens/chatscreen.dart';
import 'package:howdy/ui/screens/people.dart';
import 'package:howdy/services/call_service.dart';
import 'package:howdy/services/color_service.dart';
import 'package:howdy/services/user_service.dart';
import 'package:howdy/ui/screens/status_screen.dart';
import 'package:howdy/ui/themes/colors.dart';
import 'package:howdy/ui/themes/font_style.dart';
import 'package:howdy/ui/widgets/appbaricon.dart';
import 'package:howdy/ui/widgets/colorpallette.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int appbarState = 1;
  TabController tabController;
  CallService callService = CallService();
  AudioCache cache;
  AudioPlayer player = AudioPlayer();
  int index = 1;
  ScrollController scrollController = ScrollController();
  ScrollController primaryScrollController = ScrollController();

  CameraController cameraController;
  TrackingScrollController trackingScrollController =
      TrackingScrollController();

  double offset;

  // AppBar setAppbar() {
  //   final color = Provider.of<ColorService>(context, listen: false);

  //   if (appbarState == 1) {
  //     return AppBar(
  //       backgroundColor: color.primaryColor,
  //       title: Text(
  //         'Howdy',
  //       ),
  //       actions: <Widget>[
  //         AppbarIcon(
  //           icon: FontAwesomeIcons.search,
  //           onpressed: () {
  //             setState(() {
  //               appbarState = 2;
  //             });
  //           },
  //         ),
  //         PopupMenuButton(
  //           icon: Icon(Icons.more_vert, size: 30),
  //           onSelected: (value) {
  //             if (value == 'theme') {
  //               showColorPallete(color);
  //             }
  //           },
  //           itemBuilder: (_) {
  //             return showMore();
  //           },
  //         ),
  //       ],
  //       bottom: TabBar(
  //         controller: tabController,
  //         tabs: mytab,
  //         labelStyle: TextStyle(fontSize: 17),
  //         indicatorSize: TabBarIndicatorSize.tab,
  //         indicatorWeight: 3.5,
  //         indicatorColor: ConstantColor.white,
  //         unselectedLabelColor: Color(0x88ffffff),
  //       ),
  //       elevation: 20,
  //     );
  //   } else {
  //     return AppBar(
  //       backgroundColor: color.primaryColor,
  //       leading: AppbarIcon(
  //         icon: FontAwesomeIcons.arrowLeft,
  //         onpressed: () {
  //           setState(() {
  //             appbarState = 1;
  //           });
  //         },
  //       ),
  //       title: TextField(
  //         style: TextStyle(color: color.secondaryColor),
  //         decoration: InputDecoration(
  //           disabledBorder: InputBorder.none,
  //           enabledBorder: InputBorder.none,
  //           focusedBorder: InputBorder.none,
  //           hintText: 'Search',
  //           hintStyle: TextStyle(
  //             color: ConstantColor.white,
  //           ),
  //         ),
  //       ),
  //       elevation: 20,
  //     );
  //   }
  // }

  List<Tab> mytab = [
    Tab(child: Icon(Icons.camera_alt)),
    Tab(text: 'CHATS'),
    Tab(text: 'STATUS'),
    Tab(text: 'CALLS'),
  ];

  showMore() {
    return [
      PopupMenuItem(
          textStyle: TextStyle(
            fontSize: 18,
            color: ConstantColor.black,
          ),
          child: Text('New group')),
      PopupMenuItem(child: Text('New broadcast')),
      PopupMenuItem(child: Text('WhatsApp Web')),
      PopupMenuItem(child: Text('Starred messages')),
      PopupMenuItem(child: Text('Payments')),
      PopupMenuItem(child: Text('Settings')),
      PopupMenuItem(child: Text('Dark mode')),
      PopupMenuItem(value: 'theme', child: Text('Themes')),
    ];
  }

  @override
  void initState() {
    super.initState();
    tabController =
        TabController(vsync: this, initialIndex: index, length: mytab.length);

    tabController.animation.addListener(updateIndex);
    primaryScrollController.addListener(() {
      print('scrolling up');
      scrollController.jumpTo(primaryScrollController.offset);
    });

    getUserDetails();
    cache = AudioCache(
      fixedPlayer: player,
    );
    initializeCamera();
  }

  initializeCamera() async {
    cameraController = CameraController(
      CameraDescription(
        name: '0',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      ),
      ResolutionPreset.medium,
    );

    await cameraController.initialize();
  }

  updateIndex() {
    print('updating tab ${tabController.animation.value}');

    int currentIndex = index;
    setState(() {
      index = tabController.index;
      offset = (1 - tabController.animation.value) * 130;
    });

    if (currentIndex != index) {
      scrollController.jumpTo(0);
    }

    if (tabController.animation.value < 1) {
      scrollController.jumpTo(offset);
    }
    if (index == 0) {}
  }

  showColorPallete(ColorService color) {
    return showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (_) => ColorPallete(
        ontap: (id) {
          color.setColor(id);
        },
      ),
    );
  }

  getUserDetails() async {
    UserService userService = UserService();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String uid = preferences.getString('uid');
    int color = preferences.getInt('color');
    Provider.of<ColorService>(context, listen: false).setColor(color ?? 4);
    Provider.of<UserService>(context, listen: false).user =
        await userService.updateUser(uid);
  }

  delay() async {
    await Future.delayed(Duration(seconds: 5));
    setState(() {});
  }

  Future<bool> onBackPressed() async {
    if (index == 1) {
      return true;
    } else {
      tabController.animateTo(1);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('tab is ${scrollController.offset}');
    final color = Provider.of<ColorService>(context);
    User user = Provider.of<UserService>(context, listen: false).user;
    if (user == null) {
      delay();
      return Material(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: callService.getIncomingCall(user.uid),
      builder: (context, snapshot) {
        Call call;
        if (snapshot.hasData && snapshot.data.data != null) {
          call = Call.fromFirestore(snapshot.data);
          if (call.receiverUid == user.uid) cache.loop('ring.mp3');
        } else {
          if (player != null && player.state == AudioPlayerState.PLAYING)
            player.stop();
        }
        return snapshot.hasData && snapshot.data.data != null
            ? CallScreen(
                call: call,
                isCaller: false,
                audioPlayer: player,
              )
            : WillPopScope(
                onWillPop: onBackPressed,
                child: Scaffold(
                  backgroundColor: ConstantColor.white,
                  // appBar: setAppbar(),
                  body: CustomScrollView(
                    controller: scrollController,
                    physics: NeverScrollableScrollPhysics(),
                    // shrinkWrap: true,
                    slivers: [
                      SliverAppBar(
                        stretchTriggerOffset: 10,
                        onStretchTrigger: () async {
                          print('strechedddd');
                        },
                        stretch: true,
                        backgroundColor: color.primaryColor,
                        title: StyledText(
                          'Howdy',
                          size: 20,
                          weight: FontWeight.w500,
                        ),
                        floating: tabController.animation.value >= 1,
                        pinned: tabController.animation.value >= 1,
                        snap: tabController.animation.value >= 1,
                        bottom: TabBar(
                          controller: tabController,
                          tabs: mytab,
                          labelStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                          labelPadding: EdgeInsets.all(0),
                          indicatorPadding: EdgeInsets.all(0),
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorWeight: 3.5,
                          indicatorColor: ConstantColor.white,
                          unselectedLabelColor: Color(0x88ffffff),
                        ),
                        actions: <Widget>[
                          AppbarIcon(
                            icon: Icons.search,
                            size: 25,
                            onpressed: () {
                              setState(() {
                                appbarState = 2;
                              });
                            },
                          ),
                          PopupMenuButton(
                            padding: EdgeInsets.all(0),
                            icon: Icon(Icons.more_vert, size: 25),
                            onSelected: (value) {
                              if (value == 'theme') {
                                showColorPallete(color);
                              }
                            },
                            itemBuilder: (_) {
                              return showMore();
                            },
                          ),
                        ],
                      ),
                      SliverFillRemaining(
                        fillOverscroll: true,
                        hasScrollBody: true,
                        child: PrimaryScrollController(
                          controller: primaryScrollController,
                          child: TabBarView(
                            controller: tabController,
                            children: <Widget>[
                              CameraPreview(cameraController),
                              ChatScreen(),
                              StatusScreen(),
                              CallHistoryScreen(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  floatingActionButton: tabController.animation.value < 1
                      ? null
                      : index == 2
                          ? StatusFAB(
                              color: color.secondaryColor,
                            )
                          : FloatingActionButton(
                              backgroundColor: color.secondaryColor,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => PeopleScreen(
                                              isFromCall: index == 3,
                                            )));
                              },
                              child: Icon(
                                tabController.index == 1
                                    ? Icons.message
                                    : Icons.add_ic_call,
                                color: ConstantColor.white,
                              ),
                            ),
                ),
              );
      },
    );
  }
}

class StatusFAB extends StatelessWidget {
  StatusFAB({this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          mini: true,
          child: Icon(
            Icons.create,
            color: ConstantColor.grey,
          ),
          backgroundColor: Colors.grey[200],
          onPressed: () async {},
        ),
        SizedBox(height: 16),
        FloatingActionButton(
          backgroundColor: color,
          heroTag: 'camera',
          child: Icon(Icons.camera_alt),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => CameraScreen()));
          },
        ),
      ],
    );
  }
}
