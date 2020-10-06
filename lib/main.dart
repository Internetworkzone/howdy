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
  SharedPreferences preferences = await SharedPreferences.getInstance();
  bool isDarkMode = preferences.getBool('isDarkMode');
  if (isDarkMode != null && isDarkMode) ColorService().setColorMode();
  int color = preferences.getInt('color');

  runApp(MyApp(
    color: color,
    darkMode: isDarkMode,
  ));
}

class MyApp extends StatelessWidget {
  MyApp({this.color, this.darkMode});
  final int color;
  final bool darkMode;
  Widget getUserState() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomePage();
        } else if (snapshot.data != null) {
          return LoginPage();
        } else {
          return Material(child: CircularProgressIndicator());
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
