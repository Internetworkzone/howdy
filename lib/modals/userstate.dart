import 'package:flutter/material.dart';
import 'package:howdy/modals/constants.dart';

class UserState extends ChangeNotifier {
  String currentUserId;
  String currentUserName;

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  Future<void> signout() async {
    await auth.signOut();
  }
}
