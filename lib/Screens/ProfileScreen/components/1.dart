import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/Screens/ProfileScreen/components/favourites_screen.dart';
import 'package:lycread/Screens/ProfileScreen/components/settings.dart';
import 'package:lycread/Screens/ProfileScreen/components/view_users_screen.dart';
import 'package:lycread/Screens/WritingScreen/reading_screen.dart';
import 'package:lycread/Screens/loading_screen.dart';
import 'package:lycread/constants.dart';
import 'package:lycread/widgets/card.dart';
import 'package:lycread/widgets/follow_button.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:overlay_support/overlay_support.dart';

class VProfileScreen1 extends StatefulWidget {
  @override
  _VPlaceScreen1State createState() => _VPlaceScreen1State();
}

class _VPlaceScreen1State extends State<VProfileScreen1> {
  String name;
  bool loading = true;
  DocumentSnapshot data;
  List<QueryDocumentSnapshot> writings;

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
    return fnum1;
  }

  String getFnum1(int fnum) {
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
    var data1 = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    var writData = await FirebaseFirestore.instance
        .collection('writings')
        .where('author', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .orderBy('date', descending: true)
        .get();

    if (this.mounted) {
      setState(() {
        data = data1;
        writings = writData.docs;
        loading = false;
      });
    } else {
      data = data1;
      writings = writData.docs;
      loading = false;
    }
  }

  @override
  void initState() {
    prepare();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              elevation: 0,
              primary: false,
              excludeHeaderSemantics: true,
              backgroundColor: whiteColor,
              actions: [
                data.data()['favourites'].length != 0
                    ? IconButton(
                        color: primaryColor,
                        icon: Icon(
                          CupertinoIcons.bookmark,
                        ),
                        onPressed: () {
                          setState(() {
                            loading = true;
                          });
                          Navigator.push(
                              context,
                              SlideRightRoute(
                                page: FavouritesScreen(
                                  data: data.data()['favourites'],
                                ),
                              ));
                          setState(() {
                            loading = false;
                          });
                        },
                      )
                    : Container(),
                IconButton(
                  color: primaryColor,
                  icon: Icon(
                    CupertinoIcons.chat_bubble_2_fill,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  color: primaryColor,
                  icon: Icon(CupertinoIcons.settings),
                  onPressed: () {
                    setState(() {
                      loading = true;
                    });
                    Navigator.push(
                        context,
                        SlideRightRoute(
                          page: SettingsScreen(),
                        ));
                    setState(() {
                      loading = false;
                    });
                  },
                ),
                SizedBox(width: 10),
              ],
              // title: Text(
              //   'Пользователь',
              //   textScaleFactor: 1,
              //   overflow: TextOverflow.ellipsis,
              //   style: GoogleFonts.montserrat(
              //     textStyle: TextStyle(
              //         color: whiteColor,
              //         fontSize: 20,
              //         fontWeight: FontWeight.w300),
              //   ),
              // ),
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
                      child: FirebaseAuth.instance.currentUser.photoURL != null
                          ? FadeInImage.assetNetwork(
                              fit: BoxFit.cover,
                              placeholder: 'assets/images/User.png',
                              image: FirebaseAuth.instance.currentUser.photoURL,
                            )
                          : Image.asset(
                              'assets/images/User.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(height: 50),
                  Center(
                    child: Text(
                      FirebaseAuth.instance.currentUser.displayName,
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
                      data.data()['bio'] != null
                          ? data.data()['bio']
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
                              if (data.data()['followers_num'] != 0) {
                                Navigator.push(
                                  context,
                                  SlideRightRoute(
                                    page: ViewUsersScreen(
                                      data: data.data()['followers'],
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
                                  getFnum(data.data()['followers_num']),
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
                              if (data.data()['following_num'] != 0) {
                                Navigator.push(
                                  context,
                                  SlideRightRoute(
                                    page: ViewUsersScreen(
                                      data: data.data()['following'],
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
                                  getFnum(data.data()['following_num']),
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
                            fontWeight: FontWeight.w600),
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
                                      author: data.data()['name'],
                                    ),
                                  ));
                              setState(() {
                                loading = false;
                              });
                            },
                            child: Row(
                              children: [
                                writings[index].data()['images'] != 'No Image'
                                    ? Container(
                                        width: size.width * 0.2,
                                        child: FadeInImage.assetNetwork(
                                          height: 100,
                                          width: 100,
                                          placeholder: 'assets/images/1.png',
                                          image: writings[index]
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
                                                  style: GoogleFonts.montserrat(
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
                                                              .data()['genre'] +
                                                          ' | ' +
                                                          getFnum1(writings[
                                                                  index]
                                                              .data()['reads'])
                                                      : writings[index]
                                                          .data()['genre'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textScaleFactor: 1,
                                                  style: GoogleFonts.montserrat(
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
                                    getDate(
                                        writings[index].data()['date'].seconds),
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
