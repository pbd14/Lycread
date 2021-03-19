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
    return Container(
      width: pw == null ? size.width * width : pw,
      height: ph == null ? size.height * height : ph,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlatButton(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          color: color,
          onPressed: press,
          child: Text(
            text,
            style: GoogleFonts.montserrat(
                textStyle: TextStyle(
              color: textColor,
            )),
          ),
        ),
      ),
    );
  }
}
