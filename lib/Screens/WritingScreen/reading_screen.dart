import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants.dart';
import '../loading_screen.dart';

class ReadingScreen extends StatefulWidget {
  QueryDocumentSnapshot data;
  String author;
  ReadingScreen({Key key, this.data, this.author}) : super(key: key);
  @override
  _ReadingScreenState createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            // appBar: AppBar(
            //   elevation: 10,
            //   toolbarHeight: size.height * 0.1,
            //   backgroundColor: whiteColor,
            //   title: Text(
            //     widget.data.data()['name'],
            //     textScaleFactor: 1,
            //     overflow: TextOverflow.ellipsis,
            //     style: GoogleFonts.montserrat(
            //       textStyle: TextStyle(
            //           color: darkPrimaryColor,
            //           fontSize: 30,
            //           fontWeight: FontWeight.bold),
            //     ),
            //   ),
            // ),
            body: SingleChildScrollView(
                child: Container(
              padding: EdgeInsets.fromLTRB(25.0, 30, 25, 30),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            widget.data.data()['name'],
                            textScaleFactor: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                  color: darkPrimaryColor,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'By ' + widget.author,
                            textScaleFactor: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                  color: footyColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(icon: Icon(Icons.bedtime), onPressed: null),
                  ]),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/1.png',
                      image: widget.data.data()['images'][0],
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        widget.data.data()['text'],
                        textScaleFactor: 1,
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                              color: darkPrimaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          );
  }
}
