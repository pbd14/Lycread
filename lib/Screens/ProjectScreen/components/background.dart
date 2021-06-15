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
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //     begin: Alignment.bottomCenter,
            //     end: Alignment.topCenter,
            //     stops: [0, 0.8],
            //     colors: [Color.fromRGBO(33, 33, 33, 0), darkPrimaryColor],
            //   ),
            // ),
            child: Image.asset(
              'assets/images/hub_screen.jpg',
              fit: BoxFit.cover,
              height: size.height,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
