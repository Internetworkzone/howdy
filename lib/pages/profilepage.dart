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
    final color = Provider.of<ColorState>(context);
    final user = Provider.of<UserState>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.primaryColor,
      ),
      body: Center(
        child: MaterialButton(
          color: color.primaryColor,
          height: 50,
          minWidth: 190,
          child: Text('Logout'),
          onPressed: () {
            user.signout();
            Navigator.push(context, MaterialPageRoute(builder: (_) => MyApp()));
          },
        ),
      ),
    );
  }
}
