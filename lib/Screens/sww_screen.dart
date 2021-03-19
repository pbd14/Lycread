import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

// ignore: must_be_immutable
class SomethingWentWrongScreen extends StatelessWidget {
  String error;
  SomethingWentWrongScreen({Key key, this.error : 'Something Went Wrong'})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Text(
            error,
            style: GoogleFonts.montserrat(
              textStyle: TextStyle(
                color: primaryColor,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
