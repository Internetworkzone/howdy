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

class ColorService extends ChangeNotifier {
  Color primaryColor = purple;
  Color lightprimaryColor = purple;
  Color secondaryColor = white;
  Color bulbColor = black;
  bool darkMode = false;

  setColorMode() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    darkMode = !darkMode;
    primaryColor = darkMode ? black : lightprimaryColor;
    secondaryColor = darkMode ? lightprimaryColor : white;
    bulbColor = darkMode ? white : black;
    notifyListeners();
    preferences.setBool('isDarkMode', darkMode);
    print('called set darkmode');
    print('color is $primaryColor');
  }

  setColor(int colorId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    switch (colorId) {
      case 1:
        lightprimaryColor = purple;
        break;
      case 2:
        lightprimaryColor = lightOrange;
        break;
      case 3:
        lightprimaryColor = pink;
        break;
      case 4:
        lightprimaryColor = blue;
        break;
      case 5:
        lightprimaryColor = green;
        break;
      case 6:
        lightprimaryColor = greyBlue;
        break;
      case 7:
        lightprimaryColor = seaBlue;
        break;
    }

    primaryColor = darkMode ? black : lightprimaryColor;
    secondaryColor = darkMode ? lightprimaryColor : white;
    bulbColor = darkMode ? white : black;

    preferences.setInt('color', colorId);
    notifyListeners();
  }
}
