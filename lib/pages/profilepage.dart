import 'package:flutter/material.dart';
import 'package:howdy/main.dart';
import 'package:howdy/modals/colorstate.dart';
import 'package:howdy/modals/userstate.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final color = Provider.of<ColorState>(context, listen: false);
    final user = Provider.of<UserState>(context, listen: false);

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
              onPressed: () => user.getUserDetail()),
          Text(
            user.currentUserName ?? 'Not found',
            style: TextStyle(color: color.primaryColor, fontSize: 25),
          ),
          Text(
            user.currentUserEmailId,
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
                onPressed: () => user.signout()),
          ),
        ],
      ),
    );
  }
}
