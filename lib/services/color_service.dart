import 'package:flutter/material.dart';
import 'package:howdy/ui/themes/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorService extends ChangeNotifier {
  Color primaryColor = PrimaryColor.teal;
  Color secondaryColor = ConstantColor.white;
  Color bubbleColor = ConstantColor.white;

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
