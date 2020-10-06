import 'package:flutter/material.dart';
import 'package:howdy/modals/user.dart';
import 'package:howdy/services/auth_service.dart';
import 'package:howdy/services/color_service.dart';
import 'package:howdy/services/user_service.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final color = Provider.of<ColorService>(context, listen: false);
    User user = Provider.of<UserService>(context, listen: false).user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.primaryColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          MaterialButton(
              color: color.primaryColor,
              height: 50,
              minWidth: 190,
              child: Text(
                'check',
                style: TextStyle(color: color.secondaryColor, fontSize: 25),
              ),
              onPressed: () {
                setState(() {
                  // user.getUserDetail();
                });
              }),
          Text(
            user.name ?? 'Not found',
            style: TextStyle(color: color.primaryColor, fontSize: 25),
          ),
          Text(
            user.email,
            style: TextStyle(color: color.primaryColor, fontSize: 25),
          ),
          Center(
            child: MaterialButton(
                color: color.primaryColor,
                height: 50,
                minWidth: 190,
                child: Text(
                  'Log Out',
                  style: TextStyle(color: color.secondaryColor, fontSize: 25),
                ),
                onPressed: () {
                  AuthService().signOutUser();
                  Navigator.pop(context);
                }),
          ),
        ],
      ),
    );
  }
}
