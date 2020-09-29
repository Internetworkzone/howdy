import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:howdy/modals/colorstate.dart';
import 'package:howdy/modals/userstate.dart';
import 'package:howdy/pages/homepage.dart';
import 'package:howdy/pages/signup_page.dart';
import 'package:howdy/pages/loginpage.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Widget getUserState() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        print(snapshot.data);
        if (snapshot.hasData) {
          Provider.of<UserState>(context).currentUserId = snapshot.data.uid;
          Provider.of<UserState>(context).currentUserEmailId =
              snapshot.data.email;
          // Provider.of<UserState>(context).getUserDetail();
          return HomePage();
        } else {
          print('login');
          return LoginPage();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserState(),
        ),
        ChangeNotifierProvider(
          create: (_) => ColorState(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Howdy',
        home: getUserState(),
      ),
    );
  }
}
