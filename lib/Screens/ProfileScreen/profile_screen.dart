import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Screens/ProfileScreen/components/activity_screen.dart';
import 'package:lycread/Services/auth_service.dart';
import '../../constants.dart';
import '../loading_screen.dart';
import 'components/1.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _PlaceScreenState createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<ProfileScreen> {
  String name;
  Size size;
  bool loading = true;
  DocumentSnapshot user;
  List<Widget> tbvList = [
    VProfileScreen1(),
    ActivityScreen(),
  ];
  List<Widget> tabs = [
    Tab(
      child: Text(
        'Профиль',
        textScaleFactor: 1,
        style: GoogleFonts.montserrat(
          textStyle: TextStyle(
              color: whiteColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    ),
    Tab(
      child: Text(
        'Активность',
        textScaleFactor: 1,
        style: GoogleFonts.montserrat(
          textStyle: TextStyle(
              color: whiteColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    ),
  ];

  Future<void> prepare() async {
    user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    List acts = [];
    for (var act in user.data()['actions']) {
      if (!act['seen']) {
        acts.add(act);
      }
    }

    if (this.mounted) {
      setState(() {
        if (acts.length != 0) {
          tabs = [
            Tab(
              child: Text(
                'Профиль',
                textScaleFactor: 1,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                      color: whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
            ),
            Tab(
              child: Stack(
                children: <Widget>[
                  Text(
                    'Активность',
                    textScaleFactor: 1,
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          color: whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 15,
                        minHeight: 15,
                      ),
                      child: Text(
                        acts.length.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ];
        }
        loading = false;
      });
    } else {
      if (acts.length != 0) {
        tabs = [
          Tab(
            child: Text(
              'Профиль',
              textScaleFactor: 1,
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                    color: whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ),
          Tab(
            child: Stack(
              children: <Widget>[
                Text(
                  'Активность',
                  textScaleFactor: 1,
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                        color: whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 15,
                      minHeight: 15,
                    ),
                    child: Text(
                      acts.length.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          ),
        ];
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
    size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: whiteColor,
              appBar: AppBar(
                  automaticallyImplyLeading: false,
                  toolbarHeight: size.width * 0.17,
                  backgroundColor: primaryColor,
                  centerTitle: true,
                  title: TabBar(
                    isScrollable: true,
                    indicatorColor: whiteColor,
                    tabs: tabs,
                  ),
                  actions: [
                    IconButton(
                      color: whiteColor,
                      icon: Icon(
                        Icons.exit_to_app,
                      ),
                      onPressed: () {
                        AuthService().signOut(context);
                      },
                    ),
                  ]),
              body: TabBarView(
                children: tbvList,
              ),
            ),
          );
  }
}
