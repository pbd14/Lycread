import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Screens/SearchScreen/components/2.dart';
import 'package:lycread/Services/auth_service.dart';
import 'package:lycread/widgets/rounded_button.dart';
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
  bool loading = false;
  List<Widget> tbvList = [
    VProfileScreen1(),
    SecondScreen(),
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

  Future<void> prepare() async {}

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
    // Scaffold(
    // body: Column(
    //   children: [
    //     SizedBox(height: 200),
    //     Center(
    //       child: Text(
    //         'Profile Screen',
    //         overflow: TextOverflow.ellipsis,
    //         maxLines: 2,
    //         style: GoogleFonts.montserrat(
    //           textStyle: TextStyle(
    //             color: darkPrimaryColor,
    //             fontSize: 35,
    //           ),
    //         ),
    //       ),
    //     ),
    //     SizedBox(height: 20),
    //     RoundedButton(
    //       width: 0.5,
    //       height: 0.07,
    //       text: 'Sign out',
    //       press: () {
    //         AuthService().signOut(context);
    //       },
    //       color: darkPrimaryColor,
    //       textColor: whiteColor,
    //     ),
    //   ],
    // ),
    // );
  }
}
