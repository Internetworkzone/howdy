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

/// WhatsApp's signature green color.
final Color darkColor = const Color(0xff102e30);
final Color primaryColor = const Color(0xff075e54);

/// Secondary green color.
final Color secondaryColor = const Color(0xff00897b);
final Color highlightColor = const Color(0xff357c74);

/// White-ish background color.
final Color scaffoldBgColor = const Color(0xfffafafa);

/// FloatingActionButton's background color
final Color fabBgColor = const Color(0xff20c659);
final Color fabBgSecondaryColor = const Color(0xff507578);

final Color lightGrey = const Color(0xffe2e8ea);

final Color profileDialogBgColor = const Color(0xff73bfb8);
final Color profileDialogIconColor = const Color(0xff8ac9c3);

final Color chatDetailScaffoldBgColor = const Color(0xffe7e2db);

final Color iconColor = const Color(0xff858b90);
final Color textFieldHintColor = const Color(0xffcdcdcd);

final Color messageBubbleColor = const Color(0xffe1ffc7);
final Color blueCheckColor = const Color(0xff3fbbec);

final Color statusThumbnailBorderColor = const Color(0xff21bfa6);

final Color notificationBadgeColor = const Color(0xff08d160);
