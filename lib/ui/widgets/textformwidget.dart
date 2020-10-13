import 'package:flutter/material.dart';
import 'package:howdy/ui/themes/colors.dart';
import 'package:howdy/ui/themes/font_style.dart';

class TextFormWidget extends StatelessWidget {
  const TextFormWidget({this.onchanged, this.hintText, this.obscure = false});

  final String hintText;
  final onchanged;
  final obscure;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 15, bottom: 15, left: 30, right: 30),
      child: TextField(
        obscureText: obscure,
        style: TextFieldStyle.textStyle,
        onChanged: onchanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextFieldStyle.textStyle,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        cursorColor: ConstantColor.white,
      ),
    );
  }
}
