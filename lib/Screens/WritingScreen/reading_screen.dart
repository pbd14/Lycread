import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/Screens/ProfileScreen/view_profile_screen.dart';
import 'package:lycread/widgets/label_button.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/rounded_text_input.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool isComm = false;
  bool isYellow = false;
  Color firstColor = whiteColor;
  Color yellowColor = Color.fromRGBO(255, 255, 225, 1.0);
  Color secondColor = Color.fromRGBO(43, 43, 43, 1.0);
  int rates = 0;
  String ratStr = '';
  String commentText = '';
  StreamSubscription<DocumentSnapshot> subscription;
  List comments = [];

  String getName(String id) {
    String name;
    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get()
        .then((value) => name = value.data()['name']);
  }

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
            docsnap.data()['comments'].length != 0
                ? comments = docsnap.data()['comments']
                : comments = [];
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
          docsnap.data()['comments'].length != 0
              ? comments = docsnap.data()['comments']
              : comments = [];
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
            appBar: AppBar(
              centerTitle: true,
              iconTheme: IconThemeData(color: firstColor),
              backgroundColor: secondColor,
              title: Text(
                'Публикация',
                textScaleFactor: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                      color: firstColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w300),
                ),
              ),
            ),
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
                      height: 10,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
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
                                isComm = !isComm;
                              });
                            },
                          ),
                          IconButton(
                            color: secondColor,
                            icon: Icon(CupertinoIcons.book_solid),
                            onPressed: () {
                              setState(() {
                                if (!isComm) {
                                  isYellow
                                      ? firstColor = whiteColor
                                      : firstColor = yellowColor;
                                } else {
                                  isYellow
                                      ? secondColor = whiteColor
                                      : secondColor = yellowColor;
                                }
                                isYellow = !isYellow;
                              });
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              widget.data.data()['name'],
                              textScaleFactor: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.fade,
                              maxLines: 1000,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                    color: secondColor,
                                    fontSize: 27,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 10),
                            FlatButton(
                              color: primaryColor,
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                var data = await FirebaseFirestore.instance
                                    .collection('users')
                                    // .where('id',
                                    //     isEqualTo: widget.data.data()['author'])
                                    .doc(widget.data.data()['author'])
                                    .get();
                                Navigator.push(
                                  context,
                                  SlideRightRoute(
                                    page: VProfileScreen(
                                      data: data,
                                    ),
                                  ),
                                );
                                setState(() {
                                  loading = false;
                                });
                              },
                              child: Text(
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
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Column(
                            children: [
                              UpButton(
                                isC: false,
                                reverse: FirebaseFirestore.instance
                                    .collection('writings')
                                    .doc(widget.data.id),
                                containsValue:
                                    FirebaseAuth.instance.currentUser.uid,
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
                                      'users_rated': FieldValue.arrayUnion([
                                        FirebaseAuth.instance.currentUser.uid
                                      ])
                                    }).catchError((error) {
                                      PushNotificationMessage notification =
                                          PushNotificationMessage(
                                        title: 'Fail',
                                        body: 'Failed to up',
                                      );
                                      showSimpleNotification(
                                        Container(
                                            child: Text(notification.body)),
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
                                      'users_rated': FieldValue.arrayRemove([
                                        FirebaseAuth.instance.currentUser.uid
                                      ])
                                    }).catchError((error) {
                                      PushNotificationMessage notification =
                                          PushNotificationMessage(
                                        title: 'Fail',
                                        body: 'Failed tp up',
                                      );
                                      showSimpleNotification(
                                        Container(
                                            child: Text(notification.body)),
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
                    widget.data.data()['images'] != 'No Image'
                        ? SizedBox(
                            height: 20,
                          )
                        : Container(),
                    widget.data.data()['images'] != 'No Image'
                        ? Container(
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/images/1.png',
                              image: widget.data.data()['images'][0],
                            ),
                          )
                        : Container(),
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
                    SizedBox(height: 10),
                    Divider(
                      color: secondColor,
                      thickness: 2,
                    ),
                    SizedBox(height: 10),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  cursorColor: secondColor,
                                  maxLines: null,
                                  style: TextStyle(color: secondColor),
                                  validator: (val) => val.length > 1
                                      ? null
                                      : 'Минимум 2 символов',
                                  keyboardType: TextInputType.multiline,
                                  maxLength: 500,
                                  onChanged: (value) {
                                    commentText = value;
                                  },
                                  decoration: InputDecoration(
                                    counterStyle: TextStyle(color: secondColor),
                                    hintText: "Коммент",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              RoundedButton(
                                width: 0.2,
                                ph: 45,
                                text: 'Ок',
                                press: () async {
                                  if (_formKey.currentState.validate()) {
                                    setState(() {
                                      loading = true;
                                    });
                                    await FirebaseFirestore.instance
                                        .collection('writings')
                                        .doc(widget.data.id)
                                        .update({
                                      'comments': FieldValue.arrayUnion([
                                        {
                                          'date': DateTime.now(),
                                          'text': commentText,
                                          'author': FirebaseAuth
                                              .instance.currentUser.displayName,
                                        }
                                      ])
                                    }).catchError((error) {
                                      PushNotificationMessage notification =
                                          PushNotificationMessage(
                                        title: 'Ошибка',
                                        body: 'Неудалось добавить комментарий',
                                      );
                                      showSimpleNotification(
                                        Container(
                                            child: Text(notification.body)),
                                        position: NotificationPosition.top,
                                        background: Colors.red,
                                      );
                                    });
                                    String nText = FirebaseAuth
                                        .instance.currentUser.displayName;
                                    String nText1 = widget.data.data()['name'];
                                    if (FirebaseAuth.instance.currentUser.uid !=
                                        widget.data.data()['author']) {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.data.data()['author'])
                                          .update({
                                        'actions': FieldValue.arrayUnion([
                                          {
                                            'author': FirebaseAuth
                                                .instance.currentUser.uid,
                                            'seen': false,
                                            'text':
                                                'Пользователь $nText прокомментировал ваше искусство $nText1',
                                            'type': 'New comment',
                                            'date': DateTime.now(),
                                          }
                                        ]),
                                      });
                                    }
                                    PushNotificationMessage notification =
                                        PushNotificationMessage(
                                      title: 'Успех',
                                      body: 'Комментарий добавлен',
                                    );
                                    showSimpleNotification(
                                      Container(child: Text(notification.body)),
                                      position: NotificationPosition.top,
                                      background: footyColor,
                                    );
                                    setState(() {
                                      loading = false;
                                      commentText = '';
                                    });
                                  }
                                },
                                color: darkPrimaryColor,
                                textColor: whiteColor,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          comments.length != 0
                              ? Center(
                                  child: ListView.builder(
                                    physics: new NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.only(bottom: 10),
                                    itemCount: comments.length,
                                    itemBuilder:
                                        (BuildContext context, int index) =>
                                            Card(
                                      shadowColor: secondColor,
                                      color: firstColor,
                                      elevation: 10,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Container(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            comments[index]
                                                                ['text'],
                                                            textScaleFactor: 1,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  TextStyle(
                                                                color:
                                                                    secondColor,
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            comments[index][
                                                                        'author'] !=
                                                                    null
                                                                ? comments[
                                                                        index]
                                                                    ['author']
                                                                : 'No author',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textScaleFactor: 1,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  TextStyle(
                                                                color:
                                                                    secondColor,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
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
                                            thickness: 0.1,
                                            color: secondColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    'No comments',
                                    textScaleFactor: 1,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          color: secondColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w300),
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
          );
  }
}
