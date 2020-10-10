import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:howdy/pages/homepage.dart';
import 'package:howdy/pages/loginpage.dart';
import 'package:howdy/services/color_service.dart';
import 'package:howdy/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  isLoggedIn() {
    String uid;
    Future<SharedPreferences> preferences = SharedPreferences.getInstance();
    preferences.then((value) {
      uid = value.getString('uid');
    });

    return uid != null;
  }

  getUserDetails() {}

  Widget getUserState() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomePage();
        } else if (snapshot.data != null) {
          return LoginPage();
        } else {
          return isLoggedIn() ? HomePage() : LoginPage();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ColorService()),
        ChangeNotifierProvider(create: (_) => UserService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Howdy',
        home: getUserState(),
      ),
    );
  }
}
