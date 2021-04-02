import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/widgets/label_button.dart';
import 'package:lycread/widgets/up_button.dart';
import 'package:overlay_support/overlay_support.dart';

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
  Color firstColor = whiteColor;
  Color secondColor = Colors.black;
  int rates = 0;
  String ratStr = '';
  StreamSubscription<DocumentSnapshot> subscription;

  @override
  void initState() {
    super.initState();
    subscription = FirebaseFirestore.instance
        .collection('writings')
        .doc(widget.data.id)
        .snapshots()
        .listen((docsnap) {
      if (docsnap.data()['rating'] != null) {
        if (this.mounted) {
          setState(() {
            if (docsnap.data()['rating'] > 999999) {
              rates = docsnap.data()['rating'];
              double numb = docsnap.data()['rating'] / 1000000;
              ratStr = numb.toStringAsFixed(1) + 'M';
            } else if (docsnap.data()['rating'] > 999) {
              rates = docsnap.data()['rating'];
              double numb = docsnap.data()['rating'] / 1000;
              ratStr = numb.toStringAsFixed(1) + 'K';
            } else {
              rates = docsnap.data()['rating'];
              ratStr = docsnap.data()['rating'].toString();
            }
          });
        } else {
          if (docsnap.data()['rating'] > 999999) {
            rates = docsnap.data()['rating'];
            double numb = docsnap.data()['rating'] / 1000000;
            ratStr = numb.toStringAsFixed(1) + 'M';
          } else if (docsnap.data()['rating'] > 999) {
            rates = docsnap.data()['rating'];
            double numb = docsnap.data()['rating'] / 1000;
            ratStr = numb.toStringAsFixed(1) + 'K';
          } else {
            rates = docsnap.data()['rating'];
            ratStr = docsnap.data()['rating'].toString();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            backgroundColor: firstColor,
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
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Column(
                      children: [
                        UpButton(
                          isC: false,
                          reverse: FirebaseFirestore.instance
                              .collection('writings')
                              .doc(widget.data.id),
                          containsValue: FirebaseAuth.instance.currentUser.uid,
                          color1: footyColor,
                          color2: secondColor,
                          ph: 45,
                          pw: 45,
                          size: 40,
                          onTap: () {
                            setState(() {
                              FirebaseFirestore.instance
                                  .collection('writings')
                                  .doc(widget.data.id)
                                  .update({
                                'rating': rates + 1,
                                'users_rated': FieldValue.arrayUnion(
                                    [FirebaseAuth.instance.currentUser.uid])
                              }).catchError((error) {
                                PushNotificationMessage notification =
                                    PushNotificationMessage(
                                  title: 'Fail',
                                  body: 'Failed to up',
                                );
                                showSimpleNotification(
                                  Container(child: Text(notification.body)),
                                  position: NotificationPosition.top,
                                  background: Colors.red,
                                );
                                if (this.mounted) {
                                  setState(() {
                                    loading = false;
                                  });
                                } else {
                                  loading = false;
                                }
                              });
                            });
                            // Scaffold.of(context).showSnackBar(
                            //   SnackBar(
                            //     duration: Duration(seconds: 2),
                            //     backgroundColor: darkPrimaryColor,
                            //     content: Text(
                            //       'Успешно',
                            //       style: GoogleFonts.montserrat(
                            //         textStyle: TextStyle(
                            //           color: whiteColor,
                            //           fontSize: 15,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // );
                          },
                          onTap2: () {
                            setState(() {
                              FirebaseFirestore.instance
                                  .collection('writings')
                                  .doc(widget.data.id)
                                  .update({
                                'rating': rates - 1,
                                'users_rated': FieldValue.arrayRemove(
                                    [FirebaseAuth.instance.currentUser.uid])
                              }).catchError((error) {
                                PushNotificationMessage notification =
                                    PushNotificationMessage(
                                  title: 'Fail',
                                  body: 'Failed tp up',
                                );
                                showSimpleNotification(
                                  Container(child: Text(notification.body)),
                                  position: NotificationPosition.top,
                                  background: Colors.red,
                                );
                                if (this.mounted) {
                                  setState(() {
                                    loading = false;
                                  });
                                } else {
                                  loading = false;
                                }
                              });
                            });
                            // Scaffold.of(context).showSnackBar(
                            //   SnackBar(
                            //     duration: Duration(seconds: 2),
                            //     backgroundColor: Colors.red,
                            //     content: Text(
                            //       'Removed from favourites',
                            //       style: GoogleFonts.montserrat(
                            //         textStyle: TextStyle(
                            //           color: whiteColor,
                            //           fontSize: 15,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // );
                          },
                        ),
                        Text(
                          ratStr,
                          textScaleFactor: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                                color: secondColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            widget.data.data()['name'],
                            textScaleFactor: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                  color: secondColor,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 10),
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
                    Column(
                      children: [
                        IconButton(
                          color: secondColor,
                          icon: Icon(Icons.bedtime),
                          onPressed: () {
                            Color _1 = secondColor;
                            Color _2 = firstColor;
                            setState(() {
                              firstColor = _1;
                              secondColor = _2;
                            });
                          },
                        ),
                        LabelButton(
                          isC: false,
                          reverse: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser.uid),
                          containsValue: widget.data.id,
                          color1: footyColor,
                          color2: secondColor,
                          ph: 45,
                          pw: 45,
                          size: 40,
                          onTap: () {
                            setState(() {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                  .update({
                                'favourites':
                                    FieldValue.arrayUnion([widget.data.id])
                              }).catchError((error) {
                                PushNotificationMessage notification =
                                    PushNotificationMessage(
                                  title: 'Fail',
                                  body: 'Failed to update favourites',
                                );
                                showSimpleNotification(
                                  Container(child: Text(notification.body)),
                                  position: NotificationPosition.top,
                                  background: Colors.red,
                                );
                                if (this.mounted) {
                                  setState(() {
                                    loading = false;
                                  });
                                } else {
                                  loading = false;
                                }
                              });
                            });
                          },
                          onTap2: () {
                            setState(() {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                  .update({
                                'favourites':
                                    FieldValue.arrayRemove([widget.data.id])
                              }).catchError((error) {
                                PushNotificationMessage notification =
                                    PushNotificationMessage(
                                  title: 'Fail',
                                  body: 'Failed to update favourites',
                                );
                                showSimpleNotification(
                                  Container(child: Text(notification.body)),
                                  position: NotificationPosition.top,
                                  background: Colors.red,
                                );
                                if (this.mounted) {
                                  setState(() {
                                    loading = false;
                                  });
                                } else {
                                  loading = false;
                                }
                              });
                            });
                          },
                        ),
                      ],
                    ),
                  ]),
                  SizedBox(height: 10),
                  Divider(
                    color: secondColor,
                    thickness: 2,
                  ),
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
                              color: secondColor,
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
