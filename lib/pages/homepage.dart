import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:howdy/modals/colorstate.dart';
import 'package:howdy/modals/constants.dart';
import 'package:howdy/modals/userstate.dart';
import 'package:howdy/pages/chatscreen.dart';
import 'package:howdy/pages/groupscreen.dart';
import 'package:howdy/pages/loginpage.dart';
import 'package:howdy/pages/people.dart';
import 'package:howdy/pages/profilepage.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int appbarState = 1;
  TabController tabController;
  bool showColorPalette = false;
  bool darkMode = false;

  Widget setAppbar() {
    final color = Provider.of<ColorState>(context, listen: false);

    if (appbarState == 1) {
      return AppBar(
        backgroundColor: color.primaryColor,
        title: Text(
          'Howdy',
          style: TextStyle(color: color.secondaryColor),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              FontAwesomeIcons.search,
              color: color.secondaryColor,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                appbarState = 2;
              });
            },
          ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.solidLightbulb,
              color: color.bulbColor,
              size: 20,
            ),
            onPressed: () {
              darkMode = darkMode == true ? false : true;
              color.setColorMode(darkMode);
            },
          ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.userAlt,
              color: color.secondaryColor,
              size: 20,
            ),
            onPressed: () {
              gotoProfile();
            },
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: mytab,
          labelStyle: TextStyle(fontSize: 22),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: color.secondaryColor,
          unselectedLabelColor: color.secondaryColor,
          labelColor: color.secondaryColor,
        ),
        elevation: 20,
      );
    } else {
      return AppBar(
        backgroundColor: color.primaryColor,
        leading: IconButton(
          icon: Icon(
            FontAwesomeIcons.arrowLeft,
            color: color.secondaryColor,
          ),
          onPressed: () {
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
              color: color.secondaryColor,
            ),
          ),
        ),
        elevation: 20,
      );
    }
  }

  List<Tab> mytab = [
    Tab(text: 'People'),
    Tab(text: 'Chats'),
    Tab(text: 'Groups'),
  ];

  void gotoProfile() {
    final user = Provider.of<UserState>(context, listen: false);

    if (user.currentUserId == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfilePage(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    tabController =
        TabController(vsync: this, initialIndex: 0, length: mytab.length);
  }

  @override
  Widget build(BuildContext context) {
    final color = Provider.of<ColorState>(context);
    return Scaffold(
      backgroundColor: color.primaryColor,
      appBar: setAppbar(),
      body: Stack(
        children: <Widget>[
          TabBarView(
            controller: tabController,
            children: <Widget>[
              PeopleScreen(),
              ChatScreen(),
              GroupScreen(),
            ],
          ),
          Stacked(
            showColorPallette: showColorPalette,
            ontap1: () => color.setColor(colorNum: 1, mode: darkMode),
            ontap2: () => color.setColor(colorNum: 2, mode: darkMode),
            ontap3: () => color.setColor(colorNum: 3, mode: darkMode),
            ontap4: () => color.setColor(colorNum: 4, mode: darkMode),
            ontap5: () => color.setColor(colorNum: 5, mode: darkMode),
            ontap6: () => color.setColor(colorNum: 6, mode: darkMode),
            ontap7: () => color.setColor(colorNum: 7, mode: darkMode),
            palletteColor: color.bulbColor,
            ontap: () {
              setState(() {
                showColorPalette = false;
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: color.bulbColor,
        onPressed: () {
          setState(() {
            showColorPalette = showColorPalette == true ? false : true;
          });
        },
        child: Icon(
          FontAwesomeIcons.palette,
          color: color.primaryColor,
        ),
      ),
    );
  }
}

class Stacked extends StatelessWidget {
  const Stacked({
    this.ontap1,
    this.ontap2,
    this.ontap3,
    this.ontap4,
    this.ontap5,
    this.ontap6,
    this.ontap7,
    this.showColorPallette,
    this.ontap,
    this.palletteColor,
  });

  final ontap1;
  final ontap2;
  final ontap3;
  final ontap4;
  final ontap5;
  final ontap6;
  final ontap7;
  final ontap;
  final Color palletteColor;

  final bool showColorPallette;

  @override
  Widget build(
    BuildContext context,
  ) {
    if (showColorPallette == false) {
      return Container();
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Container(
              height: 320,
              width: 320,
              decoration: ShapeDecoration(
                shape: CircleBorder(
                  side: BorderSide(
                    color: palletteColor,
                    width: 3,
                  ),
                ),
                color: palletteColor,
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        SizedBox.shrink(),
                        ColorPalette(
                          color: purple,
                          ontap: ontap1,
                        ),
                        ColorPalette(
                          color: lightOrange,
                          ontap: ontap2,
                        ),
                        SizedBox.shrink()
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ColorPalette(
                          color: pink,
                          ontap: ontap3,
                        ),
                        ColorPalette(
                          color: blue,
                          ontap: ontap4,
                        ),
                        ColorPalette(
                          color: green,
                          ontap: ontap5,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox.shrink(),
                        ColorPalette(
                          color: greyBlue,
                          ontap: ontap6,
                        ),
                        ColorPalette(
                          color: seaBlue,
                          ontap: ontap7,
                        ),
                        SizedBox.shrink()
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      );
    }
  }
}

class ColorPalette extends StatelessWidget {
  const ColorPalette({
    this.color,
    this.ontap,
  });

  final Color color;
  final ontap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 80,
        width: 80,
        decoration: ShapeDecoration(
          shape: CircleBorder(
            side: BorderSide(
              color: white,
              width: 3,
            ),
          ),
          color: color,
        ),
      ),
      onTap: ontap,
    );
  }
}
