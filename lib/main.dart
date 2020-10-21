import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:howdy/ui/screens/homepage.dart';
import 'package:howdy/ui/screens/loginpage.dart';
import 'package:howdy/services/color_service.dart';
import 'package:howdy/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();

  runApp(MyApp(uid: preferences.getString('uid')));
}

class MyApp extends StatelessWidget {
  MyApp({this.uid});
  final String uid;

  Widget getUserState() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data != null && uid == null) {
          return LoginPage();
        } else {
          return HomePage();
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
