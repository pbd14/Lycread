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
  String id;
  VProfileScreen({Key key, this.data, this.id}) : super(key: key);
  @override
  _VPlaceScreenState createState() => _VPlaceScreenState();
}

class _VPlaceScreenState extends State<VProfileScreen> {
  String name;
  bool loading = false;
  bool isSame = false;
  int fnum = 0;

  int following = 0;
  int followingUser = 0;
  String fnum1 = '';
  String fnum2 = '';
  List writings = [];

  StreamSubscription<DocumentSnapshot> subscription;
  StreamSubscription<DocumentSnapshot> follwSub;

  Future<void> prepare() async {
    if (widget.id != null) {
      widget.data = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: widget.data)
          .orderBy('date', descending: true)
          .get();
    }
    var data = await FirebaseFirestore.instance
        .collection('writings')
        .where('author', isEqualTo: widget.data.data()['id'])
        .orderBy('date', descending: true)
        .get();
    if (this.mounted) {
      setState(() {
        writings = data.docs;
      });
    } else {
      writings = data.docs;
    }
  }

  @override
  void initState() {
    prepare();
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
            followingUser = docsnap.data()['following_num'];
            if (fnum > 999999) {
              double numb = fnum / 1000000;
              fnum1 = numb.toStringAsFixed(1) + 'M';
            } else if (fnum > 999) {
              double numb = fnum / 1000;
              fnum1 = numb.toStringAsFixed(1) + 'K';
            } else {
              fnum1 = fnum.toString();
            }

            if (followingUser > 999999) {
              double numb = followingUser / 1000000;
              fnum2 = numb.toStringAsFixed(1) + 'M';
            } else if (followingUser > 999) {
              double numb = followingUser / 1000;
              fnum2 = numb.toStringAsFixed(1) + 'K';
            } else {
              fnum2 = followingUser.toString();
            }
          });
        } else {
          fnum = docsnap.data()['followers_num'];
          followingUser = docsnap.data()['following_num'];
          if (fnum > 999999) {
            double numb = fnum / 1000000;
            fnum1 = numb.toStringAsFixed(1) + 'M';
          } else if (fnum > 999) {
            double numb = fnum / 1000;
            fnum1 = numb.toStringAsFixed(1) + 'K';
          } else {
            fnum1 = fnum.toString();
          }

          if (followingUser > 999999) {
            double numb = followingUser / 1000000;
            fnum2 = numb.toStringAsFixed(1) + 'M';
          } else if (followingUser > 999) {
            double numb = followingUser / 1000;
            fnum2 = numb.toStringAsFixed(1) + 'K';
          } else {
            fnum2 = followingUser.toString();
          }
        }
      }
    });

    follwSub = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .snapshots()
        .listen((docsnap) {
      if (docsnap.data()['following_num'] != null) {
        if (this.mounted) {
          setState(() {
            following = docsnap.data()['following_num'];
          });
        } else {
          following = docsnap.data()['following_num'];
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
                            fontSize: 30,
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
                                    [widget.data.data()['id']]),
                                'following_num': following + 1,
                              }).catchError((error) {
                                PushNotificationMessage notification =
                                    PushNotificationMessage(
                                  title: 'Fail',
                                  body: 'Failed to update followers',
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
                                    [widget.data.data()['id']]),
                                'following_num': following - 1,
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
                  SizedBox(height: 10),
                  Container(
                      height: 130,
                      child: GridView.count(
                        physics: new NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        children: [
                          Column(
                            children: [
                              Text(
                                fnum1,
                                textScaleFactor: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                      color: darkPrimaryColor,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
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
                                      color: primaryColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w200),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                fnum2,
                                textScaleFactor: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                      color: darkPrimaryColor,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Подписок',
                                textScaleFactor: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                      color: primaryColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w200),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                  CardW(
                    ph: 70,
                    bgColor: primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 5, 30, 5),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          writings.length.toString() + ' Истории',
                          textScaleFactor: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                                color: footyColor,
                                fontSize: 25,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  writings.length != 0
                      ? ListView.builder(
                          physics: new NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(bottom: 10),
                          itemCount: writings.length,
                          itemBuilder: (BuildContext context, int index) => Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              writings[index].data()['images'] != 'No Image'
                                  ? Container(
                                      width: size.width * 0.35,
                                      child: FadeInImage.assetNetwork(
                                        height: 150,
                                        width: 150,
                                        placeholder: 'assets/images/1.png',
                                        image: writings[index].data()['images']
                                            [0],
                                      ),
                                    )
                                  : Container(
                                      width: size.width * 0.35,
                                      child: Image.asset(
                                        'assets/images/1.png',
                                        height: 150,
                                        width: 150,
                                      ),
                                    ),
                              Expanded(
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Text(
                                                writings[index].data()['name'],
                                                textScaleFactor: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: primaryColor,
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                writings[index].data()['genre'],
                                                overflow: TextOverflow.ellipsis,
                                                textScaleFactor: 1,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                    color: primaryColor,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                color: darkPrimaryColor,
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Text(
                            'Нет историй',
                            textScaleFactor: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                  color: lightPrimaryColor,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w200),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          );
  }
}
