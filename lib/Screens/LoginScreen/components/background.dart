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
            //     begin: Alignment.topCenter,
            //     end: Alignment.bottomCenter,
            //     stops: [0, 0.8],
            //     colors: [Color.fromRGBO(33, 33, 33, 0), primaryColor],
            //   ),
            // ),
            child: Image.asset(
              'assets/images/login_screen.jpg',
              fit: BoxFit.fill,
              height: size.height,
              width: size.width,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
