import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;
  final double width, height, pw, ph;
  const RoundedButton(
      {Key key,
      this.text,
      this.press,
      this.color,
      this.textColor,
      this.width,
      this.height,
      this.pw,
      this.ph})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return TextButton(
      onPressed: press,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: pw == null ? size.width * width : pw,
          height: ph == null ? size.height * height : ph,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          color: color,
          child: Center(
            child: Text(
              text,
              textScaleFactor: 1,
              style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                color: textColor,
              )),
            ),
          ),
        ),
      ),
    );
  }
}
