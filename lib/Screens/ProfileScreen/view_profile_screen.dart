import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/Screens/ProfileScreen/components/view_users_screen.dart';
import 'package:lycread/Screens/WritingScreen/reading_screen.dart';
import 'package:lycread/widgets/follow_button.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../constants.dart';
import '../loading_screen.dart';

// ignore: must_be_immutable
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

  @override
  void dispose() {
    subscription.cancel();
    follwSub.cancel();
    super.dispose();
  }

  String getFnum(int fnum) {
    String fnum1 = '';
    if (fnum > 999999) {
      double numb = fnum / 1000000;
      fnum1 = numb.toStringAsFixed(1) + 'M';
    } else if (fnum > 999) {
      double numb = fnum / 1000;
      fnum1 = numb.toStringAsFixed(1) + 'K';
    } else {
      fnum1 = fnum.toString();
    }
    return fnum1 + ' просмотров';
  }

  String getDate(int seconds) {
    String date = '';
    DateTime d = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    if (d.year == DateTime.now().year) {
      if (d.month == DateTime.now().month) {
        if (d.day == DateTime.now().day) {
          date = 'сегодня';
        } else {
          int n = DateTime.now().day - d.day;
          switch (n) {
            case 1:
              date = 'вчера';
              break;
            case 2:
              date = 'позавчера';
              break;
            case 3:
              date = n.toString() + ' дня назад';
              break;
            case 4:
              date = n.toString() + ' дня назад';
              break;
            default:
              date = n.toString() + ' дней назад';
          }
        }
      } else {
        int n = DateTime.now().month - d.month;
        switch (n) {
          case 1:
            date = 'месяц назад';
            break;
          case 2:
            date = n.toString() + ' месяца назад';
            break;
          case 3:
            date = n.toString() + ' месяца назад';
            break;
          case 4:
            date = n.toString() + ' месяца назад';
            break;
          default:
            date = n.toString() + ' месяцев назад';
        }
      }
    } else {
      int n = DateTime.now().year - d.year;
      switch (n) {
        case 1:
          date = 'год назад';
          break;
        case 2:
          date = n.toString() + ' года назад';
          break;
        case 3:
          date = n.toString() + ' года назад';
          break;
        case 4:
          date = n.toString() + ' года назад';
          break;
        default:
          date = n.toString() + ' лет назад';
      }
    }
    return date;
  }

  Future<void> prepare() async {
    var data;
    if (widget.id != null) {
      DocumentSnapshot user = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.id)
          .get();
      if (this.mounted) {
        setState(() {
          widget.data = user;
        });
      } else {
        widget.data = user;
      }
      data = await FirebaseFirestore.instance
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
      if (FirebaseAuth.instance.currentUser.uid == widget.data.data()['id']) {
        if (this.mounted) {
          setState(() {
            isSame = true;
          });
        } else {
          isSame = true;
        }
      }

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
    } else {
      data = await FirebaseFirestore.instance
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
      if (FirebaseAuth.instance.currentUser.uid == widget.data.data()['id']) {
        if (this.mounted) {
          setState(() {
            isSame = true;
          });
        } else {
          isSame = true;
        }
      }

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
    }
  }

  @override
  void initState() {
    prepare();
    super.initState();
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
        : widget.data == null
            ? LoadingScreen()
            : Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  backgroundColor: primaryColor,
                  title: Text(
                    'Пользователь',
                    textScaleFactor: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          color: whiteColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 55),
                      Container(
                        width: size.width * 0.4,
                        height: size.width * 0.4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: widget.data.data()['photo'] != null
                              ? CachedNetworkImage(
                                  filterQuality: FilterQuality.none,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Transform.scale(
                                    scale: 0.8,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      backgroundColor: footyColor,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          primaryColor),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    color: footyColor,
                                  ),
                                  imageUrl: widget.data.data()['photo'],
                                )
                              : Image.asset(
                                  'assets/images/User.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      SizedBox(height: 50),
                      widget.data.data()['isVerified'] != null
                          ? widget.data.data()['isVerified']
                              ? Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                      SizedBox(width: 5),
                                      Icon(
                                        CupertinoIcons.checkmark_seal_fill,
                                        color: footyColor,
                                      ),
                                    ],
                                  ),
                                )
                              : Center(
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
                                )
                          : Center(
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
                      SizedBox(height: 25),
                      Center(
                        child: Text(
                          widget.data.data()['bio'] != null
                              ? widget.data.data()['bio']
                              : 'No Bio',
                          maxLines: 1000,
                          textScaleFactor: 1,
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                                color: darkPrimaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
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
                                String nText = FirebaseAuth
                                    .instance.currentUser.displayName;
                                setState(() {
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.data.data()['id'])
                                      .update({
                                    'followers': FieldValue.arrayUnion([
                                      FirebaseAuth.instance.currentUser.uid
                                    ]),
                                    'followers_num': fnum + 1,
                                    'actions': FieldValue.arrayUnion([
                                      {
                                        'author': FirebaseAuth
                                            .instance.currentUser.uid,
                                        'seen': false,
                                        'text':
                                            'Пользователь $nText стал вашим читателем',
                                        'type': 'New follower',
                                        'date': DateTime.now(),
                                      }
                                    ]),
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
                                      .doc(
                                          FirebaseAuth.instance.currentUser.uid)
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
                                    'followers': FieldValue.arrayRemove([
                                      FirebaseAuth.instance.currentUser.uid
                                    ]),
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
                                      .doc(
                                          FirebaseAuth.instance.currentUser.uid)
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
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    loading = true;
                                  });
                                  if (widget.data.data()['followers_num'] !=
                                      0) {
                                    Navigator.push(
                                      context,
                                      SlideRightRoute(
                                        page: ViewUsersScreen(
                                          data: widget.data.data()['followers'],
                                          text: 'Подписчики',
                                        ),
                                      ),
                                    );
                                  }
                                  setState(() {
                                    loading = false;
                                  });
                                },
                                child: Column(
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
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    loading = true;
                                  });
                                  if (widget.data.data()['following_num'] !=
                                      0) {
                                    Navigator.push(
                                      context,
                                      SlideRightRoute(
                                        page: ViewUsersScreen(
                                          data: widget.data.data()['following'],
                                          text: 'Подписки',
                                        ),
                                      ),
                                    );
                                  }
                                  setState(() {
                                    loading = false;
                                  });
                                },
                                child: Column(
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
                              ),
                            ],
                          )),
                      Center(
                        child: Text(
                          writings.length.toString() + ' историй',
                          textScaleFactor: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                                color: primaryColor,
                                fontSize: 25,
                                fontWeight: FontWeight.w400),
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
                              itemBuilder: (BuildContext context, int index) =>
                                  TextButton(
                                onPressed: () {
                                  setState(() {
                                    loading = true;
                                  });
                                  Navigator.push(
                                      context,
                                      SlideRightRoute(
                                        page: ReadingScreen(
                                          data: writings[index],
                                          author: widget.data.data()['name'],
                                        ),
                                      ));
                                  setState(() {
                                    loading = false;
                                  });
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    writings[index].data()['images'] !=
                                            'No Image'
                                        ? Container(
                                            width: size.width * 0.2,
                                            height: size.width * 0.2,
                                            child: CachedNetworkImage(
                                              filterQuality: FilterQuality.none,
                                              height: 100,
                                              width: 100,
                                              placeholder: (context, url) =>
                                                  Transform.scale(
                                                scale: 0.8,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  backgroundColor: footyColor,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(primaryColor),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                Icons.error,
                                                color: footyColor,
                                              ),
                                              imageUrl: writings[index]
                                                  .data()['images'][0],
                                            ),
                                          )
                                        : Container(),
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
                                                      writings[index]
                                                          .data()['name'],
                                                      textScaleFactor: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: primaryColor,
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      writings[index].data()[
                                                                  'reads'] !=
                                                              null
                                                          ? writings[index]
                                                                      .data()[
                                                                  'genre'] +
                                                              ' | ' +
                                                              getFnum(writings[
                                                                          index]
                                                                      .data()[
                                                                  'reads'])
                                                          : writings[index]
                                                              .data()['genre'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textScaleFactor: 1,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: primaryColor,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w300,
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
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        getDate(writings[index]
                                            .data()['date']
                                            .seconds),
                                        textScaleFactor: 1,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: primaryColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
