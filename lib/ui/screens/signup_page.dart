import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:howdy/services/auth_service.dart';
import 'package:howdy/services/color_service.dart';
import 'package:howdy/ui/themes/colors.dart';
import 'package:provider/provider.dart';
import 'package:howdy/ui/widgets/textformwidget.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String name;
  String email;
  String password;
  FirebaseAuth auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;

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
                  hintText: 'Name',
                  onchanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                ),
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
                    'Register',
                    style: TextStyle(fontSize: 40),
                  ),
                  color: ConstantColor.white,
                  onPressed: () {
                    AuthService().createNewAccount(email, password, name);

                    Navigator.pop(context);
                  },
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  splashColor: color.primaryColor,
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
