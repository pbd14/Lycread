import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 200),
          Center(
            child: Text(
              'Dashboard Screen',
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
