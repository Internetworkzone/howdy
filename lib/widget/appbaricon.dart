import 'package:flutter/material.dart';

class AppbarIcon extends StatelessWidget {
  const AppbarIcon({@required this.color, this.onpressed, this.icon});

  final Color color;
  final Function onpressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: color,
        size: 20,
      ),
      onPressed: onpressed,
    );
  }
}
