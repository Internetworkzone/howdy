import 'package:flutter/material.dart';
import 'package:howdy/modals/constants.dart';
import 'package:howdy/services/color_service.dart';

class ColorPallete extends StatelessWidget {
  const ColorPallete({
    this.ontap,

    // this.showColorPallette,
    this.palletteColor = black,
  });

  final Function(int color) ontap;

  final Color palletteColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Container(
            height: 320,
            width: 320,
            decoration: ShapeDecoration(
              shape: CircleBorder(
                side: BorderSide(
                  color: palletteColor,
                  width: 3,
                ),
              ),
              color: palletteColor,
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      SizedBox.shrink(),
                      ColorCircle(
                        color: PrimaryColor.red,
                        ontap: () => ontap(1),
                      ),
                      ColorCircle(
                        color: PrimaryColor.orange,
                        ontap: () => ontap(2),
                      ),
                      SizedBox.shrink()
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ColorCircle(
                        color: PrimaryColor.grey,
                        ontap: () => ontap(3),
                      ),
                      ColorCircle(
                        color: PrimaryColor.teal,
                        ontap: () => ontap(4),
                      ),
                      ColorCircle(
                        color: PrimaryColor.pink,
                        ontap: () => ontap(5),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox.shrink(),
                      ColorCircle(
                        color: PrimaryColor.yellow,
                        ontap: () => ontap(6),
                      ),
                      ColorCircle(
                        color: PrimaryColor.purple,
                        ontap: () => ontap(7),
                      ),
                      SizedBox.shrink()
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ColorCircle extends StatelessWidget {
  const ColorCircle({
    this.color,
    this.ontap,
  });

  final Color color;
  final ontap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 80,
        width: 80,
        decoration: ShapeDecoration(
          shape: CircleBorder(
            side: BorderSide(
              color: white,
              width: 3,
            ),
          ),
          color: color,
        ),
      ),
      onTap: ontap,
    );
  }
}
