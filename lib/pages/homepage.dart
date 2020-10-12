import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:howdy/modals/call.dart';
import 'package:howdy/modals/constants.dart';
import 'package:howdy/modals/user.dart';
import 'package:howdy/pages/call_history_screen.dart';
import 'package:howdy/pages/call_screen.dart';
import 'package:howdy/pages/chatscreen.dart';
import 'package:howdy/pages/groupscreen.dart';
import 'package:howdy/pages/people.dart';
import 'package:howdy/services/call_service.dart';
import 'package:howdy/services/color_service.dart';
import 'package:howdy/services/user_service.dart';
import 'package:howdy/widget/appbaricon.dart';
import 'package:howdy/widget/colorpallette.dart';
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

  AppBar setAppbar() {
    final color = Provider.of<ColorService>(context, listen: false);

    if (appbarState == 1) {
      return AppBar(
        backgroundColor: color.primaryColor,
        title: Text(
          'Howdy',
        ),
        actions: <Widget>[
          AppbarIcon(
            icon: FontAwesomeIcons.search,
            onpressed: () {
              setState(() {
                appbarState = 2;
              });
            },
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, size: 30),
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
        bottom: TabBar(
          controller: tabController,
          tabs: mytab,
          labelStyle: TextStyle(fontSize: 17),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3.5,
          indicatorColor: white,
          unselectedLabelColor: Color(0x88ffffff),
        ),
        elevation: 20,
      );
    } else {
      return AppBar(
        backgroundColor: color.primaryColor,
        leading: AppbarIcon(
          icon: FontAwesomeIcons.arrowLeft,
          onpressed: () {
            setState(() {
              appbarState = 1;
            });
          },
        ),
        title: TextField(
          style: TextStyle(color: color.secondaryColor),
          decoration: InputDecoration(
            disabledBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: 'Search',
            hintStyle: TextStyle(
              color: white,
            ),
          ),
        ),
        elevation: 20,
      );
    }
  }

  List<Tab> mytab = [
    Tab(text: 'CHATS'),
    Tab(text: 'STATUS'),
    Tab(text: 'CALLS'),
  ];

  showMore() {
    return [
      PopupMenuItem(
          textStyle: TextStyle(
            fontSize: 18,
            color: black,
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
        TabController(vsync: this, initialIndex: 0, length: mytab.length);
    getUserDetails();
    cache = AudioCache(
      fixedPlayer: player,
    );
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
    Provider.of<ColorService>(context, listen: false).setColor(color ?? 1);
    Provider.of<UserService>(context, listen: false).user =
        await userService.updateUser(uid);
  }

  delay() async {
    await Future.delayed(Duration(seconds: 5));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
          cache.loop('ring.mp3');
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
            : Scaffold(
                backgroundColor: white,
                appBar: setAppbar(),
                body: Stack(
                  children: <Widget>[
                    TabBarView(
                      controller: tabController,
                      children: <Widget>[
                        ChatScreen(),
                        PeopleScreen(),
                        CallHistoryScreen(),
                      ],
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: color.secondaryColor,
                  onPressed: () {
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (_) => PeopleScreen()));
                    SystemChannels.platform.invokeMethod('method');
                  },
                  child: Icon(
                    tabController.index == 0
                        ? Icons.message
                        : tabController.index == 1
                            ? Icons.camera_alt
                            : Icons.call,
                    color: white,
                  ),
                ),
              );
      },
    );
  }
}
