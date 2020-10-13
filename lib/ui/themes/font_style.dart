import 'package:flutter/material.dart';
import 'package:howdy/ui/themes/colors.dart';

class StyledText extends StatelessWidget {
  StyledText(
    this.text, {
    this.color = ConstantColor.white,
    this.size = 18,
    this.weight = FontWeight.normal,
  });
  final String text;
  final Color color;
  final double size;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontWeight: weight,
        fontSize: size,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class BlackText extends StatelessWidget {
  BlackText(
    this.text, {
    this.size = 18,
    this.weight = FontWeight.normal,
  });
  final String text;
  final double size;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: ConstantColor.black,
        fontWeight: weight,
        fontSize: size,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class TabTextStyle {
  static final TextStyle textStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
  );
}

class TextFieldStyle {
  static final TextStyle textStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
  );
}
