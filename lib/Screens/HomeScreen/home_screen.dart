import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Screens/DashboardScreen/dashboard_screen.dart';
import 'package:lycread/Screens/HistoryScreen/history_screen.dart';
import 'package:lycread/Screens/LoginScreen/login_screen1.dart';
import 'package:lycread/Screens/ManagementScreen/management_screen.dart';
import 'package:lycread/Screens/ProfileScreen/profile_screen.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  StreamSubscription<QuerySnapshot> subscription;
  List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    ManagementScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> prepare() async {
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
        Navigator.push(
            context,
            SlideRightRoute(
              page: LoginScreen1(),
            ));
      }
    }
  }

  @override
  void initState() {
    // subscription = FirebaseFirestore.instance
    //     .collection('bookings')
    //     .where(
    //       'status',
    //       isEqualTo: 'in process',
    //     )
    //     .where(
    //       'userId',
    //       isEqualTo: FirebaseAuth.instance.currentUser.uid.toString(),
    //     )
    //     .where('seen_status', whereIn: ['unseen'])
    //     .snapshots()
    //     .listen((docsnap) {
    //       if (docsnap != null) {
    //         if (docsnap.docs.length != 0) {
    //           setState(() {
    //             isNotif = true;
    //             notifCounter = docsnap.docs.length;
    //           });
    //         } else {
    //           setState(() {
    //             isNotif = false;
    //             notifCounter = 0;
    //           });
    //         }
    //       } else {
    //         setState(() {
    //           isNotif = false;
    //           notifCounter = 0;
    //         });
    //       }
    //       // if (docsnap.data()['favourites'].contains(widget.containsValue)) {
    //       //   setState(() {
    //       //     isColored = true;
    //       //     isOne = false;
    //       //   });
    //       // } else if (!docsnap.data()['favourites'].contains(widget.containsValue)) {
    //       //   setState(() {
    //       //     isColored = false;
    //       //     isOne = true;
    //       //   });
    //       // }
    //     });
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
        : !can ? LoginScreen1() : Scaffold(
            body: Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.apartment_rounded),
                  label: 'Management',
                ),
                BottomNavigationBarItem(
                  icon: isNotif
                      ? new Stack(
                          children: <Widget>[
                            new Icon(Icons.access_alarm),
                            new Positioned(
                              right: 0,
                              child: new Container(
                                padding: EdgeInsets.all(1),
                                decoration: new BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 15,
                                  minHeight: 15,
                                ),
                                child: new Text(
                                  notifCounter.toString(),
                                  style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        )
                      : Icon(Icons.access_alarm),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
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
