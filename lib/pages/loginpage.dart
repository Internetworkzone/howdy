import 'package:flutter/material.dart';
import 'package:howdy/modals/constants.dart';
import 'package:howdy/pages/signup_page.dart';
import 'package:howdy/services/auth_service.dart';
import 'package:howdy/services/color_service.dart';
import 'package:provider/provider.dart';
import 'package:howdy/widget/textformwidget.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email;
  String password;
  String loggedInUser;

  @override
  Widget build(BuildContext context) {
    final color = Provider.of<ColorService>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.primaryColor,
        elevation: 0,
      ),
      backgroundColor: color.primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormWidget(
                  hintText: 'Email',
                  onchanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                ),
                TextFormWidget(
                  obscure: true,
                  hintText: 'Password',
                  onchanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                MaterialButton(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 80, right: 80),
                  child: Text(
                    'Log In',
                    style: TextStyle(fontSize: 40),
                  ),
                  color: white,
                  onPressed: () {
                    AuthService().signInUser(email, password);
                  },
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  splashColor: color.primaryColor,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: white,
                    fontSize: 25,
                  ),
                ),
                MaterialButton(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 80, right: 80),
                  child: Text(
                    'Register here',
                    style: TextStyle(fontSize: 30, color: white),
                  ),
                  color: color.primaryColor,
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => SignupPage())),
                  splashColor: white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
