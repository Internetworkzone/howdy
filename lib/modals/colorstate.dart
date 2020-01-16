import 'package:flutter/material.dart';
import 'package:howdy/modals/constants.dart';

class ColorState with ChangeNotifier {
  Color primaryColor = purple;
  Color lightprimaryColor = purple;
  Color secondaryColor = white;
  Color bulbColor = black;

  setColorMode(darkMode) {
    primaryColor = darkMode ? black : lightprimaryColor;
    secondaryColor = darkMode ? lightprimaryColor : white;
    bulbColor = darkMode ? white : black;
    notifyListeners();
  }

  setColor({@required int colorNum, mode}) {
    switch (colorNum) {
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

    notifyListeners();

    setColorMode(mode);
  }
}
