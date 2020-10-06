import 'package:flutter/material.dart';
import 'package:howdy/modals/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorId {
  int purple = 1;
  int lightOrange = 2;
  int pink = 3;
  int blue = 4;
  int green = 5;
  int greyBlue = 6;
  int seaBlue = 7;
}

class PrimaryColor {
  static final Color teal = Colors.teal[800];
  static final Color red = Colors.red[800];
  static final Color purple = Colors.purple[800];
  static final Color orange = Colors.orange[800];
  static final Color grey = Colors.grey[800];
  static final Color yellow = Colors.yellow[800];
  static final Color pink = Colors.pink[800];

  Color getPrimaryColor() {
    int color;
    Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    prefs.then((value) {
      color = value.getInt('color');
    });
    return ColorService().setColor(color);
  }
}

class SecondaryColor {
  static final Color teal = Colors.tealAccent[400];
  static final Color red = Colors.redAccent[400];
  static final Color purple = Colors.purpleAccent[400];
  static final Color orange = Colors.orangeAccent[400];
  static final Color grey = Colors.black;
  static final Color yellow = Colors.yellowAccent[400];
  static final Color pink = Colors.pinkAccent[400];
}

class BubbleColor {
  static final Color teal = Color(0xffe1ffc7);
  static final Color red = Colors.red[100];
  static final Color purple = Colors.purple[100];
  static final Color orange = Colors.orange[100];
  static final Color grey = Colors.grey[100];
  static final Color yellow = Colors.yellow[100];
  static final Color pink = Colors.pink[100];
}

class ColorService extends ChangeNotifier {
  Color primaryColor = PrimaryColor.teal;
  Color secondaryColor = white;
  Color bubbleColor = white;

  Color setColor(int colorId) {
    Future<SharedPreferences> preferences = SharedPreferences.getInstance();

    switch (colorId) {
      case 1:
        primaryColor = PrimaryColor.red;
        secondaryColor = SecondaryColor.red;
        bubbleColor = BubbleColor.red;

        break;
      case 2:
        primaryColor = PrimaryColor.orange;
        secondaryColor = SecondaryColor.orange;
        bubbleColor = BubbleColor.orange;

        break;
      case 3:
        primaryColor = PrimaryColor.grey;
        secondaryColor = SecondaryColor.grey;
        bubbleColor = BubbleColor.grey;

        break;
      case 4:
        primaryColor = PrimaryColor.teal;
        secondaryColor = SecondaryColor.teal;
        bubbleColor = BubbleColor.teal;

        break;
      case 5:
        primaryColor = PrimaryColor.pink;
        secondaryColor = SecondaryColor.pink;
        bubbleColor = BubbleColor.pink;

        break;
      case 6:
        primaryColor = PrimaryColor.yellow;
        secondaryColor = SecondaryColor.yellow;
        bubbleColor = BubbleColor.yellow;

        break;
      case 7:
        primaryColor = PrimaryColor.purple;
        secondaryColor = SecondaryColor.purple;
        bubbleColor = BubbleColor.purple;

        break;
    }

    preferences.then((value) => value.setInt('color', colorId));
    notifyListeners();
    return primaryColor;
  }
}
