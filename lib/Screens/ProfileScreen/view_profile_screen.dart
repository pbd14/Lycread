import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/widgets/card.dart';
import 'package:lycread/widgets/follow_button.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../constants.dart';
import '../loading_screen.dart';

class VProfileScreen extends StatefulWidget {
  dynamic data;
  VProfileScreen({Key key, this.data}) : super(key: key);
  @override
  _VPlaceScreenState createState() => _VPlaceScreenState();
}

class _VPlaceScreenState extends State<VProfileScreen> {
  String name;
  bool loading = false;
  bool isSame = false;
  int fnum = 0;

  StreamSubscription<DocumentSnapshot> subscription;

  @override
  void initState() {
    if (FirebaseAuth.instance.currentUser.uid == widget.data.data()['id']) {
      if (this.mounted) {
        setState(() {
          isSame = true;
        });
      } else {
        isSame = true;
      }
    }
    super.initState();
    subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.data.data()['id'])
        .snapshots()
        .listen((docsnap) {
      if (docsnap.data()['followers_num'] != null) {
        if (this.mounted) {
          setState(() {
            fnum = docsnap.data()['followers_num'];
          });
        } else {
          fnum = docsnap.data()['followers_num'];
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
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Center(
                    child: Text(
                      widget.data.data()['name'],
                      textScaleFactor: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                            color: darkPrimaryColor,
                            fontSize: 50,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  !isSame ? SizedBox(height: 20) : Container(),
                  !isSame
                      ? FollowButton(
                          isC: false,
                          reverse: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser.uid),
                          containsValue: widget.data.data()['id'],
                          color1: footyColor,
                          color2: primaryColor,
                          ph: 45,
                          pw: 145,
                          onTap: () {
                            setState(() {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.data.data()['id'])
                                  .update({
                                'followers': FieldValue.arrayUnion(
                                    [widget.data.data()['id']]),
                                'followers_num': fnum + 1,
                              }).catchError((error) {
                                PushNotificationMessage notification =
                                    PushNotificationMessage(
                                  title: 'Fail',
                                  body: 'Failed to update followings',
                                );
                                showSimpleNotification(
                                  Container(child: Text(notification.body)),
                                  position: NotificationPosition.top,
                                  background: Colors.red,
                                );
                              });
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                  .update({
                                'following': FieldValue.arrayUnion(
                                    [widget.data.data()['id']])
                              }).catchError((error) {
                                PushNotificationMessage notification =
                                    PushNotificationMessage(
                                  title: 'Fail',
                                  body: 'Failed to update followings',
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
                                  .doc(widget.data.data()['id'])
                                  .update({
                                'followers': FieldValue.arrayRemove(
                                    [widget.data.data()['id']]),
                                'followers_num': fnum - 1,
                              }).catchError((error) {
                                PushNotificationMessage notification =
                                    PushNotificationMessage(
                                  title: 'Fail',
                                  body: 'Failed to update followings',
                                );
                                showSimpleNotification(
                                  Container(child: Text(notification.body)),
                                  position: NotificationPosition.top,
                                  background: Colors.red,
                                );
                              });
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                  .update({
                                'following': FieldValue.arrayRemove(
                                    [widget.data.data()['id']])
                              }).catchError((error) {
                                PushNotificationMessage notification =
                                    PushNotificationMessage(
                                  title: 'Fail',
                                  body: 'Failed to update followings',
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
                        )
                      : Container(),
                  SizedBox(height: 20),
                  Container(
                    width: size.width * 1,
                    child: CardW(
                      bgColor: primaryColor,
                      width: 1,
                      ph: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            children: [
                              Text(
                                fnum.toString(),
                                textScaleFactor: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                      color: footyColor,
                                      fontSize: 45,
                                      fontWeight: FontWeight.w200),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Подписчиков',
                                textScaleFactor: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                      color: footyColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w200),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
