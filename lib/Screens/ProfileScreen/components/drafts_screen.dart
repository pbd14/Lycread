import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Screens/WritingScreen/drafts_writing_screen.dart';
import 'package:lycread/Screens/WritingScreen/reading_screen.dart';
import 'package:lycread/Screens/loading_screen.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';

import '../../../constants.dart';

class DraftsScreen extends StatefulWidget {
  List<dynamic> data;
  DraftsScreen({Key key, this.data}) : super(key: key);
  @override
  _DraftsScreenState createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  List results = [];
  bool loading = true;
  bool loading1 = false;
  String author = '';

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
    DocumentSnapshot user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    if (this.mounted) {
      setState(() {
        results = user.data()['drafts'];
        loading = false;
      });
    } else {
      results = user.data()['drafts'];
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
              backgroundColor: primaryColor,
              centerTitle: true,
              title: Text(
                'Черновики',
                overflow: TextOverflow.ellipsis,
                textScaleFactor: 1,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    color: whiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                SizedBox(height: 20),
                Expanded(
                  child: loading1
                      ? LoadingScreen()
                      : results.length != 0
                          ? ListView.builder(
                              padding: EdgeInsets.only(bottom: 10),
                              itemCount: results.length,
                              itemBuilder: (BuildContext context, int index) =>
                                  Container(
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Card(
                                  elevation: 10,
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        loading = true;
                                      });
                                      Navigator.push(
                                          context,
                                          SlideRightRoute(
                                            page: DraftsWritingScreen(
                                              data: results[
                                                  results.length - 1 - index],
                                            ),
                                          ));
                                      setState(() {
                                        loading = false;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        results[results.length - 1 - index]
                                                    ['images'] !=
                                                'No Image'
                                            ? Container(
                                                width: size.width * 0.2,
                                                height: size.width * 0.2,
                                                child: CachedNetworkImage(
                                                  filterQuality:
                                                      FilterQuality.none,
                                                  height: 100,
                                                  width: 100,
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
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                  imageUrl: results[
                                                      results.length -
                                                          1 -
                                                          index]['images'][0],
                                                ),
                                              )
                                            : Container(),
                                        Expanded(
                                          child: Container(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          results[results
                                                                  .length -
                                                              1 -
                                                              index]['name'],
                                                          textScaleFactor: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  primaryColor,
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
                                                          getDate(results[results
                                                                      .length -
                                                                  1 -
                                                                  index]['date']
                                                              .seconds),
                                                          textScaleFactor: 1,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  primaryColor,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                'Нет избранных',
                                overflow: TextOverflow.ellipsis,
                                textScaleFactor: 1,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: lightPrimaryColor,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ),
                ),
              ],
            ),
          );
  }
}
