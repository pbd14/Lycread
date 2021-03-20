import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants.dart';

class SearchScreenG extends StatefulWidget {
  String data;
  SearchScreenG({Key key, this.data}) : super(key: key);
  @override
  _SearchScreenGState createState() => _SearchScreenGState();
}

class _SearchScreenGState extends State<SearchScreenG> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 200),
          Center(
            child: Text(
              'Search Screen General',
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                  color: darkPrimaryColor,
                  fontSize: 35,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
