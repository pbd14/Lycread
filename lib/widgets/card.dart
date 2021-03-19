import 'package:flutter/material.dart';
import '../constants.dart';

// ignore: must_be_immutable
class CardW extends StatelessWidget {
  double height, width, pw, ph;
  Widget child;
  Color bgColor;
  Color shadow;
  CardW(
      {Key key,
      this.height,
      this.width,
      this.child,
      this.pw,
      this.ph,
      this.bgColor: whiteColor,
      this.shadow: darkPrimaryColor})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      height: ph == null ? size.height * height : ph,
      child: Card(
        color: bgColor,
        shadowColor: shadow,
        elevation: 10,
        child: child,
      ),
    );
  }
}
