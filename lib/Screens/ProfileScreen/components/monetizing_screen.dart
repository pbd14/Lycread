import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Models/PushNotificationMessage.dart';
import 'package:lycread/Screens/WritingScreen/reading_screen.dart';
import 'package:lycread/Screens/loading_screen.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../constants.dart';

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
  Map names = {};

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
    return fnum1;
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
    if (this.mounted) {
      setState(() {
        if (user.data()['isMember'] != null) {
          isMem = user.data()['isMember'];
        }
        loading = false;
      });
    } else {
      if (user.data()['isMember'] != null) {
        isMem = user.data()['isMember'];
      }
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
            body: isMem
                ? SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            getFnum1(user.data()['balance']) + ' USD',
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
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Center(
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
                                  color: primaryColor,
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
                                  color: lightPrimaryColor,
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
                                    .doc(FirebaseAuth.instance.currentUser.uid)
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
                                    Container(child: Text(notification.body)),
                                    position: NotificationPosition.top,
                                    background: Colors.red,
                                  );
                                  setState(() {
                                    loading = false;
                                  });
                                });
                                if (can) {
                                  DocumentSnapshot doc = await FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .doc(
                                          FirebaseAuth.instance.currentUser.uid)
                                      .get();
                                  setState(() {
                                    user = doc;
                                    isMem = true;
                                    loading = false;
                                  });
                                }
                              },
                              color: darkPrimaryColor,
                              textColor: whiteColor,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(
                                  size.width * 0.05, 0, size.width * 0.05, 0),
                              child: Text(
                                'Продолжая вы принимаете все правила монетизации и нашу Политику Конфиденциальности',
                                textScaleFactor: 1,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: primaryColor,
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
          );
  }
}
