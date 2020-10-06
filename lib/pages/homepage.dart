import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:howdy/modals/user.dart';
import 'package:howdy/pages/chatscreen.dart';
import 'package:howdy/pages/groupscreen.dart';
import 'package:howdy/pages/loginpage.dart';
import 'package:howdy/pages/people.dart';
import 'package:howdy/pages/profilepage.dart';
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
  // bool showColorPalette = false;

  AppBar setAppbar() {
    final color = Provider.of<ColorService>(context, listen: false);

    if (appbarState == 1) {
      return AppBar(
        backgroundColor: color.primaryColor,
        title: Text(
          'Howdy',
          style: TextStyle(color: color.secondaryColor),
        ),
        actions: <Widget>[
          AppbarIcon(
            icon: FontAwesomeIcons.search,
            color: color.secondaryColor,
            onpressed: () {
              setState(() {
                appbarState = 2;
              });
            },
          ),
          AppbarIcon(
            icon: FontAwesomeIcons.solidLightbulb,
            color: color.bulbColor,
            onpressed: () => color.setColorMode(),
          ),
          AppbarIcon(
            icon: FontAwesomeIcons.solidBell,
            color: color.secondaryColor,
            onpressed: () {},
          ),
          AppbarIcon(
            icon: FontAwesomeIcons.userAlt,
            color: color.secondaryColor,
            onpressed: () => gotoProfile(),
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
        leading: AppbarIcon(
          icon: FontAwesomeIcons.arrowLeft,
          color: color.secondaryColor,
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
    User user = Provider.of<UserService>(context, listen: false).user;

    if (user.uid == null) {
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
    getUserDetails();
  }

  showColorPallete(ColorService color) {
    return showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (_) => ColorPallete(
        ontap1: () => color.setColor(ColorId().purple),
        ontap2: () => color.setColor(ColorId().lightOrange),
        ontap3: () => color.setColor(ColorId().pink),
        ontap4: () => color.setColor(ColorId().blue),
        ontap5: () => color.setColor(ColorId().green),
        ontap6: () => color.setColor(ColorId().greyBlue),
        ontap7: () => color.setColor(ColorId().seaBlue),
        palletteColor: color.bulbColor,
      ),
    );
  }

  getUserDetails() async {
    UserService userService = UserService();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String uid = preferences.getString('uid');
    bool dark = preferences.getBool('isDarkMode');
    int color = preferences.getInt('color');
    Provider.of<ColorService>(context, listen: false).darkMode = dark ?? false;
    Provider.of<ColorService>(context, listen: false).setColor(color ?? 1);
    Provider.of<UserService>(context, listen: false).user =
        await userService.updateUser(uid);
  }

  @override
  Widget build(BuildContext context) {
    final color = Provider.of<ColorService>(context);

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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: color.bulbColor,
        onPressed: () => showColorPallete(color),
        child: Icon(
          FontAwesomeIcons.palette,
          color: color.primaryColor,
        ),
      ),
    );
  }
}
