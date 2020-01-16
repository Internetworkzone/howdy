import 'package:flutter/material.dart';
import 'package:howdy/pages/homepage.dart';
import 'package:howdy/pages/loginpage.dart';
import 'package:howdy/services/authservice.dart';
import 'package:provider/provider.dart';

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Authservice>(context);
    return StreamBuilder(
      stream: auth.onAuthChange,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.active) {
          final user = snap.data;
          if (user != null) {
            return Provider(create: (_) => CurrentUser(), child: HomePage());
          } else {
            return LoginPage();
          }
        }
        return Text('No user');
      },
    );
  }
}
