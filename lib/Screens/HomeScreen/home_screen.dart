import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screen_lock/functions.dart';
import 'package:flutter_screen_lock/screen_lock.dart';
import 'package:lycread/Screens/DashboardScreen/dashboard_screen.dart';
import 'package:lycread/Screens/LoginScreen/login_screen1.dart';
import 'package:lycread/Screens/ProfileScreen/profile_screen.dart';
import 'package:lycread/Screens/SearchScreen/search_screen.dart';
import 'package:lycread/Screens/WritingScreen/writing_screen.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../loading_screen.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isNotif = false;

  bool can = true;
  bool loading = false;
  int _selectedIndex = 0;
  int notifCounter = 0;

  // ignore: cancel_subscriptions
  StreamSubscription<DocumentSnapshot> subscription;
  List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    SearchScreen(),
    WritingScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> prepare() async {
    final prefs = await SharedPreferences.getInstance();
    final value1 = prefs.getBool('local_auth') ?? false;
    if (value1) {
      // Navigator.push(
      //   context,
      //   SlideRightRoute(
      //     page: ScreenLock(
      //       correctString: prefs.getString('local_password'),
      //       canCancel: false,
      //     ),
      //   ),
      // );
      screenLock(
          context: context,
          correctString: prefs.getString('local_password'),
          canCancel: false);
    }
    if (FirebaseAuth.instance.currentUser != null) {
      DocumentSnapshot dc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .get();
      if (!dc.exists) {
        if (this.mounted) {
          setState(() {
            can = false;
          });
        } else {
          can = false;
        }
        // Navigator.push(
        //     context,
        //     SlideRightRoute(
        //       page: LoginScreen1(),
        //     ));
      }
    }
  }

  @override
  void initState() {
    subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .snapshots()
        .listen((docsnap) {
      if (docsnap.data()['actions'] != null) {
        if (docsnap.data()['actions'].length != 0) {
          List acts = [];
          for (var act in docsnap.data()['actions']) {
            if (!act['seen']) {
              acts.add(act);
            }
          }
          if (acts.length != 0) {
            setState(() {
              isNotif = true;
              notifCounter = acts.length;
            });
          } else {
            setState(() {
              isNotif = false;
              notifCounter = 0;
            });
          }
        } else {
          setState(() {
            isNotif = false;
            notifCounter = 0;
          });
        }
      } else {
        setState(() {
          isNotif = false;
          notifCounter = 0;
        });
      }
    });
    prepare();
    super.initState();
  }

  // @override
  // void dispose() {
  //   subscription.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingScreen()
        : !can
            ? LoginScreen1()
            : Scaffold(
                body: Center(
                  child: _widgetOptions.elementAt(_selectedIndex),
                ),
                bottomNavigationBar: BottomNavigationBar(
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Лента',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: 'Поиск',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.add_box_rounded,
                        color: footyColor,
                      ),
                      label: 'Добавить',
                    ),
                    BottomNavigationBarItem(
                      icon: isNotif
                          ? new Stack(
                              children: <Widget>[
                                new Icon(CupertinoIcons.person_fill),
                                new Positioned(
                                  right: 0,
                                  child: new Container(
                                    padding: EdgeInsets.all(1),
                                    decoration: new BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 15,
                                      minHeight: 15,
                                    ),
                                    child: new Text(
                                      notifCounter.toString(),
                                      style: new TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Icon(CupertinoIcons.person_fill),
                      label: 'Профиль',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: darkPrimaryColor,
                  unselectedItemColor: primaryColor,
                  onTap: _onItemTapped,
                  backgroundColor: whiteColor,
                  elevation: 50,
                  iconSize: 33.0,
                  selectedFontSize: 17.0,
                  type: BottomNavigationBarType.fixed,
                ),
              );
  }
}
