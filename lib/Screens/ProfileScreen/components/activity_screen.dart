import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/Screens/ProfileScreen/view_profile_screen.dart';
import 'package:lycread/Screens/WritingScreen/reading_screen.dart';
import 'package:lycread/Screens/loading_screen.dart';
import 'package:lycread/widgets/card.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../../constants.dart';

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  // ignore: override_on_non_overriding_member
  bool get wantKeepAlive => true;

  List results = [];
  List results1 = [];
  List update = [];
  bool loading = true;
  String author = '';
  Map names = {};
  Map names1 = {};

  Future<void> prepare() async {
    DocumentSnapshot qs = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    if (this.mounted) {
      setState(() {
        // for (var doc in qs.data()['actions']) {
        //   if (!doc['seen']) {
        //     results.add(doc);
        //   } else {
        //     results1.add(doc);
        //   }
        // }
        results = qs.data()['actions'];
        loading = false;
      });
    } else {
      // for (var doc in qs.data()['actions']) {
      //   if (!doc['seen']) {
      //     results.add(doc);
      //   } else {
      //     results1.add(doc);
      //   }
      // }
      results = qs.data()['actions'];
      loading = false;
    }
    for (var res in results) {
      var data = await FirebaseFirestore.instance
          .collection('users')
          .doc(res['author'])
          .get();
      if (this.mounted) {
        setState(() {
          names.addAll({
            res['author']: data.data() != null ? data.data()['photo'] : 'N'
          });
        });
      } else {
        names.addAll(
            {res['author']: data.data() != null ? data.data()['photo'] : 'N'});
      }
    }
    for (var res in results1) {
      var data = await FirebaseFirestore.instance
          .collection('users')
          .doc(res['author'])
          .get();
      if (this.mounted) {
        setState(() {
          names1.addAll({
            res['author']: data.data() != null ? data.data()['photo'] : null
          });
        });
      } else {
        names1.addAll(
            {res['author']: data.data() != null ? data.data()['photo'] : null});
      }
    }

    // if (qs.data()['actions'].length >= 30) {
    //   for (int i = 1; i <= 30; i++) {
    //     if (qs.data()['actions'][qs.data()['actions'].length - i]['seen']) {
    //       update.add(qs.data()['actions'][qs.data()['actions'].length - i]);
    //     } else {
    //       qs.data()['actions'][qs.data()['actions'].length - i] = true;
    //       update.add(qs.data()['actions'][qs.data()['actions'].length - i]);
    //     }
    //   }
    // } else {
    //   for (var i in qs.data()['actions']) {
    //     if (i['seen']) {
    //       update.add(i);
    //     } else {
    //       i['seen'] = true;
    //       update.add(i);
    //     }
    //   }
    // }

    for (var i in qs.data()['actions'].reversed) {
      int difference = Timestamp.now().seconds - i['date'].seconds;
      if (difference < 2592000) {
        if (update.length < 21) {
          if (i['seen']) {
            update.insertAll(0, [i]);
          } else {
            i['seen'] = true;
            update.insertAll(0, [i]);
          }
        }
      }
    }
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({
      'actions': update,
    }).catchError((error) {
      PushNotificationMessage notification = PushNotificationMessage(
        title: 'Fail',
        body: 'Failed to update activity',
      );
      showSimpleNotification(
        Container(child: Text(notification.body)),
        position: NotificationPosition.top,
        background: Colors.red,
      );
    });
  }

  @override
  void initState() {
    prepare();
    super.initState();
  }

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    results = [];
    results1 = [];
    update = [];
    author = '';
    names = {};
    names1 = {};
    prepare();
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingScreen()
        : RefreshIndicator(
            color: footyColor,
            onRefresh: _refresh,
            child: Scaffold(
              // appBar: AppBar(
              //   backgroundColor: whiteColor,
              //   centerTitle: true,
              //   title: Text(
              //     'Активность',
              //     overflow: TextOverflow.ellipsis,
              //     textScaleFactor: 1,
              //     style: GoogleFonts.montserrat(
              //       textStyle: TextStyle(
              //         color: primaryColor,
              //         fontSize: 24,
              //         fontWeight: FontWeight.w500,
              //       ),
              //     ),
              //   ),
              // ),
              body: Column(
                children: [
                  SizedBox(height: 30),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: 10),
                      itemCount: results.length,
                      itemBuilder: (BuildContext context, int index) =>
                          FadeInLeft(
                        child: TextButton(
                          style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.zero)),
                          onPressed: () async {
                            setState(() {
                              loading = true;
                            });
                            if (results[results.length - 1 - index]['type'] ==
                                'New follower') {
                              Navigator.push(
                                context,
                                SlideRightRoute(
                                  page: VProfileScreen(
                                    id: results[results.length - 1 - index]
                                        ['author'],
                                  ),
                                ),
                              );
                            }
                            if (results[results.length - 1 - index]['type'] ==
                                'New comment') {
                              Navigator.push(
                                context,
                                SlideRightRoute(
                                  page: ReadingScreen(
                                    id: results[results.length - 1 - index]
                                        ['post_id'],
                                    author: results[results.length - 1 - index]
                                        ['author'],
                                  ),
                                ),
                              );
                            }
                            setState(() {
                              loading = false;
                            });
                          },
                          child: Container(
                            child: CardW(
                              bgColor: results[results.length - 1 - index]
                                      ['seen']
                                  ? whiteColor
                                  : primaryColor,
                              shadow: !results[results.length - 1 - index]
                                      ['seen']
                                  ? whiteColor
                                  : primaryColor,
                              ph: results[results.length - 1 - index]['type'] ==
                                      'Invitation'
                                  ? 150
                                  : 105,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 8,
                                      child: Column(
                                        children: [
                                          Text(
                                            results[results.length - 1 - index]
                                                ['type'],
                                            textScaleFactor: 1,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: results[results.length -
                                                        1 -
                                                        index]['seen']
                                                    ? primaryColor
                                                    : whiteColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            results[results.length - 1 - index]
                                                ['text'],
                                            textScaleFactor: 1,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: results[results.length -
                                                        1 -
                                                        index]['seen']
                                                    ? primaryColor
                                                    : whiteColor,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ),
                                          results[results.length - 1 - index]
                                                      ['type'] ==
                                                  'Invitation'
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          loading = true;
                                                        });
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'projects')
                                                            .doc(results[results
                                                                            .length -
                                                                        1 -
                                                                        index]
                                                                    ['metadata']
                                                                ['project_id'])
                                                            .update({
                                                          'authors': FieldValue
                                                              .arrayUnion([
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                .uid
                                                          ]),
                                                        }).catchError((error) {
                                                          print('MISTAKE HERE');
                                                          print(error);
                                                          Navigator.of(context)
                                                              .pop(false);
                                                          PushNotificationMessage
                                                              notification =
                                                              PushNotificationMessage(
                                                            title: 'Ошибка',
                                                            body:
                                                                'Возникла ошибка',
                                                          );
                                                          showSimpleNotification(
                                                            Container(
                                                                child: Text(
                                                                    notification
                                                                        .body)),
                                                            position:
                                                                NotificationPosition
                                                                    .top,
                                                            background:
                                                                Colors.red,
                                                          );
                                                        });
                                                        PushNotificationMessage
                                                            notification =
                                                            PushNotificationMessage(
                                                          title: 'Успех',
                                                          body:
                                                              'Вы присоединились',
                                                        );
                                                        showSimpleNotification(
                                                          Container(
                                                              child: Text(
                                                                  notification
                                                                      .body)),
                                                          position:
                                                              NotificationPosition
                                                                  .top,
                                                          background:
                                                              footyColor,
                                                        );
                                                        results.remove(results[
                                                            results.length -
                                                                1 -
                                                                index]);
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                .uid)
                                                            .update({
                                                          'actions': results
                                                        }).catchError((error) {
                                                          print('MISTAKE HERE');
                                                          print(error);
                                                          Navigator.of(context)
                                                              .pop(false);
                                                          PushNotificationMessage
                                                              notification =
                                                              PushNotificationMessage(
                                                            title: 'Ошибка',
                                                            body:
                                                                'Возникла ошибка',
                                                          );
                                                          showSimpleNotification(
                                                            Container(
                                                                child: Text(
                                                                    notification
                                                                        .body)),
                                                            position:
                                                                NotificationPosition
                                                                    .top,
                                                            background:
                                                                Colors.red,
                                                          );
                                                        });
                                                        setState(() {
                                                          loading = false;
                                                        });
                                                      },
                                                      child: const Text(
                                                        'Yes',
                                                        style: TextStyle(
                                                            color: footyColor),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          loading = true;
                                                        });
                                                        results.remove(results[
                                                            results.length -
                                                                1 -
                                                                index]);
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                .uid)
                                                            .update({
                                                          'actions': results
                                                        }).catchError((error) {
                                                          print('MISTAKE HERE');
                                                          print(error);
                                                          Navigator.of(context)
                                                              .pop(false);
                                                          PushNotificationMessage
                                                              notification =
                                                              PushNotificationMessage(
                                                            title: 'Ошибка',
                                                            body:
                                                                'Возникла ошибка',
                                                          );
                                                          showSimpleNotification(
                                                            Container(
                                                                child: Text(
                                                                    notification
                                                                        .body)),
                                                            position:
                                                                NotificationPosition
                                                                    .top,
                                                            background:
                                                                Colors.red,
                                                          );
                                                        });
                                                        setState(() {
                                                          loading = false;
                                                        });
                                                      },
                                                      child: const Text(
                                                        'No',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          child: names[results[results.length -
                                                      1 -
                                                      index]['author']] !=
                                                  null
                                              ? CachedNetworkImage(
                                                  filterQuality:
                                                      FilterQuality.none,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Transform.scale(
                                                    scale: 0.8,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2.0,
                                                      backgroundColor:
                                                          footyColor,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              primaryColor),
                                                    ),
                                                  ),
                                                  imageUrl: names[results[
                                                      results.length -
                                                          1 -
                                                          index]['author']],
                                                )
                                              : Image.asset(
                                                  'assets/images/User.png',
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                  ],
                                ),
                              ),
                            ),
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
