import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Screens/ProjectScreen/project_info_screen.dart';
import 'package:lycread/Screens/loading_screen.dart';
import 'package:lycread/widgets/rounded_text_input.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';

import '../../../constants.dart';

class ThirdScreen extends StatefulWidget {
  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen>
    with AutomaticKeepAliveClientMixin<ThirdScreen> {
  @override
  bool get wantKeepAlive => true;
  List results = [];
  bool loading = true;
  bool loading1 = false;
  String author = '';

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
    QuerySnapshot qs =
        await FirebaseFirestore.instance.collection('projects').limit(20).get();
    if (this.mounted) {
      setState(() {
        results = qs.docs;
        loading = false;
      });
    } else {
      results = qs.docs;
      loading = false;
    }
  }

  Future<void> search(String st) async {
    setState(() {
      loading1 = true;
    });
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('projects')
        // .orderBy('rating', descending: true)
        .limit(20)
        .get();
    setState(() {
      List preresults = [];
      for (var doc in qs.docs) {
        if (doc.data()['name'].toLowerCase().contains(st.toLowerCase())) {
          preresults.add(doc);
        }
      }
      results = preresults;
      loading1 = false;
      preresults = [];
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
      loading1 = false;
    });
    results = [];
    author = '';
    results = [];
    prepare();
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : RefreshIndicator(
            color: footyColor,
            onRefresh: _refresh,
            child: Scaffold(
              body: Column(
                children: [
                  SizedBox(height: 5),
                  Center(
                    child: RoundedTextInput(
                      validator: (val) =>
                          val.length > 1 ? null : 'Минимум 2 символов',
                      hintText: "Название",
                      type: TextInputType.text,
                      height: 100,
                      onChanged: (value) {
                        value != null
                            ? value.length != 0
                                ? search(value)
                                : prepare()
                            : prepare();
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: loading1
                        ? LoadingScreen()
                        : ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (BuildContext context, int index) =>
                                FadeInLeft(
                              child: Container(
                                child: Card(
                                  margin: EdgeInsets.fromLTRB(10, 3, 10, 3),
                                  elevation: 10,
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        loading = true;
                                      });
                                      Navigator.push(
                                          context,
                                          SlideRightRoute(
                                            page: ProjectInfoScreen(
                                              id: results[index].id,
                                            ),
                                          ));
                                      setState(() {
                                        loading = false;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          results[index]
                                                              .data()['name'],
                                                          textScaleFactor: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  primaryColor,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 7,
                                                        ),
                                                        Text(
                                                          getDate(results[index]
                                                              .data()['date']
                                                              .seconds),
                                                          textScaleFactor: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  primaryColor,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
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
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
  }
}
