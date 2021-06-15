import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/Screens/WritingScreen/reading_screen.dart';
import 'package:lycread/Screens/loading_screen.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui' as ui;
import '../../../constants.dart';
import 'background.dart';

class MonetizingScreen extends StatefulWidget {
  @override
  _MonetizingScreenState createState() => _MonetizingScreenState();
}

class _MonetizingScreenState extends State<MonetizingScreen> {
  List results = [];
  bool loading = true;
  bool isMem = false;
  DocumentSnapshot user;
  String author = '';
  List<QueryDocumentSnapshot> writings = [];
  QuerySnapshot docs;
  Map wrData = {};
  Map colorWrData = {};
  Map middleChartData = {};
  List<Map> chartData = [];
  List<Map> doughnutData = [];

  String getFnum1(double fnum) {
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
    return r"$ " + fnum1;
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
    final _random = Random();
    DateTime today = DateTime.now();

    middleChartData.addAll({
      DateTime(today.year, today.month, today.day - 4): 0,
      DateTime(today.year, today.month, today.day - 3): 0,
      DateTime(today.year, today.month, today.day - 2): 0,
      DateTime(today.year, today.month, today.day - 1): 0,
      DateTime(today.year, today.month, today.day): 0,
    });
    user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    for (Map log in user.data()['membershipLogs']) {
      if (wrData[log['wr_id']] != null) {
        wrData[log['wr_id']] += log['sum'];
      } else {
        wrData[log['wr_id']] = log['sum'];
      }
      colorWrData[log['wr_id']] = Color.fromRGBO(_random.nextInt(256),
          _random.nextInt(256), _random.nextInt(256), 0.5);

      DateTime mDate = DateTime.parse(log['date']);
      DateTime dDate = DateTime(mDate.year, mDate.month, mDate.day);
      if (middleChartData[dDate] != null) {
        middleChartData[dDate] += log['sum'];
      }
    }
    wrData.forEach(
      (key, value) {
        doughnutData.add(
            {'id': key, 'value': value.toDouble(), 'color': colorWrData[key]});
      },
    );
    print('HERERE');
    print(doughnutData);
    middleChartData.forEach(
      (key, value) {
        chartData.add({'date': key, 'sum': value});
      },
    );
    if (user.data()['isMember'] != null) {
      if (user.data()['isMember']) {
        docs = await FirebaseFirestore.instance
            .collection('writings')
            .where('author', isEqualTo: FirebaseAuth.instance.currentUser.uid)
            .where('isMonetized', isEqualTo: true)
            .where('reads', isNotEqualTo: 0)
            .orderBy('reads', descending: true)
            .limit(5)
            .get();

        if (this.mounted) {
          setState(() {
            isMem = user.data()['isMember'];
            writings = docs.docs;
            loading = false;
          });
        } else {
          isMem = user.data()['isMember'];
          writings = docs.docs;
          loading = false;
        }
      }
    }
    if (this.mounted) {
      setState(() {
        loading = false;
      });
    } else {
      loading = false;
    }
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
    isMem = false;
    author = '';
    writings = [];
    wrData = {};
    colorWrData = {};
    middleChartData = {};
    chartData = [];
    doughnutData = [];
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
              appBar: AppBar(
                backgroundColor: primaryColor,
                centerTitle: true,
                title: Text(
                  'Финансы',
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
              backgroundColor: isMem ? whiteColor : Colors.transparent,
              body: isMem
                  ? SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(
                              'Баланс',
                              overflow: TextOverflow.ellipsis,
                              textScaleFactor: 1,
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: primaryColor,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Text(
                              getFnum1(user.data()['balance']),
                              overflow: TextOverflow.ellipsis,
                              textScaleFactor: 1,
                              maxLines: 1,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: primaryColor,
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RoundedButton(
                              width: 0.4,
                              ph: 45,
                              text: 'Вывод',
                              press: () async {},
                              color: darkPrimaryColor,
                              textColor: whiteColor,
                            ),
                            SizedBox(height: 50),
                            Text(
                              'Монетизация',
                              overflow: TextOverflow.ellipsis,
                              textScaleFactor: 1,
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: primaryColor,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: size.width * 0.9,
                              height: 200,
                              child: SfCartesianChart(
                                primaryXAxis: DateTimeAxis(
                                  dateFormat: DateFormat.d(),
                                  maximumLabels: 5,
                                ),
                                series: <ChartSeries>[
                                  // Renders line chart
                                  LineSeries<Map, DateTime>(
                                    dataSource: chartData,
                                    pointColorMapper: (Map log, _) =>
                                        primaryColor,
                                    xValueMapper: (Map log, _) => log['date'],
                                    yValueMapper: (Map log, _) => log['sum'],
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 200,
                              width: size.width * 0.9,
                              child: SfCircularChart(series: <CircularSeries>[
                                // Renders doughnut chart
                                DoughnutSeries<Map, String>(
                                    dataSource: doughnutData,
                                    pointColorMapper: (Map data, _) =>
                                        data['color'],
                                    xValueMapper: (Map data, _) => data['id'],
                                    yValueMapper: (Map data, _) =>
                                        data['value'],
                                    radius: '100%')
                              ]),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            for (QueryDocumentSnapshot wr in writings)
                              Container(
                                width: size.width * 0.95,
                                height: 100,
                                padding: EdgeInsets.all(10),
                                child: TextButton(
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.zero)),
                                  onPressed: () {
                                    setState(() {
                                      loading = true;
                                    });
                                    Navigator.push(
                                        context,
                                        SlideRightRoute(
                                          page: ReadingScreen(
                                            data: wr,
                                            author: FirebaseAuth.instance
                                                .currentUser.displayName,
                                          ),
                                        ));
                                    setState(() {
                                      loading = false;
                                    });
                                  },
                                  child: Card(
                                    color: colorWrData[wr.id],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    elevation: 11,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: Container(
                                                  width: size.width * 0.6,
                                                  child: Text(
                                                    wr.data()['name'],
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
                                              ),
                                              SizedBox(width: 10),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      getFnum1(wrData[wr.id]
                                                          .toDouble()),
                                                      textScaleFactor: 1,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: primaryColor,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      getDate(wr
                                                          .data()['date']
                                                          .seconds),
                                                      textScaleFactor: 1,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: primaryColor,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
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
                    )
                  : Background(
                      child: SingleChildScrollView(
                        child: Container(
                          color: Color.fromRGBO(0, 0, 0, 0.01),
                          margin: EdgeInsets.fromLTRB(0, size.width, 0, 0),
                          padding: EdgeInsets.all(20),
                          child: ClipRRect(
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(
                                sigmaX: 6.0,
                                sigmaY: 6.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Монетизурйте творчество',
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    textScaleFactor: 1,
                                    maxLines: 10,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: whiteColor,
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    'Показываейте рекламу в ваших историях и получайте деньги. Подробнее здесь',
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    textScaleFactor: 1,
                                    maxLines: 10,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: whiteColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  RoundedButton(
                                    width: 0.3,
                                    ph: 45,
                                    text: 'ОК',
                                    press: () async {
                                      bool can = true;
                                      setState(() {
                                        loading = true;
                                      });
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(FirebaseAuth
                                              .instance.currentUser.uid)
                                          .update({
                                        'isMember': true,
                                        'balance': 0.0,
                                      }).catchError((error) {
                                        can = false;
                                        PushNotificationMessage notification =
                                            PushNotificationMessage(
                                          title: 'Ошибка',
                                          body: 'Неудалось зайти',
                                        );
                                        showSimpleNotification(
                                          Container(
                                              child: Text(notification.body)),
                                          position: NotificationPosition.top,
                                          background: Colors.red,
                                        );
                                        setState(() {
                                          loading = false;
                                        });
                                      });
                                      if (can) {
                                        DocumentSnapshot doc =
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(FirebaseAuth
                                                    .instance.currentUser.uid)
                                                .get();
                                        setState(() {
                                          user = doc;
                                          isMem = true;
                                          loading = false;
                                        });
                                      }
                                    },
                                    color: whiteColor,
                                    textColor: darkPrimaryColor,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(
                                        size.width * 0.05,
                                        0,
                                        size.width * 0.05,
                                        0),
                                    child: Text(
                                      'Продолжая вы принимаете все правила монетизации и нашу Политику Конфиденциальности',
                                      textScaleFactor: 1,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w100,
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
          );
  }
}
