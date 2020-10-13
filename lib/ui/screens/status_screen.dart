import 'package:flutter/material.dart';
import 'package:howdy/ui/screens/chatscreen.dart';

class StatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CardTile(
          title: 'My status',
          subTitle: 'Tap to add status update',
        ),
      ],
    );
  }
}
