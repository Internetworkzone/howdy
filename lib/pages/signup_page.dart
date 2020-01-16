import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:howdy/modals/colorstate.dart';
import 'package:howdy/modals/constants.dart';
import 'package:howdy/pages/homepage.dart';
import 'package:provider/provider.dart';
import 'package:howdy/widget/textformwidget.dart';

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

  Future registerUser() async {
    try {
      final signupUser = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (signupUser.user.uid != null) {
        firestore.collection('users').document(signupUser.user.uid).setData({
          'id': signupUser.user.uid,
          'name': name,
          'email': email,
          'timestamp': Timestamp.now(),
        });
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Provider.of<ColorState>(context);
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
                  color: white,
                  onPressed: () => registerUser(),
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
