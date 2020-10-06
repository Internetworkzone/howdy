import 'package:flutter/material.dart';

class AppbarIcon extends StatelessWidget {
  const AppbarIcon({
    this.color,
    this.onpressed,
    this.icon,
    this.size = 20,
  });

  final Color color;
  final Function onpressed;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: color,
        size: size,
      ),
      onPressed: onpressed,
    );
  }
}
