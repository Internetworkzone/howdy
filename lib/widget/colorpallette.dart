import 'package:flutter/material.dart';
import 'package:howdy/modals/constants.dart';

class ColorPallete extends StatelessWidget {
  const ColorPallete({
    this.ontap1,
    this.ontap2,
    this.ontap3,
    this.ontap4,
    this.ontap5,
    this.ontap6,
    this.ontap7,
    // this.showColorPallette,
    this.palletteColor,
  });

  final ontap1;
  final ontap2;
  final ontap3;
  final ontap4;
  final ontap5;
  final ontap6;
  final ontap7;
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
                        color: purple,
                        ontap: ontap1,
                      ),
                      ColorCircle(
                        color: lightOrange,
                        ontap: ontap2,
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
                        color: pink,
                        ontap: ontap3,
                      ),
                      ColorCircle(
                        color: blue,
                        ontap: ontap4,
                      ),
                      ColorCircle(
                        color: green,
                        ontap: ontap5,
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
                        color: greyBlue,
                        ontap: ontap6,
                      ),
                      ColorCircle(
                        color: seaBlue,
                        ontap: ontap7,
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
