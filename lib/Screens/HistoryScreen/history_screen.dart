import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 200),
          Center(
            child: Text(
              'History Screen',
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
