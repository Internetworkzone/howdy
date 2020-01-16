import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const Color black = Colors.black;
const Color white = Colors.white;

const Color purple = Color(0xff536dfe);
const Color lightOrange = Color(0xffff8a80);
const Color pink = Color(0xfff50057);
const Color green = Color(0xff00bfa5);
const Color blue = Color(0xff0d47a1);
const Color seaBlue = Color(0xff00bcd4);
const Color greyBlue = Color(0xff37474f);

final textStyle = TextStyle(
  color: white,
  fontSize: 25,
  fontWeight: FontWeight.w600,
);

final Firestore firestore = Firestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
