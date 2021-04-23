import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Screens/HomeScreen/home_screen.dart';
import 'package:lycread/Screens/WritingScreen/reading_screen.dart';
import 'package:lycread/Screens/loading_screen.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import '../../constants.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin<DashboardScreen> {
  @override
  bool get wantKeepAlive => true;

  DocumentSnapshot user;
  QuerySnapshot data1;
  List results = [];
  Map names = {};
  bool loading = true;
  int i = 0;
  int j = 0;

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
    user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    if (user.data()['following'] == null ||
        user.data()['following'].length == 0) {
      QuerySnapshot data = await FirebaseFirestore.instance
          .collection('writings')
          .orderBy('rating', descending: true)
          .limit(30)
          .get();
      for (QueryDocumentSnapshot d in data.docs) {
        var name = await FirebaseFirestore.instance
            .collection('users')
            .doc(d.data()['author'])
            .get();
        if (this.mounted) {
          setState(() {
            if (name.data() != null) {
              names.addAll({d.data()['author']: name.data()['name']});
            } else {
              names.addAll({d.data()['author']: 'No author'});
            }
          });
        } else {
          if (name.data() != null) {
            names.addAll({d.data()['author']: name.data()['name']});
          } else {
            names.addAll({d.data()['author']: 'No author'});
          }
        }
      }

      if (this.mounted) {
        setState(() {
          results = data.docs;
        });
      } else {
        results = data.docs;
      }
    } else {
      QuerySnapshot data = await FirebaseFirestore.instance
          .collection('writings')
          .orderBy('date', descending: true)
          .where('author', whereIn: user.data()['following'])
          .limit(25)
          .get();
      for (QueryDocumentSnapshot wr in data.docs) {
        if (wr.data()['users_read'] != null) {
          if (!wr
              .data()['users_read']
              .contains(FirebaseAuth.instance.currentUser.uid)) {
            if (this.mounted) {
              var name = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(wr.data()['author'])
                  .get();
              setState(() {
                if (name.data() != null) {
                  names.addAll({wr.data()['author']: name.data()['name']});
                } else {
                  names.addAll({wr.data()['author']: 'No author'});
                }
                results.add(wr);
              });
            } else {
              var name = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(wr.data()['author'])
                  .get();
              if (name.data() != null) {
                names.addAll({wr.data()['author']: name.data()['name']});
              } else {
                names.addAll({wr.data()['author']: 'No author'});
              }
              results.add(wr);
            }
          }
        } else {
          if (this.mounted) {
            var name = await FirebaseFirestore.instance
                .collection('users')
                .doc(wr.data()['author'])
                .get();
            setState(() {
              if (name.data() != null) {
                names.addAll({wr.data()['author']: name.data()['name']});
              } else {
                names.addAll({wr.data()['author']: 'No author'});
              }
              results.add(wr);
            });
          } else {
            var name = await FirebaseFirestore.instance
                .collection('users')
                .doc(wr.data()['author'])
                .get();
            if (name.data() != null) {
              names.addAll({wr.data()['author']: name.data()['name']});
            } else {
              names.addAll({wr.data()['author']: 'No author'});
            }
            results.add(wr);
          }
        }
      }

      if (results.length < 30) {
        QuerySnapshot data2 = await FirebaseFirestore.instance
            .collection('writings')
            .orderBy('rating', descending: true)
            .limit(30 - results.length)
            .get();
        if (this.mounted) {
          for (QueryDocumentSnapshot wr in data2.docs) {
            var name = await FirebaseFirestore.instance
                .collection('users')
                .doc(wr.data()['author'])
                .get();
            if (this.mounted) {
              setState(() {
                if (name.data() != null) {
                  names.addAll({wr.data()['author']: name.data()['name']});
                } else {
                  names.addAll({wr.data()['author']: 'No author'});
                }
              });
            } else {
              if (name.data() != null) {
                names.addAll({wr.data()['author']: name.data()['name']});
              } else {
                names.addAll({wr.data()['author']: 'No author'});
              }
            }
          }
          setState(() {
            data1 = data2;
          });
        } else {
          data1 = data2;
        }
      }
    }

    if (this.mounted) {
      setState(() {
        loading = false;
      });
    } else {
      if (this.mounted) {
        setState(() {
          loading = false;
        });
      }
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
            // appBar: AppBar(
            //   automaticallyImplyLeading: false,
            //   backgroundColor: primaryColor,
            //   title: Text(
            //     'LycRead',
            //     overflow: TextOverflow.ellipsis,
            //     textScaleFactor: 1,
            //     style: GoogleFonts.montserrat(
            //       textStyle: TextStyle(
            //         color: whiteColor,
            //         fontSize: 20,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
            body: RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                scrollDirection: Axis.vertical,
                slivers: [
                  data1 != null
                      ? SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              for (QueryDocumentSnapshot element in results)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      loading = true;
                                    });
                                    Navigator.push(
                                        context,
                                        SlideRightRoute(
                                          page: ReadingScreen(
                                            data: element,
                                            author:
                                                names[element.data()['author']],
                                          ),
                                        ));
                                    setState(() {
                                      loading = false;
                                    });
                                  },
                                  child: Container(
                                    width: size.width * 0.9,
                                    height: element.data()['images'] != null
                                        ? element.data()['images'] != 'No Image'
                                            ? 300
                                            : 100
                                        : 100,
                                    margin: EdgeInsets.all(5),
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        element.data()['images'] != null
                                            ? element.data()['images'] !=
                                                    'No Image'
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    child: Container(
                                                      height: 200,
                                                      width: size.width,
                                                      child: CachedNetworkImage(
                                                        fit: BoxFit.cover,
                                                        filterQuality:
                                                            FilterQuality.none,
                                                        height: 100,
                                                        width: 100,
                                                        placeholder:
                                                            (context, url) =>
                                                                Container(
                                                          height: 50,
                                                          width: 50,
                                                          child:
                                                              Transform.scale(
                                                            scale: 0.1,
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
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(
                                                          Icons.error,
                                                          color: footyColor,
                                                        ),
                                                        imageUrl:
                                                            element.data()[
                                                                'images'][0],
                                                      ),
                                                    ),
                                                  )
                                                : Container()
                                            : Container(),
                                        SizedBox(height: 10),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: size.width * 0.6,
                                                  child: Text(
                                                    element.data()['name'],
                                                    textScaleFactor: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: primaryColor,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  names[element.data()[
                                                              'author']] !=
                                                          null
                                                      ? names[element
                                                          .data()['author']]
                                                      : 'Loading',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textScaleFactor: 1,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  element.data()['genre'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textScaleFactor: 1,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  getDate(element
                                                      .data()['date']
                                                      .seconds),
                                                  textScaleFactor: 1,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        Divider(
                                          thickness: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              SizedBox(height: 10),
                              Center(
                                child: Text(
                                  'Рекомендации',
                                  textScaleFactor: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: primaryColor,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              for (QueryDocumentSnapshot element in data1.docs)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      loading = true;
                                    });
                                    Navigator.push(
                                        context,
                                        SlideRightRoute(
                                          page: ReadingScreen(
                                            data: element,
                                            author:
                                                names[element.data()['author']],
                                          ),
                                        ));
                                    setState(() {
                                      loading = false;
                                    });
                                  },
                                  child: Container(
                                    width: size.width * 0.9,
                                    height: element.data()['images'] != null
                                        ? element.data()['images'] != 'No Image'
                                            ? 300
                                            : 100
                                        : 100,
                                    margin: EdgeInsets.all(5),
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        element.data()['images'] != null
                                            ? element.data()['images'] !=
                                                    'No Image'
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    child: Container(
                                                      height: 200,
                                                      width: size.width,
                                                      child: CachedNetworkImage(
                                                        fit: BoxFit.cover,
                                                        filterQuality:
                                                            FilterQuality.none,
                                                        height: 100,
                                                        width: 100,
                                                        placeholder:
                                                            (context, url) =>
                                                                Container(
                                                          height: 50,
                                                          width: 50,
                                                          child:
                                                              Transform.scale(
                                                            scale: 0.1,
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
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(
                                                          Icons.error,
                                                          color: footyColor,
                                                        ),
                                                        imageUrl:
                                                            element.data()[
                                                                'images'][0],
                                                      ),
                                                    ),
                                                  )
                                                : Container()
                                            : Container(),
                                        SizedBox(height: 10),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: size.width * 0.6,
                                                  child: Text(
                                                    element.data()['name'],
                                                    textScaleFactor: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: primaryColor,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  names[element.data()[
                                                              'author']] !=
                                                          null
                                                      ? names[element
                                                          .data()['author']]
                                                      : 'Loading',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textScaleFactor: 1,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  element.data()['genre'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textScaleFactor: 1,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  getDate(element
                                                      .data()['date']
                                                      .seconds),
                                                  textScaleFactor: 1,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        Divider(
                                          thickness: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              for (QueryDocumentSnapshot element in results)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      loading = true;
                                    });
                                    Navigator.push(
                                        context,
                                        SlideRightRoute(
                                          page: ReadingScreen(
                                            data: element,
                                            author:
                                                names[element.data()['author']],
                                          ),
                                        ));
                                    setState(() {
                                      loading = false;
                                    });
                                  },
                                  child: Container(
                                    width: size.width * 0.9,
                                    height: element.data()['images'] != null
                                        ? element.data()['images'] != 'No Image'
                                            ? 300
                                            : 100
                                        : 100,
                                    margin: EdgeInsets.all(5),
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        element.data()['images'] != null
                                            ? element.data()['images'] !=
                                                    'No Image'
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    child: Container(
                                                      height: 200,
                                                      width: size.width,
                                                      child: CachedNetworkImage(
                                                        fit: BoxFit.cover,
                                                        filterQuality:
                                                            FilterQuality.none,
                                                        height: 100,
                                                        width: 100,
                                                        placeholder:
                                                            (context, url) =>
                                                                Container(
                                                          height: 50,
                                                          width: 50,
                                                          child:
                                                              Transform.scale(
                                                            scale: 0.1,
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
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(
                                                          Icons.error,
                                                          color: footyColor,
                                                        ),
                                                        imageUrl:
                                                            element.data()[
                                                                'images'][0],
                                                      ),
                                                    ),
                                                  )
                                                : Container()
                                            : Container(),
                                        SizedBox(height: 10),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: size.width * 0.6,
                                                  child: Text(
                                                    element.data()['name'],
                                                    textScaleFactor: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: primaryColor,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  names[element.data()[
                                                              'author']] !=
                                                          null
                                                      ? names[element
                                                          .data()['author']]
                                                      : 'Loading',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textScaleFactor: 1,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  element.data()['genre'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textScaleFactor: 1,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  getDate(element
                                                      .data()['date']
                                                      .seconds),
                                                  textScaleFactor: 1,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        Divider(
                                          thickness: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          );
  }

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    Navigator.push(
      context,
      SlideRightRoute(
        page: HomeScreen(),
      ),
    );
    setState(() {
      loading = false;
    });
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
  }
}
