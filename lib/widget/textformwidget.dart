import 'package:flutter/material.dart';
import 'package:howdy/modals/constants.dart';

class TextFormWidget extends StatelessWidget {
  const TextFormWidget({this.onchanged, this.hintText, this.obscure = false});

  final String hintText;
  final onchanged;
  final obscure;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 15, bottom: 15, left: 30, right: 30),
      child: TextFormField(
        obscureText: obscure,
        style: textStyle,
        onChanged: onchanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: textStyle,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          hasFloatingPlaceholder: true,
        ),
        cursorColor: white,
      ),
    );
  }
}
