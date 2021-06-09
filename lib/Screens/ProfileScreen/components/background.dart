import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: size.width,
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //     begin: Alignment.topCenter,
            //     end: Alignment.bottomCenter,
            //     stops: [0, 0.8],
            //     colors: [Color.fromRGBO(33, 33, 33, 0), primaryColor],
            //   ),
            // ),
            child: Image.asset(
              'assets/images/membership_screen.jpg',
              fit: BoxFit.cover,
              height: size.height,
              width: size.width,
            ),
          ),
          Container(width: size.width, child: child),
        ],
      ),
    );
  }
}
